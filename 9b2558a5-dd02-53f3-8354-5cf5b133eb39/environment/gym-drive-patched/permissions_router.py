"""
Google Drive Permissions API Router
Provides permission management endpoints for Google Drive API mock implementation
"""

import logging
import uuid
from datetime import datetime
from typing import Any, Dict, Literal, Optional

from app.database import get_db_for_session
from app.db.file_repo import FileRepo
from app.db.permission_repo import PermissionRepo
from app.middleware.auth import get_current_user
from app.models.files import File
from app.models.google_drive_model import Drive, Group, User
from app.models.permissions import Permission, PermissionRole, PermissionType
from app.schemas.error_schema import ErrorResponse
from app.schemas.google_drive_schema import PermissionSchema
from app.schemas.permission_schema import CreatePermission
from app.utils.permission_utils import can_create_permission, get_debug_id
from fastapi import (
    APIRouter,
    Body,
    Depends,
    HTTPException,
    Path,
    Query,
    Request,
    status,
)
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

# Set up logging
logger = logging.getLogger(__name__)

permissions_router = APIRouter(tags=["Google Drive Permissions"])


# Pydantic models for request/response
class CreatePermissionRequest(BaseModel):
    fileId: str = Field(..., description="The ID of the file or shared drive")
    role: str = Field(..., description="The role granted by this permission")
    type: str = Field(..., description="The type of the grantee")
    emailAddress: Optional[str] = Field(
        None, description="Email address for user/group permissions"
    )
    domain: Optional[str] = Field(None, description="Domain for domain permissions")
    allowFileDiscovery: Optional[bool] = Field(
        False, description="Allow file discovery through search"
    )
    sendNotificationEmail: Optional[bool] = Field(
        True, description="Send notification email"
    )
    emailMessage: Optional[str] = Field(
        None, description="Custom message in notification email"
    )


class UpdatePermissionRequest(BaseModel):
    role: Optional[str] = Field(None, description="The role to update")


def _permission_to_dict(permission: Permission, db: Session) -> Dict[str, Any]:
    """Convert Permission model to Google Drive API format"""
    result = {
        "kind": permission.kind or "drive#permission",
        "id": permission.id,
        "type": permission.type.value if permission.type else None,
        "role": permission.role.value if permission.role else None,
        "allowFileDiscovery": permission.allow_file_discovery,
    }

    permission_details = []
    if permission.drive_id and permission.inherited:
        permission_type = "file" if permission.file_id else "member"
        permission_details.append(
            {
                "permissionType": permission_type,
                "role": permission.role.value if permission.role else None,
                "inherited": permission.inherited,
                "inheritedFrom": permission.inherited_from,
            }
        )
    result["permissionDetails"] = permission_details

    if permission.user_id:
        user = db.query(User).filter(User.id == permission.user_id).first()
        if user:
            result.update(
                {
                    "emailAddress": user.email,
                    "displayName": user.display_name,
                    "photoLink": user.photo_url,
                }
            )
    elif permission.group_id:
        group = db.query(Group).filter(Group.id == permission.group_id).first()
        if group:
            result.update({"emailAddress": group.email, "displayName": group.name})
    elif permission.email_address:
        result["emailAddress"] = permission.email_address
    elif permission.domain:
        result["domain"] = permission.domain

    if permission.expiration_time:
        result["expirationTime"] = permission.expiration_time.isoformat() + "Z"

    if permission.deleted is not None:
        result["deleted"] = permission.deleted

    if permission.pending_owner is not None:
        result["pendingOwner"] = permission.pending_owner

    if permission.view:
        result["view"] = (
            permission.view.value
            if hasattr(permission.view, "value")
            else permission.view
        )

    return result


@permissions_router.post(
    "/files/{file_id}/permissions",
    response_model=PermissionSchema,
    status_code=status.HTTP_201_CREATED,
    responses={
        201: {
            "description": "Permission created successfully",
            "content": {
                "application/json": {
                    "example": {
                        "id": "permission123",
                        "file_id": "file123",
                        "user_id": "user123",
                        "type": "user",
                        "role": "owner",
                        "email_address": "user@example.com",
                        "domain": None,
                        "display_name": "John Doe",
                        "photo_link": "https://example.com/photo.jpg",
                        "allow_file_discovery": True,
                        "deleted": False,
                        "pending_owner": False,
                        "inherited_permissions_disabled": False,
                        "expiration_time": None,
                        "view": "published",
                        "permission_details": [],
                    }
                }
            },
        },
        400: {
            "description": "The request is not well-formed, is syntactically incorrect, or violates schema.",
            "content": {
                "application/json": {
                    "example": {
                        "name": "INVALID_REQUEST",
                        "message": "Request is not well-formed, syntactically incorrect, or violates schema.",
                        "debug_id": "b1d1f06c7246c",
                    }
                }
            },
        },
        401: {
            "description": "Authentication failed due to missing Authorization header, or invalid authentication credentials.",
            "content": {
                "application/json": {
                    "example": {
                        "name": "AUTHENTICATION_FAILURE",
                        "message": "Authentication failed due to missing authorization header, or invalid authentication credentials.",
                        "debug_id": "b1d1f06c7246d",
                    }
                }
            },
        },
        403: {
            "description": "Authorization failed due to insufficient permissions.",
            "content": {
                "application/json": {
                    "example": {
                        "name": "NOT_AUTHORIZED",
                        "message": "Authorization failed due to insufficient permissions.",
                        "debug_id": "b1d1f06c7246e",
                    }
                }
            },
        },
        500: {
            "description": "An internal server error occurred.",
            "content": {
                "application/json": {
                    "example": {
                        "name": "INTERNAL_SERVER_ERROR",
                        "message": "An internal server error occurred.",
                        "debug_id": "b1d1f06c7246f",
                    }
                }
            },
        },
    },
)
def create_permission(
    request: Request,
    permission_data: CreatePermission = Body(...),
    db: Session = Depends(get_db_for_session),
    file_id: str = Path(..., description="The ID of the file"),
    emailMessage: Optional[str] = Query(
        None,
        description="A plain text custom message to include in the notification email",
    ),
    moveToNewOwnersRoot: Optional[bool] = Query(
        None,
        description="This parameter only takes effect if the item is not in a shared drive and the request is attempting to transfer the ownership of the item",
    ),
    sendNotificationEmail: Optional[bool] = Query(
        True,
        description="Whether to send a notification email when sharing to users or groups",
    ),
    supportsAllDrives: Optional[bool] = Query(
        False,
        description="Whether the requesting application supports both My Drives and shared drives",
    ),
    transferOwnership: Optional[bool] = Query(
        False,
        description="Whether to transfer ownership to the specified user and downgrade the current owner to a writer",
    ),
    useDomainAdminAccess: Optional[bool] = Query(
        False, description="Issue the request as a domain administrator"
    ),
    supportsTeamDrives: Optional[bool] = Query(
        None, description="Deprecated: Use supportsAllDrives instead."
    ),
    enforceExpansiveAccess: Optional[bool] = Query(
        False, description="Whether to enforce expansive access"
    ),
    current_user: User = Depends(get_current_user),
):
    """Create a permission for a file or shared drive"""

    debug_id = get_debug_id()
    try:
        logger.info(f"Creating permission for file {file_id}")

        # Handle deprecated supportsTeamDrives parameter
        if supportsTeamDrives is not None:
            logger.warning(
                "supportsTeamDrives parameter is deprecated. Use supportsAllDrives instead."
            )
            # Use supportsTeamDrives value if supportsAllDrives is False
            if not supportsAllDrives:
                supportsAllDrives = supportsTeamDrives

        aFile = db.query(File).filter(File.id == file_id).first()
        if not aFile:
            return JSONResponse(
                status_code=404,
                content=ErrorResponse(
                    name="FILE_NOT_FOUND",
                    message=f"File '{file_id}' not found",
                    debug_id=debug_id,
                ).model_dump(),
            )

        try:
            role = PermissionRole(permission_data.role)
            perm_type = PermissionType(permission_data.type)
        except ValueError:
            return JSONResponse(
                status_code=400,
                content=ErrorResponse(
                    name="INVALID_REQUEST",
                    message="Invalid role or type specified",
                    debug_id=debug_id,
                ).model_dump(),
            )

        permission = Permission(
            id=str(uuid.uuid4()),
            file_id=file_id,
            role=role,
            type=perm_type,
            allow_file_discovery=permission_data.allow_file_discovery or False,
            email_address=permission_data.email_address,
            domain=permission_data.domain,
            expiration_time=permission_data.expiration_time,
            view=permission_data.view,
            pending_owner=permission_data.pending_owner,
            inherited_permissions_disabled=permission_data.inherited_permissions_disabled,
        )

        if not can_create_permission(current_user, aFile, db):
            return JSONResponse(
                status_code=403,
                content=ErrorResponse(
                    name="NOT_AUTHORIZED",
                    message="You do not have permission to share this file",
                    debug_id=debug_id,
                ).model_dump(),
            )

        if perm_type == PermissionType.USER:
            if not permission_data.email_address:
                return JSONResponse(
                    status_code=400,
                    content=ErrorResponse(
                        name="INVALID_REQUEST",
                        message="email_address is required for user permissions",
                        debug_id=debug_id,
                    ).model_dump(),
                )
            user = (
                db.query(User)
                .filter(User.email == permission_data.email_address)
                .first()
            )
            if user:
                permission.user_id = user.id
                permission.email_address = None
            else:
                permission.email_address = permission_data.email_address

        elif perm_type == PermissionType.GROUP:
            if not permission_data.email_address:
                return JSONResponse(
                    status_code=400,
                    content=ErrorResponse(
                        name="INVALID_REQUEST",
                        message="email_address is required for group permissions",
                        debug_id=debug_id,
                    ).model_dump(),
                )
            group = (
                db.query(Group)
                .filter(Group.email == permission_data.email_address)
                .first()
            )
            if group:
                permission.group_id = group.id
                permission.email_address = None
            else:
                permission.email_address = permission_data.email_address

        elif perm_type == PermissionType.DOMAIN:
            if not permission_data.domain:
                return JSONResponse(
                    status_code=400,
                    content=ErrorResponse(
                        name="INVALID_REQUEST",
                        message="domain is required for domain permissions",
                        debug_id=debug_id,
                    ).model_dump(),
                )
            permission.domain = permission_data.domain

        if transferOwnership and perm_type == PermissionType.USER:
            if role != PermissionRole.OWNER:
                logger.warning(
                    "transferOwnership is True but role is not 'owner', adjusting role to 'owner'"
                )
                permission.role = PermissionRole.OWNER

            new_owner = None
            if permission_data.email_address:
                new_owner = (
                    db.query(User)
                    .filter(User.email == permission_data.email_address)
                    .first()
                )

            if not new_owner:
                return JSONResponse(
                    status_code=404,
                    content=ErrorResponse(
                        name="USER_NOT_FOUND",
                        message=f"User with email {permission_data.email_address} not found",
                        debug_id=debug_id,
                    ).model_dump(),
                )

            current_user_id = current_user.id if current_user else None

            try:
                FileRepo.transfer_file_ownership(db, aFile, new_owner, current_user_id)
                logger.info(
                    f"Successfully transferred ownership of file {file_id} to {permission_data.email_address}"
                )

                aFile.created_by = new_owner.id
                db.commit()

            except Exception as e:
                logger.error(f"Failed to transfer ownership: {str(e)}")
                raise HTTPException(
                    status_code=500,
                    content=ErrorResponse(
                        name="INTERNAL_SERVER_ERROR",
                        message=f"Failed to transfer ownership: {str(e)}",
                        debug_id=debug_id,
                    ).model_dump(),
                )

        if moveToNewOwnersRoot and transferOwnership:
            try:
                aFile.parent_id = None
                db.commit()
                logger.info(f"Moved file {file_id} to new owner's root")
            except Exception as e:
                logger.error(f"Failed to move file to new owner's root: {str(e)}")

        if sendNotificationEmail and permission_data.email_address:
            notification_message = (
                emailMessage or f"You have been granted {role.value} access to the file"
            )
            logger.info(
                f"Would send notification email to {permission_data.email_address}: {notification_message}"
            )

        if useDomainAdminAccess:
            logger.info("Using domain admin access for permission creation")

        if enforceExpansiveAccess:
            logger.info("Enforcing expansive access for permission creation")

        # FIX (gym-patch): files.drive_id is NOT NULL in the schema, so bool(aFile.drive_id) flagged
        # EVERY file as a Shared Drive and create_permission rejected all of them (no file could ever
        # be shared). A file is only in a Shared Drive when its drive is not the user's personal
        # "My Drive". Resolve the drive and decide by that instead of mere presence of a drive_id.
        _drive = db.query(Drive).filter(Drive.id == aFile.drive_id).first()
        is_shared_drive = _drive is not None and _drive.name != "My Drive"

        if supportsAllDrives:
            logger.info("Application supports both My Drive and Shared Drives")
            if is_shared_drive:
                logger.info(f"File is in shared drive: {aFile.drive_id}")
            else:
                logger.info("File is in My Drive")
        else:
            logger.info("Application only supports My Drive")
            if is_shared_drive:
                logger.info(
                    "File is in a shared drive and the request doesn't support all drives, rejecting the request"
                )
                return JSONResponse(
                    status_code=400,
                    content=ErrorResponse(
                        name="INVALID_REQUEST",
                        message="This application only supports My Drive files, not Shared Drive files",
                        debug_id=debug_id,
                    ).model_dump(),
                )

        PermissionRepo.create_permission(db, permission)

        response_data = _permission_to_dict(permission, db)
        logger.info(f"Permission created successfully: {permission.id}")

        return JSONResponse(status_code=201, content=response_data)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating permission: {str(e)}")
        db.rollback()

        error_message = str(e)
        if "check_permission_type_consistency" in error_message:
            return JSONResponse(
                status_code=400,
                content=ErrorResponse(
                    name="INVALID_PERMISSION_TYPE",
                    message="Invalid permission configuration. For group permissions, the group must exist in the system. For user permissions, the user must exist in the system. Please check that the email address corresponds to an existing user or group.",
                    debug_id=debug_id,
                ).model_dump(),
            )
        elif "check_file_discovery_type" in error_message:
            return JSONResponse(
                status_code=400,
                content=ErrorResponse(
                    name="INVALID_FILE_DISCOVERY",
                    message="File discovery is only allowed for 'domain' and 'anyone' permission types, not for 'user' or 'group' permissions.",
                    debug_id=debug_id,
                ).model_dump(),
            )
        elif "UNIQUE constraint failed" in error_message:
            return JSONResponse(
                status_code=409,
                content=ErrorResponse(
                    name="PERMISSION_ALREADY_EXISTS",
                    message="A permission with these parameters already exists for this file. Please check for duplicate permissions.",
                    debug_id=debug_id,
                ).model_dump(),
            )
        else:
            return JSONResponse(
                status_code=500,
                content=ErrorResponse(
                    name="INTERNAL_SERVER_ERROR",
                    message="An unexpected error occurred while creating the permission. Please try again or contact support if the problem persists.",
                    debug_id=debug_id,
                ).model_dump(),
            )


@permissions_router.delete("/permissions.delete")
def delete_permission(
    request: Request,
    fileId: str = Query(
        ..., description="The ID of the file containing the permission"
    ),
    permissionId: str = Query(..., description="The ID of the permission to delete"),
    supportsAllDrives: bool = Query(
        False, description="Whether the application supports all drives"
    ),
    db: Session = Depends(get_db_for_session),
    current_user: User = Depends(get_current_user),
):
    """Delete a permission from a file or shared drive"""
    try:
        logger.info(f"Deleting permission {permissionId} from file {fileId}")

        file = db.query(File).filter(File.id == fileId).first()
        if not file:
            raise HTTPException(status_code=404, detail=f"File '{fileId}' not found")

        permission = (
            db.query(Permission)
            .filter(Permission.id == permissionId, Permission.file_id == fileId)
            .first()
        )

        if not permission:
            raise HTTPException(
                status_code=404,
                detail=f"Permission '{permissionId}' not found in file '{fileId}'",
            )

        db.delete(permission)
        db.commit()

        logger.info(f"Permission deleted successfully: {permissionId}")
        return {"message": "Permission deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting permission: {str(e)}")
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@permissions_router.get("/permissions.get")
def get_permission(
    request: Request,
    fileId: str = Query(
        ..., description="The ID of the file containing the permission"
    ),
    permissionId: str = Query(..., description="The ID of the permission to retrieve"),
    supportsAllDrives: bool = Query(
        False, description="Whether the application supports all drives"
    ),
    db: Session = Depends(get_db_for_session),
    current_user: User = Depends(get_current_user),
):
    """Get a specific permission by ID"""
    try:
        logger.info(f"Getting permission {permissionId} from file {fileId}")

        file = db.query(File).filter(File.id == fileId).first()
        if not file:
            raise HTTPException(status_code=404, detail=f"File '{fileId}' not found")

        permission = (
            db.query(Permission)
            .filter(Permission.id == permissionId, Permission.file_id == fileId)
            .first()
        )

        if not permission:
            raise HTTPException(
                status_code=404,
                detail=f"Permission '{permissionId}' not found in file '{fileId}'",
            )

        response_data = _permission_to_dict(permission, db)
        logger.info(f"Permission retrieved successfully: {permissionId}")

        return response_data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting permission: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@permissions_router.get("/files/{fileId}/permissions")
def list_permissions(
    fileId: str = Path(
        ..., description="The ID of the file or shared drive to list permissions for"
    ),
    includePermissionsForView: Optional[Literal["published"]] = Query(
        None,
        description="Specifies which additional view's permissions to include. Only 'published' is supported.",
    ),
    pageSize: Optional[int] = Query(
        None,
        ge=1,
        le=100,
        description="The maximum number of permissions to return per page. When not set for files in a shared drive, at most 100 results will be returned. When not set for files that are not in a shared drive, the entire list will be returned.",
    ),
    pageToken: Optional[str] = Query(
        None,
        description="The token for continuing a previous list request on the next page. This should be set to the value of nextPageToken from the previous response.",
    ),
    supportsAllDrives: bool = Query(
        False,
        description="Whether the requesting application supports both My Drives and shared drives",
    ),
    supportsTeamDrives: Optional[bool] = Query(
        None, description="Deprecated: Use supportsAllDrives instead."
    ),
    useDomainAdminAccess: bool = Query(
        False,
        description="Issue the request as a domain administrator. If set to true, and if the following additional conditions are met, the requester is granted access: The file ID parameter refers to a shared drive. The requester is an administrator of the domain to which the shared drive belongs.",
    ),
    db: Session = Depends(get_db_for_session),
    current_user: User = Depends(get_current_user),
):
    """Lists the permissions for a file or shared drive."""
    try:
        logger.info(f"Listing permissions for file {fileId}")

        # Handle deprecated supportsTeamDrives parameter
        if supportsTeamDrives is not None:
            logger.warning(
                "supportsTeamDrives parameter is deprecated. Use supportsAllDrives instead."
            )
            # Use supportsTeamDrives value if supportsAllDrives is False
            if not supportsAllDrives:
                supportsAllDrives = supportsTeamDrives

        if includePermissionsForView and includePermissionsForView != "published":
            raise HTTPException(
                status_code=400,
                detail="includePermissionsForView only supports 'published' value",
            )

        file = db.query(File).filter(File.id == fileId).first()
        if not file:
            raise HTTPException(status_code=404, detail=f"File '{fileId}' not found")

        is_shared_drive = bool(file.drive_id)

        if pageSize is None:
            if is_shared_drive:
                pageSize = 100
            else:
                pageSize = 10000

        if useDomainAdminAccess:
            logger.info("Using domain admin access for listing permissions")

        permissions_query = db.query(Permission).filter(Permission.file_id == fileId)

        total_count = permissions_query.count()

        offset = 0
        if pageToken:
            try:
                if pageToken.startswith("page_"):
                    offset = int(pageToken.replace("page_", ""))
                    logger.info(f"Using pageToken with offset: {offset}")
                else:
                    offset = int(pageToken)
                    logger.info(f"Using pageToken as integer offset: {offset}")
            except (ValueError, AttributeError):
                logger.warning(
                    f"Invalid pageToken format: {pageToken}, starting from beginning"
                )
                offset = 0

        permissions = permissions_query.offset(offset).limit(pageSize).all()

        permissions_data = []
        for permission in permissions:
            permissions_data.append(_permission_to_dict(permission, db))

        response_data = {
            "kind": "drive#permissionList",
            "permissions": permissions_data,
        }

        current_items = offset + len(permissions_data)
        has_more = current_items < total_count

        if has_more:
            next_offset = offset + pageSize
            response_data["nextPageToken"] = f"page_{next_offset}"
            logger.info(f"Next page token: page_{next_offset}")

        logger.info(f"Listed {len(permissions_data)} permissions for file {fileId}")
        return response_data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error listing permissions: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@permissions_router.patch("/files/{file_id}/permissions/{permission_id}")
def update_permission(
    request: Request,
    file_id: str = Path(..., description="The ID of the file or shared drive"),
    permission_id: str = Path(..., description="The ID of the permission to update"),
    permission_data: UpdatePermissionRequest = Body(...),
    db: Session = Depends(get_db_for_session),
    supportsAllDrives: Optional[bool] = Query(
        False,
        description="Whether the requesting application supports both My Drives and shared drives",
    ),
    supportsTeamDrives: Optional[bool] = Query(
        None, description="Deprecated: Use supportsAllDrives instead."
    ),
    transferOwnership: Optional[bool] = Query(
        False,
        description="Whether to transfer ownership to the specified user and downgrade the current owner to a writer",
    ),
    useDomainAdminAccess: Optional[bool] = Query(
        False, description="Issue the request as a domain administrator"
    ),
    removeExpiration: Optional[bool] = Query(
        False, description="Whether to remove the expiration date"
    ),
    enforceExpansiveAccess: Optional[bool] = Query(
        False, description="Whether the request should enforce expansive access rules"
    ),
    current_user: User = Depends(get_current_user),
):
    """Update an existing permission"""
    debug_id = get_debug_id()
    try:
        logger.info(f"Updating permission {permission_id} for file {file_id}")

        # Handle deprecated supportsTeamDrives parameter
        if supportsTeamDrives is not None:
            logger.warning(
                "supportsTeamDrives parameter is deprecated. Use supportsAllDrives instead."
            )
            # Use supportsTeamDrives value if supportsAllDrives is False
            if not supportsAllDrives:
                supportsAllDrives = supportsTeamDrives

        query_params = {
            "supportsAllDrives": supportsAllDrives,
            "transferOwnership": transferOwnership,
            "useDomainAdminAccess": useDomainAdminAccess,
            "removeExpiration": removeExpiration,
            "enforceExpansiveAccess": enforceExpansiveAccess,
        }
        logger.info(f"Update query parameters: {query_params}")

        file = db.query(File).filter(File.id == file_id).first()
        if not file:
            return JSONResponse(
                status_code=404,
                content=ErrorResponse(
                    name="FILE_NOT_FOUND",
                    message=f"File '{file_id}' not found",
                    debug_id=debug_id,
                ).model_dump(),
            )

        permission = (
            db.query(Permission)
            .filter(
                Permission.id == permission_id,
                Permission.file_id == file_id,
            )
            .first()
        )

        if not permission:
            return JSONResponse(
                status_code=404,
                content=ErrorResponse(
                    name="PERMISSION_NOT_FOUND",
                    message=f"Permission '{permission_id}' not found in file '{file_id}'",
                    debug_id=debug_id,
                ).model_dump(),
            )

        if not can_create_permission(current_user, file, db):
            return JSONResponse(
                status_code=403,
                content=ErrorResponse(
                    name="NOT_AUTHORIZED",
                    message="You do not have permission to update permissions on this file",
                    debug_id=debug_id,
                ).model_dump(),
            )

        if transferOwnership and permission_data.role:
            if permission_data.role != "owner":
                logger.warning(
                    "transferOwnership is True but role is not 'owner', adjusting role to 'owner'"
                )
                permission_data.role = "owner"
            logger.info(f"Transferring ownership for permission {permission_id}")

        if useDomainAdminAccess:
            logger.info("Using domain admin access for permission update")

        if enforceExpansiveAccess:
            logger.info("Enforcing expansive access rules for permission update")

        if removeExpiration:
            logger.info(f"Removing expiration date for permission {permission_id}")
            permission.expiration_time = None

        if permission_data.role:
            try:
                permission.role = PermissionRole(permission_data.role)
            except ValueError:
                return JSONResponse(
                    status_code=400,
                    content=ErrorResponse(
                        name="INVALID_REQUEST",
                        message="Invalid role specified",
                        debug_id=debug_id,
                    ).model_dump(),
                )

        permission.updated_time = datetime.utcnow()

        db.commit()
        db.refresh(permission)

        response_data = _permission_to_dict(permission, db)
        logger.info(f"Permission updated successfully: {permission_id}")

        return JSONResponse(status_code=200, content=response_data)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating permission: {str(e)}")
        db.rollback()
        return JSONResponse(
            status_code=500,
            content=ErrorResponse(
                name="INTERNAL_SERVER_ERROR",
                message=f"Internal server error: {str(e)}",
                debug_id=debug_id,
            ).model_dump(),
        )
