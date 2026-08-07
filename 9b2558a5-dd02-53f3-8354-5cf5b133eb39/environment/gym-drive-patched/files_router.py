"""
Google Drive Files API Router
Provides files.create and files.delete endpoints for Google Drive API mock implementation.

Notes:
- Handles metadata creation and deletion (no binary upload handling yet).
- Now requires authentication using X-Auth-Token and X-Database-ID headers.
"""

import logging
import re
import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional

from app.database import get_db_for_session
from app.middleware.auth import get_current_user
from app.models.files import File
from app.models.google_drive_model import (
    Drive,
    FileLabel,
    Label,
    TrashLog,
    User,
    generate_uuid,
)
from app.models.permissions import Permission, PermissionRole, PermissionView
from app.models.revisions import Revision
from app.schemas.files_schema import (
    FileCreateRequest,
    FileResponse,
    FileSchema,
    FilesGenerateIdsResponse,
    FilesListQueryParams,
    FilesListResponse,
    FilesUpdateRequest,
    FileUser,
    GoogleDriveMimeTypes,
    map_file_model_to_file_schema,
)
from app.schemas.tools.files_validation import EXPORTABLE_TYPES, FilesExportArgs
from app.utils.export_binary import generate_export_bytes
from app.utils.permission_utils import can_copy_file
from fastapi import (
    APIRouter,
    Body,
    Depends,
    HTTPException,
    Path,
    Query,
    Request,
    Response,
    status,
)
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, ValidationError
from pydantic_core import ValidationError as PydanticCoreValidationError
from sqlalchemy import and_, exists, func, or_, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified


# Temporary local fallback (keeps behavior predictable for this step)
def _sanitize_filename(filename: Optional[str]) -> str:
    if not filename:
        return "untitled"
    unsafe_chars = ["<", ">", ":", '"', "|", "?", "*", "\\", "/"]
    for ch in unsafe_chars:
        filename = filename.replace(ch, "_")
    return filename.strip()[:255]


def _apply_google_drive_query(query, q: str, db: Session):
    """
    Apply Google Drive API compliant query to the database query.

    Supports query syntax: queryterm operator values
    Examples:
    - mimeType='image/jpeg'
    - name contains 'document'
    - starred = true
    - trashed = false
    - modifiedTime > '2024-01-01T00:00:00Z'
    - modifiedTime >= '2024-01-01T00:00:00Z'
    - modifiedTime <= '2024-01-01T00:00:00Z'
    - viewedByMeTime > '2024-01-01T00:00:00Z'
    - parents in 'folder_id'
    - fullText contains 'hello'
    - fullText contains '"hello world"'
    - visibility = 'limited'
    - shortcutDetails.targetId = 'file_id'
    - 'test@example.org' in owners
    - 'group@example.org' in writers
    - sharedWithMe = true
    - properties has { key='mass' and value='1.3kg' }
    - modifiedTime > '2012-06-04T12:00:00' and (mimeType contains 'image/' or mimeType contains 'video/')
    """
    try:
        # Parse the query string
        conditions = _parse_google_drive_query(q)
        logger.info(f"Parsed query '{q}' into conditions: {conditions}")

        # Apply conditions with logical operators
        query = _apply_conditions_with_logical_operators(query, conditions, db)

        return query
    except Exception as e:
        logger.warning(f"Error parsing query '{q}': {e}")
        # Fallback to simple text search
        search_terms = q.lower().split()
        for term in search_terms:
            query = query.filter(
                (File.name.ilike(f"%{term}%")) | (File.mime_type.ilike(f"%{term}%"))
            )
        return query


def _apply_conditions_with_logical_operators(
    query, conditions: List[Dict[str, Any]], db: Session
):
    """
    Apply conditions with logical operators (AND/OR) to the database query.
    """
    if not conditions:
        return query

    # Build filter conditions, grouping OR conditions together
    # Strategy: Process conditions and look ahead to see if next operator is OR
    filter_conditions = []
    or_group = []  # Current group of OR conditions
    in_or_group = False  # Whether we're currently building an OR group

    i = 0
    while i < len(conditions):
        condition = conditions[i]

        if condition["type"] == "condition":
            # Apply the condition and get the filter
            filter_condition = _build_filter_condition(condition, db)
            if filter_condition is None:
                i += 1
                continue

            # Look ahead to see if next operator is OR
            next_is_or = False
            if i + 1 < len(conditions) and conditions[i + 1].get("type") == "logical":
                next_is_or = conditions[i + 1].get("operator") == "or"

            if in_or_group or next_is_or:
                # Add to OR group
                or_group.append(filter_condition)
                in_or_group = next_is_or  # Continue OR group if next is also OR
            else:
                # Finalize any pending OR group first
                if or_group:
                    if len(or_group) == 1:
                        filter_conditions.append(or_group[0])
                    else:
                        filter_conditions.append(or_(*or_group))
                    or_group = []
                    in_or_group = False

                # Add as regular condition (AND)
                filter_conditions.append(filter_condition)

        elif condition["type"] == "logical":
            operator = condition["operator"]

            if operator == "and":
                # AND operator - finalize any OR group
                if or_group:
                    if len(or_group) == 1:
                        filter_conditions.append(or_group[0])
                    else:
                        filter_conditions.append(or_(*or_group))
                    or_group = []
                    in_or_group = False
            elif operator == "or":
                # OR operator - we're in an OR group
                in_or_group = True

        i += 1

    # Finalize any remaining OR group
    if or_group:
        if len(or_group) == 1:
            filter_conditions.append(or_group[0])
        else:
            filter_conditions.append(or_(*or_group))
    # Apply all filter conditions
    if filter_conditions:
        if len(filter_conditions) == 1:
            query = query.filter(filter_conditions[0])
        else:
            # Combine multiple conditions with AND
            query = query.filter(and_(*filter_conditions))

    return query


def _build_filter_condition(condition: Dict[str, Any], db: Session):
    """
    Build a SQLAlchemy filter condition from a parsed condition.
    """
    field = condition["field"]
    operator = condition["operator"]
    value = condition["value"]
    negated = condition.get("negated", False)

    # Handle special permission fields that require complex queries
    if field in ["owners", "writers", "readers"] and operator == "in":
        return _build_permission_filter(field, value, negated, db)

    # Handle sharedWithMe field
    if field == "sharedWithMe":
        return _build_shared_with_me_filter(value, negated, db)

    # Handle properties and appProperties with has operator
    if field in ["properties", "appProperties"] and operator == "has":
        return _build_property_has_filter(field, value, negated, db)

    # Handle shortcutDetails.targetId field (nested field)
    if field == "shortcutDetails.targetId":
        return _build_shortcut_target_filter(value, operator, negated, db)

    # Handle visibility field
    if field == "visibility":
        return _build_visibility_filter(value, operator, negated, db)

    # Handle fullText search - searches name, description, and potentially content
    if field == "fullText" and operator == "contains":
        was_double_quoted = condition.get("was_double_quoted", False)
        return _build_fulltext_filter(
            value, negated, db, was_double_quoted=was_double_quoted
        )

    # Handle parents field with in operator - check if value is in parent_ids JSON array
    if field == "parents" and operator == "in":
        # For query like: 'folder_id' in parents
        # Check if the folder_id exists in the parent_ids JSON array
        # SQLAlchemy's JSON contains method checks if the JSON array contains the value
        filter_condition = File.parent_ids.contains([value])

        if negated:
            filter_condition = ~filter_condition

        return filter_condition

    # Handle labels field with in operator - check if file has a specific label
    # Query format: 'labels/LABEL_ID' in labels
    if field == "labels" and operator == "in":
        return _build_labels_in_filter(value, negated, db)

    # Handle labels/LABEL_ID.FIELD pattern - check label field value
    # Query format: labels/LABEL_ID.FIELD = value
    # Also handle IS NULL / IS NOT NULL operators for label fields
    # Also handle case where field might be parsed as LABEL_ID.FIELD (without labels/ prefix)
    # This can happen if the regex doesn't capture the full path
    # Check if field looks like a label field (has a dot and looks like an ID.field pattern)
    if field.startswith("labels/") and "." in field:
        return _build_labels_field_filter(field, operator, value, negated, db)
    # Handle IS NULL / IS NOT NULL for label fields (field might not have labels/ prefix)
    elif operator in ["IS_NULL", "IS_NOT_NULL"] and "." in field:
        # Check if it looks like a label field (long ID before the dot)
        if len(field.split(".")[0]) > 20 and not field.startswith("shortcut"):
            # Field looks like LABEL_ID.field_name - add labels/ prefix
            field = f"labels/{field}"
            return _build_labels_field_filter(field, operator, value, negated, db)
    # Fallback: if field has a dot and looks like an ID (long alphanumeric string), treat as label field
    elif (
        "." in field
        and len(field.split(".")[0]) > 20
        and not field.startswith("shortcut")
    ):
        # Field looks like LABEL_ID.field_name - add labels/ prefix
        field = f"labels/{field}"
        return _build_labels_field_filter(field, operator, value, negated, db)

    # Map Google Drive fields to database fields
    field_mapping = {
        "name": File.name,
        "mimeType": File.mime_type,
        "starred": File.starred,
        "trashed": File.trashed,
        "modifiedTime": File.modified_time,
        "createdTime": File.created_time,
        "viewedByMeTime": File.viewed_by_me_time,
        "size": File.size_bytes,
        "parents": File.parent_id,  # Only used for non-in operators
        "owners": File.created_by,  # Fallback for simple cases
        "writers": File.modified_by,  # Fallback for simple cases
        "readers": File.created_by,  # Fallback for simple cases
        "sharedWithMe": File.created_by,  # Fallback for simple cases
        "properties": File.properties,
        "appProperties": File.properties,
        "labels": File.id,  # TODO: Implement label search
    }

    if field not in field_mapping:
        logger.warning(f"Unknown query field: {field}")
        return None

    db_field = field_mapping[field]

    # Build the filter condition
    if operator == "=":
        filter_condition = db_field == value
    elif operator == "!=":
        filter_condition = db_field != value
    elif operator == ">":
        if field in ["modifiedTime", "createdTime", "viewedByMeTime"]:
            try:
                dt_value = datetime.fromisoformat(value.replace("Z", "+00:00"))
                filter_condition = db_field > dt_value
            except ValueError:
                logger.warning(f"Invalid datetime format: {value}")
                return None
        else:
            filter_condition = db_field > value
    elif operator == ">=":
        if field in ["modifiedTime", "createdTime", "viewedByMeTime"]:
            try:
                dt_value = datetime.fromisoformat(value.replace("Z", "+00:00"))
                filter_condition = db_field >= dt_value
            except ValueError:
                logger.warning(f"Invalid datetime format: {value}")
                return None
        else:
            filter_condition = db_field >= value
    elif operator == "<":
        if field in ["modifiedTime", "createdTime", "viewedByMeTime"]:
            try:
                dt_value = datetime.fromisoformat(value.replace("Z", "+00:00"))
                filter_condition = db_field < dt_value
            except ValueError:
                logger.warning(f"Invalid datetime format: {value}")
                return None
        else:
            filter_condition = db_field < value
    elif operator == "<=":
        if field in ["modifiedTime", "createdTime", "viewedByMeTime"]:
            try:
                dt_value = datetime.fromisoformat(value.replace("Z", "+00:00"))
                filter_condition = db_field <= dt_value
            except ValueError:
                logger.warning(f"Invalid datetime format: {value}")
                return None
        else:
            filter_condition = db_field <= value
    elif operator == "contains":
        if isinstance(value, str):
            # According to Google Drive API docs, "name contains" only performs prefix matching,
            # not substring matching. For other fields, use substring matching.
            if field == "name":
                # Prefix matching: value must be at the start of the field
                filter_condition = db_field.ilike(f"{value}%")
            else:
                # Substring matching for other fields (e.g., mimeType, fullText)
                filter_condition = db_field.ilike(f"%{value}%")
        else:
            logger.warning(
                f"Contains operator requires string value, got: {type(value)}"
            )
            return None
    elif operator == "in":
        if isinstance(value, str):
            values = [v.strip() for v in value.split(",")]
            filter_condition = db_field.in_(values)
        else:
            filter_condition = db_field.in_(value)
    elif operator == "has":
        # This should be handled by the special cases above
        logger.warning(f"Has operator not yet implemented for field: {field}")
        return None
    else:
        logger.warning(f"Unknown operator: {operator}")
        return None

    # Apply negation if needed
    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _parse_google_drive_query(q: str) -> List[Dict[str, Any]]:
    """
    Parse Google Drive query string into conditions.

    Returns list of dictionaries with keys: field, operator, value, negated
    Supports complex queries with AND/OR operators and parentheses.
    """
    conditions = []

    # Handle parentheses and complex queries
    if "(" in q or " and " in q or " or " in q:
        return _parse_complex_query(q)

    # Handle special case: 'value' in field (Google Drive API format)
    # Pattern: 'folder_id' in parents
    # Updated to support nested fields like 'labels/LABEL_ID' in labels
    # Note: NOT operator should be case-insensitive per Google Drive API docs
    in_pattern = r"(?i)(not\s+)?('([^']*)'|\"([^\"]*)\")\s+in\s+(\w+(?:\.\w+)?)"
    in_match = re.search(in_pattern, q)
    if in_match:
        not_prefix = in_match.group(1)
        single_quote_value = in_match.group(3)
        double_quote_value = in_match.group(4)
        field = in_match.group(5)

        # Extract the actual value
        if single_quote_value:
            value = single_quote_value
        elif double_quote_value:
            value = double_quote_value
        else:
            value = None

        if value:
            conditions.append(
                {
                    "type": "condition",
                    "field": field,
                    "operator": "in",
                    "value": value,
                    "negated": bool(not_prefix and not_prefix.strip()),
                }
            )
            return conditions

    # Simple single condition parsing
    # Updated pattern to support <= and >= operators and labels/ID.field format
    # Also support IS NULL, IS NOT NULL, and STARTS WITH operators
    # First check for IS NULL / IS NOT NULL (no value needed)
    is_null_pattern = r"(not\s+)?([\w]+(?:[/\.][\w]+)*)\s+(IS\s+NULL|IS\s+NOT\s+NULL)"
    is_null_match = re.search(is_null_pattern, q, re.IGNORECASE)
    if is_null_match:
        not_prefix = is_null_match.group(1)
        field = is_null_match.group(2)
        operator = (
            is_null_match.group(3).upper().replace(" ", "_")
        )  # "IS NULL" -> "IS_NULL"
        conditions.append(
            {
                "type": "condition",
                "field": field,
                "operator": operator,
                "value": None,  # IS NULL/IS NOT NULL don't have values
                "negated": bool(not_prefix and not_prefix.strip()),
            }
        )
        return conditions

    # Check for STARTS WITH operator
    starts_with_pattern = r"(not\s+)?([\w]+(?:[/\.][\w]+)*)\s+STARTS\s+WITH\s+('([^']*)'|\"([^\"]*)\"|([^'\s]+))"
    starts_with_match = re.search(starts_with_pattern, q, re.IGNORECASE)
    if starts_with_match:
        not_prefix = starts_with_match.group(1)
        field = starts_with_match.group(2)
        single_quote_value = starts_with_match.group(4)
        double_quote_value = starts_with_match.group(5)
        unquoted_value = starts_with_match.group(6)

        if single_quote_value:
            value = single_quote_value
        elif double_quote_value:
            value = double_quote_value
        else:
            value = unquoted_value

        conditions.append(
            {
                "type": "condition",
                "field": field,
                "operator": "starts_with",
                "value": value,
                "negated": bool(not_prefix and not_prefix.strip()),
            }
        )
        return conditions

    # Standard pattern for other operators
    pattern = r"(not\s+)?([\w]+(?:[/\.][\w]+)*)\s*(=|!=|>=|<=|>|<|contains|in|has)\s*('([^']*)'|\"([^\"]*)\"|([^'\s]+))"
    matches = re.findall(pattern, q)

    for match in matches:
        (
            not_prefix,
            field,
            operator,
            full_value,
            single_quote_value,
            double_quote_value,
            unquoted_value,
        ) = match

        # Extract the actual value from the match groups
        if single_quote_value:
            value = single_quote_value
            was_double_quoted = False
        elif double_quote_value:
            value = double_quote_value
            was_double_quoted = True
        else:
            value = unquoted_value
            was_double_quoted = False

        # Convert boolean strings
        if value.lower() in ["true", "false"]:
            value = value.lower() == "true"

        conditions.append(
            {
                "type": "condition",
                "field": field,
                "operator": operator,
                "value": value,
                "negated": bool(not_prefix and not_prefix.strip()),
                "was_double_quoted": was_double_quoted,  # Track if value was originally double-quoted
            }
        )

    return conditions


def _parse_complex_query(q: str) -> List[Dict[str, Any]]:
    """
    Parse complex queries with AND/OR operators and parentheses.
    Handles parentheses by recursively parsing nested expressions.
    """

    def has_balanced_parentheses(s: str) -> bool:
        """Check if string has balanced parentheses"""
        count = 0
        for char in s:
            if char == "(":
                count += 1
            elif char == ")":
                count -= 1
                if count < 0:
                    return False
        return count == 0

    def strip_outer_parentheses(s: str) -> str:
        """Strip outer parentheses only if they're balanced and wrap the entire expression"""
        s = s.strip()
        # Use a loop instead of recursion to avoid infinite recursion
        while s.startswith("(") and s.endswith(")"):
            inner = s[1:-1].strip()
            # Check if inner has balanced parentheses (all parentheses are closed)
            if has_balanced_parentheses(inner):
                s = inner
            else:
                break
        return s

    def parse_simple_query(query_str):
        """Parse a query, handling parentheses properly"""
        conditions = []
        query_str = query_str.strip()

        # Strip outer parentheses
        query_str = strip_outer_parentheses(query_str)

        # Split by ' and ' and ' or ' while preserving the operators
        # But be careful with parentheses - we need to split only at top level
        parts = []
        current_part = ""
        paren_depth = 0
        i = 0

        while i < len(query_str):
            char = query_str[i]

            if char == "(":
                paren_depth += 1
                current_part += char
            elif char == ")":
                paren_depth -= 1
                current_part += char
            elif paren_depth == 0 and query_str[i : i + 5] == " and ":
                if current_part.strip():
                    parts.append(current_part.strip())
                parts.append("and")
                current_part = ""
                i += 4  # Skip " and "
            elif paren_depth == 0 and query_str[i : i + 4] == " or ":
                if current_part.strip():
                    parts.append(current_part.strip())
                parts.append("or")
                current_part = ""
                i += 3  # Skip " or "
            else:
                current_part += char

            i += 1

        if current_part.strip():
            parts.append(current_part.strip())

        if len(parts) == 1:
            # Single condition - no operators found at top level, parse as simple condition
            condition_str = parts[0].strip()
            condition_str = strip_outer_parentheses(condition_str)
            if condition_str:
                condition = _parse_single_condition(condition_str)
                if condition:
                    conditions.append(condition)
        else:
            # Multiple conditions with logical operators
            i = 0
            while i < len(parts):
                if i % 2 == 0:  # Even indices are conditions
                    condition_str = parts[i].strip()
                    condition_str = strip_outer_parentheses(condition_str)
                    if condition_str:
                        # After stripping outer parentheses, if it still has operators,
                        # it means it's a nested expression that needs recursive parsing.
                        # Check if it has operators at top level (outside any remaining parentheses)
                        has_top_level_operators = False
                        paren_depth = 0
                        for idx in range(max(0, len(condition_str) - 4)):
                            if condition_str[idx] == "(":
                                paren_depth += 1
                            elif condition_str[idx] == ")":
                                paren_depth -= 1
                            elif paren_depth == 0:
                                # Check for " and " (5 chars) or " or " (4 chars)
                                if (
                                    idx + 5 <= len(condition_str)
                                    and condition_str[idx : idx + 5] == " and "
                                ):
                                    has_top_level_operators = True
                                    break
                                if (
                                    idx + 4 <= len(condition_str)
                                    and condition_str[idx : idx + 4] == " or "
                                ):
                                    has_top_level_operators = True
                                    break

                        # If it has operators, recursively parse; otherwise parse as simple condition
                        if has_top_level_operators:
                            nested_conditions = _parse_complex_query(condition_str)
                            conditions.extend(nested_conditions)
                        else:
                            condition = _parse_single_condition(condition_str)
                            if condition:
                                conditions.append(condition)
                else:  # Odd indices are logical operators
                    operator = parts[i].strip().lower()
                    if operator in ["and", "or"]:
                        conditions.append({"type": "logical", "operator": operator})
                i += 1

        return conditions

    return parse_simple_query(q)


def _tokenize_query(q: str) -> List[str]:
    """
    Tokenize the query string into individual tokens.
    """
    import re

    # Pattern to match tokens: operators, parentheses, quoted strings, identifiers
    pattern = r"""
        (and|or)                    # Logical operators
        |(\()                       # Opening parenthesis
        |(\))                       # Closing parenthesis
        |(not\s+\w+)               # Not operator with field
        |(\w+\s*(?:=|!=|>|<|contains|in|has)\s*(?:'[^']*'|\"[^\"]*\"|[^'\s]+))  # Conditions
        |(\s+)                     # Whitespace
    """

    tokens = []
    for match in re.finditer(pattern, q, re.VERBOSE):
        token = match.group().strip()
        if token:
            tokens.append(token)

    return tokens


def _parse_tokens(tokens: List[str]) -> Dict[str, Any]:
    """
    Parse tokens into a condition tree.
    """
    # Simple implementation - parse left to right with precedence
    # Higher precedence: parentheses, then AND, then OR

    # First, handle parentheses
    tokens = _handle_parentheses(tokens)

    # Then handle AND operations
    tokens = _handle_logical_operator(tokens, "and")

    # Finally handle OR operations
    tokens = _handle_logical_operator(tokens, "or")

    # Should be left with a single condition
    if len(tokens) == 1:
        return _parse_single_condition(tokens[0])
    else:
        raise ValueError(f"Invalid query structure: {tokens}")


def _handle_parentheses(tokens: List[str]) -> List[str]:
    """
    Handle parentheses by recursively parsing nested expressions.
    """
    result = []
    i = 0

    while i < len(tokens):
        if tokens[i] == "(":
            # Find matching closing parenthesis
            depth = 1
            j = i + 1
            while j < len(tokens) and depth > 0:
                if tokens[j] == "(":
                    depth += 1
                elif tokens[j] == ")":
                    depth -= 1
                j += 1

            if depth == 0:
                # Recursively parse the content inside parentheses
                inner_tokens = tokens[i + 1 : j - 1]
                inner_result = _parse_tokens(inner_tokens)
                result.append(inner_result)
                i = j
            else:
                raise ValueError("Unmatched opening parenthesis")
        else:
            result.append(tokens[i])
            i += 1

    return result


def _handle_logical_operator(tokens: List[str], operator: str) -> List[str]:
    """
    Handle a specific logical operator (and/or) with left associativity.
    """
    result = []
    i = 0

    while i < len(tokens):
        if i + 1 < len(tokens) and tokens[i + 1] == operator:
            # Found the operator
            left = tokens[i]
            op = tokens[i + 1]
            right = tokens[i + 2] if i + 2 < len(tokens) else None

            if right is None:
                raise ValueError(f"Missing right operand for {operator}")

            # Create a logical condition
            logical_condition = {
                "type": "logical",
                "operator": op,
                "left": _parse_single_condition(left)
                if isinstance(left, str)
                else left,
                "right": _parse_single_condition(right)
                if isinstance(right, str)
                else right,
            }

            result.append(logical_condition)
            i += 3
        else:
            result.append(tokens[i])
            i += 1

    return result


def _parse_single_condition(condition_str: str) -> Dict[str, Any]:
    """
    Parse a single condition string into a condition dictionary.
    """
    condition_str = condition_str.strip()

    # First, try to match 'value' in field pattern (for labels, parents, etc.)
    # Note: NOT operator should be case-insensitive per Google Drive API docs
    in_pattern = r"(?i)(not\s+)?('([^']*)'|\"([^\"]*)\")\s+in\s+(\w+(?:\.\w+)?)"
    in_match = re.match(in_pattern, condition_str)
    if in_match:
        not_prefix = in_match.group(1)
        single_quote_value = in_match.group(3)
        double_quote_value = in_match.group(4)
        field = in_match.group(5)

        # Extract the actual value
        if single_quote_value:
            value = single_quote_value
        elif double_quote_value:
            value = double_quote_value
        else:
            value = None

        if value:
            return {
                "type": "condition",
                "field": field,
                "operator": "in",
                "value": value,
                "negated": bool(not_prefix and not_prefix.strip()),
            }

    # Use the existing pattern for single conditions
    # Updated pattern to support <= and >= operators and nested fields like shortcutDetails.targetId
    # Also support labels/LABEL_ID.FIELD pattern (allows / and . in field names)
    # Pattern: allows word chars, slashes, and dots in field names (e.g., labels/ID.field or shortcutDetails.targetId)

    # First check for IS NULL / IS NOT NULL (no value needed)
    is_null_pattern = r"(not\s+)?([\w]+(?:[/\.][\w]+)*)\s+(IS\s+NULL|IS\s+NOT\s+NULL)"
    is_null_match = re.match(is_null_pattern, condition_str, re.IGNORECASE)
    if is_null_match:
        not_prefix = is_null_match.group(1)
        field = is_null_match.group(2)
        operator = (
            is_null_match.group(3).upper().replace(" ", "_")
        )  # "IS NULL" -> "IS_NULL"
        return {
            "type": "condition",
            "field": field,
            "operator": operator,
            "value": None,  # IS NULL/IS NOT NULL don't have values
            "negated": bool(not_prefix and not_prefix.strip()),
        }

    # Check for STARTS WITH operator
    starts_with_pattern = r"(not\s+)?([\w]+(?:[/\.][\w]+)*)\s+STARTS\s+WITH\s+('([^']*)'|\"([^\"]*)\"|([^'\s]+))"
    starts_with_match = re.match(starts_with_pattern, condition_str, re.IGNORECASE)
    if starts_with_match:
        not_prefix = starts_with_match.group(1)
        field = starts_with_match.group(2)
        single_quote_value = starts_with_match.group(4)
        double_quote_value = starts_with_match.group(5)
        unquoted_value = starts_with_match.group(6)

        if single_quote_value:
            value = single_quote_value
        elif double_quote_value:
            value = double_quote_value
        else:
            value = unquoted_value

        return {
            "type": "condition",
            "field": field,
            "operator": "starts_with",
            "value": value,
            "negated": bool(not_prefix and not_prefix.strip()),
        }

    # Standard pattern for other operators
    pattern = r"(not\s+)?([\w]+(?:[/\.][\w]+)*)\s*(=|!=|>=|<=|>|<|contains|in|has)\s*('([^']*)'|\"([^\"]*)\"|([^'\s]+))"
    match = re.match(pattern, condition_str)

    if not match:
        raise ValueError(f"Invalid condition: {condition_str}")

    (
        not_prefix,
        field,
        operator,
        full_value,
        single_quote_value,
        double_quote_value,
        unquoted_value,
    ) = match.groups()

    # Extract the actual value
    if single_quote_value:
        value = single_quote_value
        was_double_quoted = False
    elif double_quote_value:
        value = double_quote_value
        was_double_quoted = True
    else:
        value = unquoted_value
        was_double_quoted = False

    # Convert boolean strings
    if value.lower() in ["true", "false"]:
        value = value.lower() == "true"

    return {
        "type": "condition",
        "field": field,
        "operator": operator,
        "value": value,
        "negated": bool(not_prefix and not_prefix.strip()),
        "was_double_quoted": was_double_quoted,  # Track if value was originally double-quoted
    }


def _flatten_condition_tree(tree: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Flatten a condition tree into a list of conditions with logical operators.
    """
    conditions = []

    if tree["type"] == "condition":
        conditions.append(tree)
    elif tree["type"] == "logical":
        # Add left side
        left_conditions = _flatten_condition_tree(tree["left"])
        conditions.extend(left_conditions)

        # Add logical operator
        conditions.append({"type": "logical", "operator": tree["operator"]})

        # Add right side
        right_conditions = _flatten_condition_tree(tree["right"])
        conditions.extend(right_conditions)

    return conditions


def _build_permission_filter(field: str, value: str, negated: bool, db: Session):
    """
    Build filter condition for permission fields (owners, writers, readers) with group support.

    Examples:
    - 'test@example.org' in owners
    - 'group@example.org' in writers
    """
    from app.models.google_drive_model import GroupMembership

    # Parse comma-separated values
    if isinstance(value, str):
        values = [v.strip() for v in value.split(",")]
    else:
        values = [value]

    # Build subqueries for each permission type
    file_ids = set()

    for val in values:
        # Check direct user permissions
        if field == "owners":
            # Files owned by the user
            user_files = db.query(File.id).filter(File.created_by == val).all()
            file_ids.update([f.id for f in user_files])

        elif field == "writers":
            # Files where user has write permission
            # 1. Direct write permissions
            write_perms = (
                db.query(Permission.file_id)
                .filter(
                    Permission.user_id == val,
                    Permission.role.in_(
                        ["writer", "owner", "organizer", "fileOrganizer"]
                    ),
                )
                .all()
            )
            file_ids.update([p.file_id for p in write_perms])

            # 2. Group write permissions
            group_write_perms = (
                db.query(Permission.file_id)
                .join(GroupMembership)
                .filter(
                    GroupMembership.user_id == val,
                    Permission.type == "group",
                    Permission.role.in_(
                        ["writer", "owner", "organizer", "fileOrganizer"]
                    ),
                )
                .all()
            )
            file_ids.update([p.file_id for p in group_write_perms])

        elif field == "readers":
            # Files where user has read permission
            # 1. Direct read permissions
            read_perms = (
                db.query(Permission.file_id)
                .filter(
                    Permission.user_id == val,
                    Permission.role.in_(
                        [
                            "reader",
                            "commenter",
                            "writer",
                            "owner",
                            "organizer",
                            "fileOrganizer",
                        ]
                    ),
                )
                .all()
            )
            file_ids.update([p.file_id for p in read_perms])

            # 2. Group read permissions
            group_read_perms = (
                db.query(Permission.file_id)
                .join(GroupMembership)
                .filter(
                    GroupMembership.user_id == val,
                    Permission.type == "group",
                    Permission.role.in_(
                        [
                            "reader",
                            "commenter",
                            "writer",
                            "owner",
                            "organizer",
                            "fileOrganizer",
                        ]
                    ),
                )
                .all()
            )
            file_ids.update([p.file_id for p in group_read_perms])

    # Create filter condition
    if file_ids:
        filter_condition = File.id.in_(list(file_ids))
    else:
        # No matching files found
        filter_condition = File.id.in_([])  # Empty set

    # Apply negation if needed
    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _build_shared_with_me_filter(value: str, negated: bool, db: Session):
    """
    Build filter condition for sharedWithMe field.

    Examples:
    - sharedWithMe = true
    - sharedWithMe and name contains 'hello'
    """

    # For sharedWithMe, we need to find files that are shared with the current user
    # This is a complex query that would need the current user context
    # For now, we'll implement a simplified version
    # Get files that have permissions (indicating they're shared)
    shared_file_ids = db.query(Permission.file_id).distinct().all()
    shared_file_ids = [p.file_id for p in shared_file_ids]

    # Also include files where user is not the owner but has access
    # This is a simplified implementation - in reality, we'd need the current user context

    if shared_file_ids:
        filter_condition = File.id.in_(shared_file_ids)
    else:
        filter_condition = File.id.in_([])  # Empty set

    # Apply negation if needed
    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _build_shortcut_target_filter(
    value: str, operator: str, negated: bool, db: Session
):
    """
    Build filter condition for shortcutDetails.targetId field.

    Examples:
    - shortcutDetails.targetId = 'file_id'
    - shortcutDetails.targetId != 'file_id'
    """
    if operator == "=":
        filter_condition = File.shortcut_target_id == value
    elif operator == "!=":
        filter_condition = File.shortcut_target_id != value
    else:
        logger.warning(
            f"Unsupported operator '{operator}' for shortcutDetails.targetId"
        )
        return None

    # Also ensure the file is actually a shortcut
    filter_condition = and_(File.is_shortcut == True, filter_condition)

    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _build_visibility_filter(value: str, operator: str, negated: bool, db: Session):
    """
    Build filter condition for visibility field.

    Valid values: 'anyoneCanFind', 'anyoneWithLink', 'domainCanFind', 'domainWithLink', 'limited'

    The visibility is computed based on permissions:
    - 'limited': File has specific user/group permissions (not public)
    - 'anyoneWithLink': File has 'anyoneWithLink' permission
    - 'anyoneCanFind': File has 'anyone' permission with allow_file_discovery=True
    - 'domainWithLink': File has domain permission with link sharing
    - 'domainCanFind': File has domain permission with discovery enabled

    For now, we'll use a simplified implementation based on the shared field and permissions.
    """
    if operator not in ["=", "!="]:
        logger.warning(f"Unsupported operator '{operator}' for visibility field")
        return None

    # Get file IDs matching the visibility criteria
    matching_file_ids = set()

    if value == "limited":
        # Files that are not publicly shared (no 'anyone' or 'anyoneWithLink' permissions)
        all_files = db.query(File.id).all()
        public_file_ids = (
            db.query(Permission.file_id)
            .filter(
                or_(
                    Permission.type == "anyone",
                    and_(
                        Permission.type == "anyone",
                        Permission.role.in_(["reader", "writer", "commenter"]),
                    ),
                )
            )
            .distinct()
            .all()
        )
        public_file_ids_set = {p.file_id for p in public_file_ids}
        matching_file_ids = {f.id for f in all_files if f.id not in public_file_ids_set}
    elif value == "anyoneWithLink":
        # Files with 'anyoneWithLink' permission
        public_files = (
            db.query(Permission.file_id)
            .filter(Permission.type == "anyone")
            .distinct()
            .all()
        )
        matching_file_ids = {p.file_id for p in public_files}
    elif value == "anyoneCanFind":
        # Files with 'anyone' permission and allow_file_discovery=True
        discoverable_files = (
            db.query(Permission.file_id)
            .filter(
                Permission.type == "anyone", Permission.allow_file_discovery == True
            )
            .distinct()
            .all()
        )
        matching_file_ids = {p.file_id for p in discoverable_files}
    elif value in ["domainWithLink", "domainCanFind"]:
        # Files with domain permissions
        domain_files = (
            db.query(Permission.file_id)
            .filter(Permission.type == "domain")
            .distinct()
            .all()
        )
        matching_file_ids = {p.file_id for p in domain_files}
    else:
        logger.warning(f"Unknown visibility value: {value}")
        return None

    if matching_file_ids:
        filter_condition = File.id.in_(list(matching_file_ids))
    else:
        filter_condition = File.id.in_([])  # Empty set

    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _build_labels_in_filter(value: str, negated: bool, db: Session):
    """
    Build filter for 'labels/LABEL_ID' in labels query.

    Args:
        value: The label ID (e.g., 'labels/01JBQM3K8TGHZX9RNVQM5Y2P9U' or '01JBQM3K8TGHZX9RNVQM5Y2P9U')
        negated: Whether the condition is negated
        db: Database session

    Returns:
        SQLAlchemy filter condition
    """
    # Extract label ID from value (may be 'labels/LABEL_ID' or just 'LABEL_ID')
    label_id = value
    if label_id.startswith("labels/"):
        label_id = label_id[7:]  # Remove 'labels/' prefix

    # Query files that have this label
    # Use exists() subquery to check if file has the label
    subquery = exists().where(
        and_(FileLabel.file_id == File.id, FileLabel.label_id == label_id)
    )

    filter_condition = subquery

    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _build_labels_field_filter(
    field: str, operator: str, value: Any, negated: bool, db: Session
):
    """
    Build filter for labels/LABEL_ID.FIELD = value query.

    Args:
        field: The field path (e.g., 'labels/01JBQM3K8TGHZX9RNVQM5Y2P9U.priority')
        operator: The operator (=, !=, <, >, <=, >=, IS_NULL, IS_NOT_NULL, starts_with)
        value: The value to compare (None for IS NULL / IS NOT NULL)
        negated: Whether the condition is negated
        db: Database session

    Returns:
        SQLAlchemy filter condition
    """
    from datetime import datetime

    from app.models.google_drive_model import Label, LabelType

    # Parse field: labels/LABEL_ID.FIELD_NAME
    # Example: labels/01JBQM3K8TGHZX9RNVQM5Y2P9U.priority
    parts = field.split("/")
    if len(parts) != 2:
        logger.warning(f"Invalid labels field format: {field}")
        return None

    label_part = parts[1]  # LABEL_ID.FIELD_NAME
    if "." not in label_part:
        logger.warning(f"Invalid labels field format (missing field name): {field}")
        return None

    label_id, field_name = label_part.split(".", 1)

    # Look up the label from database to determine the actual field type
    label = db.query(Label).filter(Label.id == label_id).first()
    if not label:
        logger.warning(f"Label not found: {label_id}")
        return None

    label_type = label.type  # LabelType enum: string, number, boolean, date, enum

    # Handle IS NULL / IS NOT NULL operators (no value needed)
    if operator in ["IS_NULL", "IS_NOT_NULL"]:
        base_condition = and_(
            FileLabel.file_id == File.id, FileLabel.label_id == label_id
        )

        # Determine which value column to check for NULL based on label type
        if label_type == LabelType.boolean:
            value_column = FileLabel.value_boolean
        elif label_type == LabelType.number:
            value_column = FileLabel.value_number
        elif label_type == LabelType.date:
            value_column = FileLabel.value_date
        elif label_type == LabelType.enum:
            value_column = FileLabel.value_enum
        else:  # string
            value_column = FileLabel.value_string

        if operator == "IS_NULL":
            value_condition = value_column.is_(None)
        else:  # IS_NOT_NULL
            value_condition = value_column.isnot(None)

        subquery_condition = and_(base_condition, value_condition)
        filter_condition = exists(
            select(1).select_from(FileLabel).where(subquery_condition)
        )

        if negated:
            filter_condition = ~filter_condition

        return filter_condition

    # Convert value to appropriate type based on label type
    # This is critical because values come as strings from the query parser
    if value is not None:
        if label_type == LabelType.boolean:
            if isinstance(value, str) and value.lower() in ["true", "false"]:
                value = value.lower() == "true"
            elif not isinstance(value, bool):
                logger.warning(f"Invalid boolean value for label field: {value}")
                return None
        elif label_type == LabelType.number:
            # Convert string to number
            if isinstance(value, str):
                try:
                    # Try int first, then float
                    if "." in value:
                        value = float(value)
                    else:
                        value = int(value)
                except ValueError:
                    logger.warning(f"Invalid numeric value for label field: {value}")
                    return None
            elif not isinstance(value, (int, float)):
                logger.warning(
                    f"Invalid numeric value type for label field: {type(value)}"
                )
                return None
        elif label_type == LabelType.date:
            # Convert string to datetime
            # Note: value_date is stored as DateTime in the database
            if isinstance(value, str):
                try:
                    # Parse date string (format: YYYY-MM-DD) and convert to datetime
                    # Use midnight as the time component for date comparisons
                    value = datetime.strptime(value, "%Y-%m-%d")
                except ValueError:
                    logger.warning(
                        f"Invalid date value for label field: {value}. Expected format: YYYY-MM-DD"
                    )
                    return None
            elif isinstance(value, datetime):
                # Already a datetime, use as is
                pass
            else:
                logger.warning(
                    f"Invalid date value type for label field: {type(value)}"
                )
                return None

    # Build the base condition
    base_condition = and_(FileLabel.file_id == File.id, FileLabel.label_id == label_id)

    # Build value condition based on label type and operator
    if label_type == LabelType.boolean:
        # Boolean value - check value_boolean column
        if operator == "=":
            value_condition = and_(
                FileLabel.value_boolean.isnot(None), FileLabel.value_boolean == value
            )
        elif operator == "!=":
            value_condition = or_(
                FileLabel.value_boolean.is_(None), FileLabel.value_boolean != value
            )
        else:
            logger.warning(f"Unsupported operator for boolean labels field: {operator}")
            return None
        subquery_condition = and_(base_condition, value_condition)

    elif label_type == LabelType.number:
        # Numeric value - check value_number column
        if operator == "=":
            value_condition = and_(
                FileLabel.value_number.isnot(None), FileLabel.value_number == value
            )
        elif operator == "!=":
            value_condition = or_(
                FileLabel.value_number.is_(None), FileLabel.value_number != value
            )
        elif operator == "<":
            value_condition = and_(
                FileLabel.value_number.isnot(None), FileLabel.value_number < value
            )
        elif operator == ">":
            value_condition = and_(
                FileLabel.value_number.isnot(None), FileLabel.value_number > value
            )
        elif operator == "<=":
            value_condition = and_(
                FileLabel.value_number.isnot(None), FileLabel.value_number <= value
            )
        elif operator == ">=":
            value_condition = and_(
                FileLabel.value_number.isnot(None), FileLabel.value_number >= value
            )
        else:
            logger.warning(f"Unsupported operator for numeric labels field: {operator}")
            return None
        subquery_condition = and_(base_condition, value_condition)

    elif label_type == LabelType.date:
        # Date value - check value_date column
        # SQLAlchemy handles datetime comparisons correctly with SQLite
        # The value is already converted to datetime object above
        if operator == "=":
            value_condition = and_(
                FileLabel.value_date.isnot(None), FileLabel.value_date == value
            )
        elif operator == "!=":
            value_condition = or_(
                FileLabel.value_date.is_(None), FileLabel.value_date != value
            )
        elif operator == "<":
            value_condition = and_(
                FileLabel.value_date.isnot(None), FileLabel.value_date < value
            )
        elif operator == ">":
            value_condition = and_(
                FileLabel.value_date.isnot(None), FileLabel.value_date > value
            )
        elif operator == "<=":
            value_condition = and_(
                FileLabel.value_date.isnot(None), FileLabel.value_date <= value
            )
        elif operator == ">=":
            # For >= with dates in SQLite, use date() function to normalize
            # SQLite stores dates as strings, so we need to extract just the date part
            # Convert the datetime value to a string in ISO format (YYYY-MM-DD)
            value_str = value.strftime("%Y-%m-%d")
            # Use SQLite's date() function to extract date part and compare as strings
            value_condition = and_(
                FileLabel.value_date.isnot(None),
                func.date(FileLabel.value_date) >= value_str,
            )
        else:
            logger.warning(f"Unsupported operator for date labels field: {operator}")
            return None
        subquery_condition = and_(base_condition, value_condition)

    elif label_type in [LabelType.string, LabelType.enum]:
        # String or enum value - check value_string and value_enum columns
        if operator == "=":
            value_condition = or_(
                FileLabel.value_enum == value, FileLabel.value_string == value
            )
        elif operator == "!=":
            value_condition = ~or_(
                FileLabel.value_enum == value, FileLabel.value_string == value
            )
        elif operator == "starts_with":
            # STARTS WITH operator for text fields
            # Use LIKE with prefix pattern
            value_condition = or_(
                FileLabel.value_enum.like(f"{value}%"),
                FileLabel.value_string.like(f"{value}%"),
            )
        else:
            logger.warning(
                f"Unsupported operator for string/enum labels field: {operator}"
            )
            return None
        subquery_condition = and_(base_condition, value_condition)

    else:
        logger.warning(f"Unsupported label type: {label_type}")
        return None

    # Create a properly scoped exists subquery
    # Use select().select_from() to explicitly specify FileLabel table
    # The File.id reference in base_condition will automatically correlate the subquery
    filter_condition = exists(
        select(1).select_from(FileLabel).where(subquery_condition)
    )

    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _build_fulltext_filter(
    value: str, negated: bool, db: Session, was_double_quoted: bool = False
):
    """
    Build filter condition for fullText search.

    Searches across: name, description, indexableText (if available).

    Per Google Drive API docs:
    - Single words: matches entire tokens only (not substrings)
    - Double-quoted phrases: exact phrase matching with underscore normalization
    - Single-quoted phrases: matches individual tokens (no underscore normalization)

    Examples:
    - 'hello' matches token "hello" but not "HelloWorld"
    - '"Hello world"' matches "Hello world" and "Hello_world" (underscore normalization)
    - 'Hello world' matches files with both "Hello" and "world" tokens (no underscore normalization)
    """
    has_spaces = " " in value

    if has_spaces:
        if was_double_quoted:
            # Double-quoted: exact phrase with underscore normalization
            # Per API docs: underscores treated as spaces in alphanumeric matching
            phrase_with_spaces = value
            phrase_with_underscores = value.replace(" ", "_")

            filter_condition = or_(
                File.name.ilike(f"%{phrase_with_spaces}%"),
                File.name.ilike(f"%{phrase_with_underscores}%"),
                and_(
                    File.description.isnot(None),
                    or_(
                        File.description.ilike(f"%{phrase_with_spaces}%"),
                        File.description.ilike(f"%{phrase_with_underscores}%"),
                    ),
                ),
            )
        else:
            # Single-quoted: match individual tokens (no underscore normalization)
            tokens = value.split()
            conditions = []
            for token in tokens:
                token_escaped = (
                    token.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
                )

                # Match complete tokens only (word boundaries)
                token_conditions = [
                    # Token at start
                    or_(
                        File.name.ilike(f"{token_escaped} %"),
                        File.name.ilike(token_escaped),
                        and_(
                            File.description.isnot(None),
                            or_(
                                File.description.ilike(f"{token_escaped} %"),
                                File.description.ilike(token_escaped),
                            ),
                        ),
                    ),
                    # Token in middle
                    or_(
                        File.name.ilike(f"% {token_escaped} %"),
                        and_(
                            File.description.isnot(None),
                            File.description.ilike(f"% {token_escaped} %"),
                        ),
                    ),
                    # Token at end
                    or_(
                        File.name.ilike(f"% {token_escaped}"),
                        and_(
                            File.description.isnot(None),
                            File.description.ilike(f"% {token_escaped}"),
                        ),
                    ),
                ]
                conditions.append(or_(*token_conditions))

            filter_condition = and_(*conditions) if conditions else File.id.in_([])
    else:
        # Single word: match complete token only (not substring)
        # Per API docs: 'Important' matches "Important Notes.txt" but 'portant' does not
        term_escaped = (
            value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
        )

        # Match token at word boundaries (start, middle, end, or exact match)
        filter_condition = or_(
            File.name.ilike(f"{term_escaped} %"),
            File.name.ilike(f"% {term_escaped} %"),
            File.name.ilike(f"% {term_escaped}"),
            File.name.ilike(term_escaped),
            and_(
                File.description.isnot(None),
                or_(
                    File.description.ilike(f"{term_escaped} %"),
                    File.description.ilike(f"% {term_escaped} %"),
                    File.description.ilike(f"% {term_escaped}"),
                    File.description.ilike(term_escaped),
                ),
            ),
        )

    if negated:
        filter_condition = ~filter_condition

    return filter_condition


def _apply_user_file_access_filter(query, user: User, db: Session):
    """
    Apply filter to only include files that the user has access to.
    Checks both direct permissions and group memberships.
    """
    from app.models.google_drive_model import DriveMembership, GroupMembership

    # Get file IDs that user has access to through various means
    accessible_file_ids = set()

    # 1. Files owned by the user
    owned_files = db.query(File.id).filter(File.created_by == user.id).all()
    accessible_file_ids.update([f.id for f in owned_files])

    # 2. Files with direct user permissions
    direct_permissions = (
        db.query(Permission.file_id).filter(Permission.user_id == user.id).all()
    )
    accessible_file_ids.update([p.file_id for p in direct_permissions])

    # 3. Files with group permissions where user is a member
    group_permissions = (
        db.query(Permission.file_id)
        .join(GroupMembership, Permission.group_id == GroupMembership.group_id)
        .filter(GroupMembership.user_id == user.id, Permission.type == "group")
        .all()
    )
    accessible_file_ids.update([p.file_id for p in group_permissions])

    # 4. Files in drives where user has membership (basic read access)
    user_drives = (
        db.query(DriveMembership.drive_id)
        .filter(DriveMembership.user_id == user.id)
        .all()
    )
    drive_ids = [d.drive_id for d in user_drives]

    if drive_ids:
        drive_files = db.query(File.id).filter(File.drive_id.in_(drive_ids)).all()
        accessible_file_ids.update([f.id for f in drive_files])

    # Filter query to only include accessible files
    if accessible_file_ids:
        return query.filter(File.id.in_(list(accessible_file_ids)))
    else:
        # User has no access to any files
        return query.filter(File.id.in_([]))  # Empty set


def _get_user_file_permission(user: User, file: File, db: Session) -> str:
    """
    Get user's permission level for a file (owner, writer, reader, etc.).
    Checks both direct permissions and group memberships.
    """
    from app.models.google_drive_model import GroupMembership

    # Check if user is the file owner
    if file.created_by == user.id:
        return "owner"

    # Check direct permissions
    permission = (
        db.query(Permission)
        .filter(Permission.file_id == file.id, Permission.user_id == user.id)
        .first()
    )

    if permission:
        return permission.role

    # Check group permissions
    group_permissions = (
        db.query(Permission)
        .filter(Permission.file_id == file.id, Permission.type == "group")
        .all()
    )

    for group_permission in group_permissions:
        # Check if user is a member of this group
        group_membership = (
            db.query(GroupMembership)
            .filter(
                GroupMembership.group_id == group_permission.group_id,
                GroupMembership.user_id == user.id,
            )
            .first()
        )

        if group_membership:
            return group_permission.role

    # Check drive membership (basic read access)
    from app.models.google_drive_model import DriveMembership

    drive_membership = (
        db.query(DriveMembership)
        .filter(
            DriveMembership.drive_id == file.drive_id,
            DriveMembership.user_id == user.id,
        )
        .first()
    )

    if drive_membership:
        return "reader"  # Basic read access through drive membership

    return "none"  # No access


def _build_file_capabilities(
    user: User, file: File, permission_level: str, db: Session
) -> dict:
    """
    Build capabilities object based on user's actual permission level for the file.
    Only includes implemented capabilities.
    """
    is_folder = file.mime_type == "application/vnd.google-apps.folder"
    is_owner = permission_level == "owner"
    is_writer = permission_level in ["writer", "owner", "organizer", "fileOrganizer"]
    is_reader = permission_level in [
        "reader",
        "commenter",
        "writer",
        "owner",
        "organizer",
        "fileOrganizer",
    ]

    capabilities = {}

    # Only add capabilities that are actually implemented and meaningful
    if is_folder:
        if is_writer:
            capabilities["canAddChildren"] = True
            capabilities["canRemoveChildren"] = True
            capabilities["canMoveChildrenWithinDrive"] = True
        if is_reader:
            capabilities["canListChildren"] = True

    if is_writer:
        capabilities["canEdit"] = True
        capabilities["canModifyContent"] = True
        capabilities["canRename"] = True
        capabilities["canShare"] = True
        capabilities["canTrash"] = True
        capabilities["canUntrash"] = True
        capabilities["canMoveItemWithinDrive"] = True

    if is_reader:
        capabilities["canCopy"] = True
        capabilities["canComment"] = True
        capabilities["canReadRevisions"] = True
        capabilities["canViewerCopy"] = True

    if not is_folder and is_reader:
        capabilities["canDownload"] = True

    if is_owner:
        capabilities["canDelete"] = True
        capabilities["canChangeCopyRequiresWriterPermission"] = True
        capabilities["canChangeViewersCanCopyContent"] = True

    return capabilities


def _build_property_has_filter(field: str, value: str, negated: bool, db: Session):
    """
    Build filter condition for properties/appProperties with has operator.

    Examples:
    - properties has { key='mass' and value='1.3kg' }
    - appProperties has { key='additionalID' and value='8e8aceg2af2ge72e78' }
    """
    import json

    # Parse the property condition
    # Expected format: { key='mass' and value='1.3kg' }
    try:
        # Remove curly braces and parse the condition
        condition_str = value.strip("{}")

        # Simple parsing for key=value pairs
        # This is a basic implementation - could be enhanced for complex conditions
        if " and " in condition_str:
            parts = condition_str.split(" and ")
            key_part = None
            value_part = None

            for part in parts:
                part = part.strip()
                if part.startswith("key="):
                    key_part = part.split("=", 1)[1].strip("'\"")
                elif part.startswith("value="):
                    value_part = part.split("=", 1)[1].strip("'\"")

            if key_part and value_part:
                # Search in properties JSON field
                if field == "properties":
                    # Look for files where properties JSON contains the key-value pair
                    filter_condition = File.properties.contains(
                        json.dumps({key_part: value_part})
                    )
                elif field == "appProperties":
                    # For now, treat appProperties the same as properties
                    filter_condition = File.properties.contains(
                        json.dumps({key_part: value_part})
                    )
                else:
                    return None

                # Apply negation if needed
                if negated:
                    filter_condition = ~filter_condition

                return filter_condition
        else:
            # Simple key=value format
            if "=" in condition_str:
                key, val = condition_str.split("=", 1)
                key = key.strip()
                val = val.strip().strip("'\"")

                if field == "properties":
                    filter_condition = File.properties.contains(json.dumps({key: val}))
                elif field == "appProperties":
                    filter_condition = File.properties.contains(json.dumps({key: val}))
                else:
                    return None

                # Apply negation if needed
                if negated:
                    filter_condition = ~filter_condition

                return filter_condition

    except Exception as e:
        logger.warning(f"Error parsing property condition '{value}': {e}")
        return None

    return None


logger = logging.getLogger(__name__)


def _get_user_my_drive_root_folder(db: Session, user: User) -> Optional[str]:
    """
    Get the user's My Drive root folder ID.
    In Google Drive, the root folder is represented by NULL parent_id and empty parent_ids.

    Args:
        db: Database session
        user: The user

    Returns:
        str: The root folder ID (None for root), or None if no My Drive available
    """
    # Get user's drive membership
    from app.models.google_drive_model import DriveMembership

    user_drive_membership = (
        db.query(DriveMembership.drive_id)
        .filter(DriveMembership.user_id == user.id)
        .first()
    )

    if user_drive_membership:
        # drive_id = user_drive_membership.drive_id
        # Return None to represent root folder (files with parent_id=None are in root)
        return None
    else:
        # Fallback: get any available drive
        drive = db.query(Drive).filter(not Drive.hidden).first()
        if drive:
            return None  # Root folder
        else:
            return None


def _generate_unique_filename(
    db: Session, desired_name: str, parent_id: Optional[str]
) -> str:
    """
    Generate a unique filename by appending a number suffix if conflicts exist.

    Args:
        db: Database session
        desired_name: The desired filename
        parent_id: The parent folder ID (None for root folder)

    Returns:
        str: A unique filename
    """
    # Check if the desired name already exists in the parent folder
    existing_file = (
        db.query(File)
        .filter(
            File.name == desired_name,
            File.parent_id == parent_id,
            File.trashed == False,
        )
        .first()
    )

    if not existing_file:
        return desired_name

    # Extract name and extension
    if "." in desired_name:
        name_part, extension = desired_name.rsplit(".", 1)
        extension = "." + extension
    else:
        name_part = desired_name
        extension = ""

    # Try appending numbers until we find a unique name
    counter = 1
    while True:
        new_name = f"{name_part} ({counter}){extension}"

        existing_file = (
            db.query(File)
            .filter(
                File.name == new_name,
                File.parent_id == parent_id,
                File.trashed == False,
            )
            .first()
        )

        if not existing_file:
            return new_name

        counter += 1

        # Safety check to prevent infinite loops
        if counter > 1000:
            # Fallback to using timestamp
            timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
            return f"{name_part} ({timestamp}){extension}"


files_router = APIRouter(tags=["Google Drive Files"])


@files_router.get("/files", response_model=FilesListResponse)
def list_files(
    request: Request,
    params: FilesListQueryParams = Query(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
) -> FilesListResponse:
    """Lists the user's files with filtering, pagination, and search capabilities"""
    try:
        logger.info(f"Listing files for user with corpora: {params.corpora}")

        # Validate driveId parameter - must be used with corpora="drive"
        if params.driveId and params.corpora != "drive":
            raise HTTPException(
                status_code=400,
                detail="driveId parameter can only be used when corpora='drive'. "
                "To search a specific shared drive, set corpora='drive' and provide the driveId.",
            )

        # Validate includePermissionsForView parameter
        if (
            params.includePermissionsForView is not None
            and params.includePermissionsForView.strip().lower() != "published"
        ):
            raise HTTPException(
                status_code=400,
                detail="includePermissionsForView only supports 'published' value",
            )

        # Validate includeLabels parameter - check if label IDs exist in database
        if params.includeLabels is not None:
            include_labels = params.includeLabels.strip()
            if include_labels:
                label_ids = [label_id.strip() for label_id in include_labels.split(",")]
                for label_id in label_ids:
                    if label_id:
                        # Check if label exists in database
                        label = db.query(Label).filter(Label.id == label_id).first()
                        if not label:
                            raise HTTPException(
                                status_code=400,
                                detail=f"Invalid label ID '{label_id}'. Label does not exist in the system.",
                            )

        # Validate spaces parameter
        if params.spaces:
            space_list = [s.strip() for s in params.spaces.split(",") if s.strip()]
            supported_spaces = {"drive", "appDataFolder"}
            invalid_spaces = set(space_list) - supported_spaces
            if invalid_spaces:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid space values: {', '.join(invalid_spaces)}. Supported values are: 'drive' and 'appDataFolder'",
                )

        # Build the base query
        query = db.query(File)

        # Apply corpora filter with proper permission checking
        # Handle includeItemsFromAllDrives: when True and corpora="user", include shared drive items
        if params.corpora == "user":
            if params.includeItemsFromAllDrives:
                # Include both My Drive (user's files) and shared drive items
                # My Drive files: created_by == current_user.id
                # Shared drive files: accessible via permissions
                query = query.filter(
                    or_(
                        File.created_by == current_user.id,
                        # Files in shared drives where user has access
                        File.drive_id.isnot(None),
                    )
                )
                # Apply permission filter for shared drive items
                query = _apply_user_file_access_filter(query, current_user, db)
            else:
                # Files owned by the current user (using created_by as owner)
                query = query.filter(File.created_by == current_user.id)
        elif params.corpora == "drive" and params.driveId:
            # Files in a specific shared drive - check user has access to drive
            query = query.filter(File.drive_id == params.driveId)
            # Additional check: user must have access to files in this drive
            query = _apply_user_file_access_filter(query, current_user, db)
        elif params.corpora == "domain":
            # Files shared to the user's domain
            # Get user's domain from email
            if not current_user.email or "@" not in current_user.email:
                # User has no domain, return empty result
                query = query.filter(False)
            else:
                user_domain = current_user.email.split("@")[1]

                # Get file IDs with domain permissions for this domain
                domain_permission_files = (
                    db.query(Permission.file_id)
                    .filter(
                        Permission.type == "domain",
                        Permission.domain == user_domain,
                        Permission.deleted == False,
                        Permission.file_id.isnot(None),
                    )
                    .all()
                )
                domain_file_ids = [p.file_id for p in domain_permission_files]

                # Filter query to only include files with domain permissions
                if domain_file_ids:
                    query = query.filter(File.id.in_(domain_file_ids))
                    # Apply user access filter to ensure user has permission to access these files
                    query = _apply_user_file_access_filter(query, current_user, db)
                else:
                    # No files with domain permissions for this domain
                    query = query.filter(False)
        elif params.corpora == "allDrives":
            # All drives accessible to the user - check file permissions
            query = _apply_user_file_access_filter(query, current_user, db)
        else:
            # Default: only files user has access to
            query = _apply_user_file_access_filter(query, current_user, db)

        # Apply spaces filter
        if params.spaces:
            space_list = [s.strip() for s in params.spaces.split(",") if s.strip()]
            # Filter files by space field
            if len(space_list) == 1:
                # Single space requested - filter to that space only
                query = query.filter(File.space == space_list[0])
            elif len(space_list) == 2:
                # Both spaces requested - filter to files in either space
                query = query.filter(File.space.in_(space_list))
            # If empty or invalid, no filtering (shouldn't happen due to validation)

        # Apply trashed filter
        if params.trashed is not None:
            query = query.filter(File.trashed == params.trashed)
        elif params.trashed is None:
            # Default behavior: include trashed files unless explicitly filtered out
            pass

        # Apply search query (q parameter) - Google Drive API compliant
        if params.q:
            query = _apply_google_drive_query(query, params.q, db)

        # Apply ordering
        if params.orderBy:
            order_clauses = []
            for order_item in params.orderBy.split(","):
                order_item = order_item.strip()
                if order_item.endswith(" desc"):
                    field = order_item[:-5].strip()
                    desc = True
                else:
                    field = order_item.strip()
                    desc = False

                # Map Google Drive API order fields to database fields
                if field == "createdTime":
                    order_clauses.append(
                        File.created_time.desc() if desc else File.created_time.asc()
                    )
                elif field == "modifiedTime":
                    order_clauses.append(
                        File.modified_time.desc() if desc else File.modified_time.asc()
                    )
                elif field == "modifiedByMeTime":
                    # Since we don't have this field, use modified_time
                    order_clauses.append(
                        File.modified_time.desc() if desc else File.modified_time.asc()
                    )
                elif field == "name":
                    order_clauses.append(File.name.desc() if desc else File.name.asc())
                elif field == "name_natural":
                    order_clauses.append(File.name.desc() if desc else File.name.asc())
                elif field == "quotaBytesUsed":
                    order_clauses.append(
                        File.size_bytes.desc() if desc else File.size_bytes.asc()
                    )
                elif field == "viewedByMeTime":
                    order_clauses.append(
                        File.viewed_by_me_time.desc()
                        if desc
                        else File.viewed_by_me_time.asc()
                    )
                elif field == "starred":
                    order_clauses.append(
                        File.starred.desc() if desc else File.starred.asc()
                    )
                elif field == "recency":
                    # Use the most recent of created_time and modified_time
                    order_clauses.append(
                        File.modified_time.desc() if desc else File.modified_time.asc()
                    )
                elif field == "folder":
                    # For folder ordering, we'd need parent_id logic
                    order_clauses.append(
                        File.parent_id.desc() if desc else File.parent_id.asc()
                    )

            if order_clauses:
                query = query.order_by(*order_clauses)
        else:
            # Default ordering by modified time descending
            query = query.order_by(File.modified_time.desc())

        # Handle pagination
        offset = 0
        if params.pageToken:
            try:
                offset = int(params.pageToken)
            except ValueError:
                raise HTTPException(status_code=400, detail="Invalid page_token format")

        # Get files with pagination
        files = query.offset(offset).limit(params.pageSize + 1).all()

        # Check if there are more results
        has_next_page = len(files) > params.pageSize
        if has_next_page:
            files = files[: params.pageSize]
            next_page_token = str(offset + params.pageSize)
        else:
            next_page_token = None

        # Convert files to response format
        file_list: List[FileResponse] = []
        for file in files:
            # Get owner information
            owner = db.query(User).filter(User.id == file.created_by).first()

            # Get last modifying user information
            last_modifying_user = None
            if file.modified_by:
                last_modifying_user = (
                    db.query(User).filter(User.id == file.modified_by).first()
                )

            # Build file response with only implemented fields
            file_data = {
                "id": file.id,
                "name": file.name,
                "mimeType": file.mime_type,
                # PATCH(drive/list_files): seed rows leave these boolean columns NULL, and
                # FileResponse declares them as strict `bool` (no default), so a None here raised
                # a ValidationError -> HTTP 500 that masked list_files entirely. Coerce None->False
                # (the Google Drive default for each), mirroring the bool() coercion the get_file
                # path already applies at file_response["trashed"/"shared"/...] below.
                "starred": bool(file.starred),
                "trashed": bool(file.trashed),
                "createdTime": file.created_time.isoformat() + "Z"
                if file.created_time
                else None,
                "modifiedTime": file.modified_time.isoformat() + "Z"
                if file.modified_time
                else None,
                "shared": bool(file.shared),
                "ownedByMe": file.created_by == current_user.id,
                "size": str(file.size_bytes) if file.size_bytes else "0",
                "kind": "drive#file",
            }

            # Add optional fields only if they have meaningful values
            if file.description:
                file_data["description"] = file.description

            if file.explicitly_trashed:
                file_data["explicitlyTrashed"] = file.explicitly_trashed

            # Use parent_ids (JSON array) if available, otherwise fall back to parent_id
            if (
                file.parent_ids
                and isinstance(file.parent_ids, list)
                and len(file.parent_ids) > 0
            ):
                file_data["parents"] = file.parent_ids
            elif file.parent_id:
                file_data["parents"] = [file.parent_id]
            else:
                file_data["parents"] = []

            if file.version and file.version != 1:
                file_data["version"] = str(file.version)

            if file.web_content_link:
                file_data["webContentLink"] = file.web_content_link

            if file.web_view_link:
                file_data["webViewLink"] = file.web_view_link

            if file.icon_link:
                file_data["iconLink"] = file.icon_link

            if file.thumbnail_link:
                file_data["thumbnailLink"] = file.thumbnail_link

            # Compute viewedByMe from database: user has viewed if they created or modified the file
            viewed_by_me = (
                file.created_by == current_user.id
                or file.modified_by == current_user.id
            )

            # If user didn't create/modify, check if they have any revisions (they would have viewed it)
            # This is a fallback - if they created/modified, we already know they viewed it
            if not viewed_by_me:
                has_user_revision = (
                    db.query(Revision)
                    .filter(
                        Revision.file_id == file.id,
                        Revision.last_modifying_user_id == current_user.id,
                    )
                    .first()
                    is not None
                )
                viewed_by_me = has_user_revision

            if viewed_by_me:
                file_data["viewedByMe"] = True
                # Use modified_time as viewedByMeTime if user modified it, otherwise created_time
                if file.modified_by == current_user.id and file.modified_time:
                    file_data["viewedByMeTime"] = file.modified_time.isoformat() + "Z"
                elif file.created_by == current_user.id and file.created_time:
                    file_data["viewedByMeTime"] = file.created_time.isoformat() + "Z"
            else:
                file_data["viewedByMe"] = False

            file_data["modifiedByMe"] = file.modified_by == current_user.id

            if file.md5_checksum:
                file_data["md5Checksum"] = file.md5_checksum

            if file.sha1_checksum:
                file_data["sha1Checksum"] = file.sha1_checksum

            if file.head_revision_id:
                file_data["headRevisionId"] = file.head_revision_id

            if file.quota_bytes_used and file.quota_bytes_used != 0:
                file_data["quotaBytesUsed"] = str(file.quota_bytes_used)

            # Add shortcut fields if file is a shortcut
            if file.is_shortcut:
                file_data["isShortcut"] = True
                if file.shortcut_target_id:
                    file_data["shortcutDetails"] = {
                        "targetId": file.shortcut_target_id,
                        "targetMimeType": file.shortcut_target_mime,
                    }

            if file.properties:
                file_data["properties"] = file.properties

            if file.app_properties:
                file_data["appProperties"] = file.app_properties

            # Add owner information according to Google Drive API User resource specification
            if owner:
                file_data["owners"] = [
                    FileUser(
                        kind="drive#user",
                        displayName=owner.display_name,
                        photoLink=owner.photo_url,
                        me=owner.id == current_user.id,
                        permissionId=owner.id,
                        emailAddress=owner.email,
                    )
                ]

            # Add last modifying user information
            if last_modifying_user:
                file_data["lastModifyingUser"] = FileUser(
                    kind="drive#user",
                    displayName=last_modifying_user.display_name,
                    photoLink=last_modifying_user.photo_url,
                    me=last_modifying_user.id == current_user.id,
                    permissionId=last_modifying_user.id,
                    emailAddress=last_modifying_user.email,
                )

            # Add drive information
            file_data["driveId"] = file.drive_id

            # Add spaces field
            if file.space:
                file_data["spaces"] = [file.space]

            # Add labelInfo if includeLabels is specified
            if params.includeLabels:
                validated_label_ids = [
                    label_id.strip()
                    for label_id in params.includeLabels.split(",")
                    if label_id.strip()
                ]
                # Initialize label_list - will be populated if labels are found
                label_list = []
                if validated_label_ids:
                    # Get file labels that match the requested label IDs
                    file_labels = (
                        db.query(FileLabel)
                        .join(Label)
                        .filter(
                            FileLabel.file_id == file.id,
                            FileLabel.label_id.in_(validated_label_ids),
                        )
                        .all()
                    )

                    if file_labels:
                        for file_label in file_labels:
                            label_data = {"kind": "drive#labelFieldValue"}

                            # Map value based on type
                            if file_label.value_string is not None:
                                label_data["valueType"] = "text"
                                label_data["textValues"] = [file_label.value_string]
                            elif file_label.value_number is not None:
                                label_data["valueType"] = "integer"
                                label_data["integerValues"] = [
                                    int(file_label.value_number)
                                ]
                            elif file_label.value_boolean is not None:
                                label_data["valueType"] = "selection"
                                label_data["selectionValues"] = [
                                    str(file_label.value_boolean)
                                ]
                            elif file_label.value_date is not None:
                                label_data["valueType"] = "dateString"
                                label_data["dateStringValues"] = [
                                    file_label.value_date.isoformat()
                                ]
                            elif file_label.value_enum is not None:
                                label_data["valueType"] = "selection"
                                label_data["selectionValues"] = [file_label.value_enum]

                            # Get label information
                            label = (
                                file_label.label
                                if hasattr(file_label, "label")
                                else db.query(Label)
                                .filter(Label.id == file_label.label_id)
                                .first()
                            )
                            if label:
                                label_list.append(
                                    {
                                        "kind": "drive#label",
                                        "id": label.id,
                                        "fields": {label.key or "value": label_data},
                                    }
                                )

                # According to Google Drive API: labelInfo should always be present when includeLabels is specified
                # (even if empty, to match Google Drive API behavior)
                file_data["labelInfo"] = {"labels": label_list}

            # Add permissions if includePermissionsForView is specified
            if (
                params.includePermissionsForView
                and params.includePermissionsForView.strip().lower() == "published"
            ):
                # Get all permissions for the file with view=published
                permissions = (
                    db.query(Permission)
                    .filter(
                        Permission.file_id == file.id,
                        Permission.view == PermissionView.PUBLISHED,
                    )
                    .all()
                )

                # Always initialize permission_list when includePermissionsForView is specified
                permission_list = []
                if permissions:
                    for perm in permissions:
                        permission_data = {
                            "kind": "drive#permission",
                            "id": perm.id,
                            "type": perm.type.value if perm.type else None,
                            "role": perm.role.value if perm.role else None,
                        }

                        if perm.email_address:
                            permission_data["emailAddress"] = perm.email_address
                        if perm.domain:
                            permission_data["domain"] = perm.domain
                        if perm.display_name:
                            permission_data["displayName"] = perm.display_name
                        if perm.photo_link:
                            permission_data["photoLink"] = perm.photo_link

                        permission_data["allowFileDiscovery"] = bool(
                            perm.allow_file_discovery
                        )
                        permission_data["deleted"] = bool(perm.deleted)

                        if perm.created_time:
                            permission_data["createdTime"] = (
                                perm.created_time.isoformat() + "Z"
                            )

                        permission_list.append(permission_data)

                # Always add permissions field when includePermissionsForView is specified
                # (even if empty, to match Google Drive API behavior)
                file_data["permissions"] = permission_list

            # Convert dict to FileResponse Pydantic model
            file_response = FileResponse(**file_data)
            file_list.append(file_response)

        # Set incompleteSearch based on corpora
        incomplete_search = params.corpora == "allDrives"

        logger.info(f"Retrieved {len(file_list)} files for user")

        # Return Pydantic response model
        return FilesListResponse(
            files=file_list,
            kind="drive#fileList",
            nextPageToken=next_page_token,
            incompleteSearch=incomplete_search,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error listing files: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to list files: {str(e)}")


@files_router.get("/files.get")
def get_files(
    request: Request,
    fileId: str = Query(..., description="The ID of the file"),
    acknowledgeAbuse: bool = Query(
        False,
        description="Whether the user is acknowledging the risk of downloading known malware or other abusive files. This is only applicable when the alt parameter is set to media and the user is the owner of the file or an organizer of the shared drive in which the file resides.",
    ),
    supportsAllDrives: bool = Query(
        True,
        description="Whether the requesting application supports both My Drives and shared drives",
    ),
    supportsTeamDrives: Optional[bool] = Query(
        None, description="Deprecated: Use supportsAllDrives instead"
    ),
    includePermissionsForView: Optional[str] = Query(
        None,
        description="Specifies which additional view's permissions to include in the response. Only published is supported",
    ),
    includeLabels: Optional[str] = Query(
        None,
        description="A comma-separated list of IDs of labels to include in the labelInfo part of the response",
    ),
    alt: Optional[str] = Query(
        None,
        description="Specifies the format that the API should return for the file. Use 'media' to download file content",
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    """
    Get a file's metadata or content by ID.

    Implements Google Drive API v3 files.get endpoint with comprehensive validation
    and response formatting according to the official specification.

    Reference: https://developers.google.com/workspace/drive/api/reference/rest/v3/files/get
    """
    try:
        if not fileId or not fileId.strip():
            raise HTTPException(
                status_code=400,
                detail={
                    "error": {
                        "code": 400,
                        "message": "File ID is required",
                        "status": "INVALID_ARGUMENT",
                    }
                },
            )

        fileId = fileId.strip()

        # Validate acknowledgeAbuse parameter - must be used with alt=media only
        if acknowledgeAbuse:
            if alt is None or alt.strip().lower() != "media":
                raise HTTPException(
                    status_code=400,
                    detail={
                        "error": {
                            "code": 400,
                            "message": "acknowledgeAbuse=true is only valid when alt parameter is set to 'media'",
                            "status": "INVALID_ARGUMENT",
                        }
                    },
                )

        # Validate includePermissionsForView parameter - only allows 'published'
        if includePermissionsForView is not None:
            includePermissionsForView = includePermissionsForView.strip()
            if (
                includePermissionsForView
                and includePermissionsForView.lower() != "published"
            ):
                raise HTTPException(
                    status_code=400,
                    detail={
                        "error": {
                            "code": 400,
                            "message": "includePermissionsForView only supports 'published' value",
                            "status": "INVALID_ARGUMENT",
                        }
                    },
                )

        # Validate includeLabels parameter - check if label IDs exist and are associated with the file
        validated_label_ids = []
        if includeLabels is not None:
            includeLabels = includeLabels.strip()
            if includeLabels:
                label_ids = [
                    label_id.strip()
                    for label_id in includeLabels.split(",")
                    if label_id.strip()
                ]
                for label_id in label_ids:
                    # Check if label exists in database
                    label = db.query(Label).filter(Label.id == label_id).first()
                    if not label:
                        raise HTTPException(
                            status_code=400,
                            detail={
                                "error": {
                                    "code": 400,
                                    "message": f"Invalid label ID '{label_id}'. Label does not exist in the system.",
                                    "status": "INVALID_ARGUMENT",
                                }
                            },
                        )
                    validated_label_ids.append(label_id)

        file = db.query(File).filter(File.id == fileId).first()
        if not file:
            raise HTTPException(
                status_code=404,
                detail={
                    "error": {
                        "code": 404,
                        "message": f"File not found: {fileId}",
                        "status": "NOT_FOUND",
                    }
                },
            )

        if not _has_file_access(current_user, file, db):
            raise HTTPException(
                status_code=403,
                detail={
                    "error": {
                        "code": 403,
                        "message": f"The user does not have sufficient permissions for file {fileId}.",
                        "status": "PERMISSION_DENIED",
                    }
                },
            )

        user_permission_level = _get_user_file_permission(current_user, file, db)

        file_response = {
            "kind": "drive#file",
            "id": file.id,
            "name": file.name,
            "mimeType": file.mime_type,
        }
        if file.description:
            file_response["description"] = file.description
        if file.size_bytes is not None:
            file_response["size"] = str(file.size_bytes)
        if file.quota_bytes_used is not None:
            file_response["quotaBytesUsed"] = str(file.quota_bytes_used)
        if file.md5_checksum:
            file_response["md5Checksum"] = file.md5_checksum
        if file.sha1_checksum:
            file_response["sha1Checksum"] = file.sha1_checksum
        if file.created_time:
            file_response["createdTime"] = file.created_time.isoformat() + "Z"
        if file.modified_time:
            file_response["modifiedTime"] = file.modified_time.isoformat() + "Z"
        if file.viewed_by_me_time:
            file_response["viewedByMeTime"] = file.viewed_by_me_time.isoformat() + "Z"
        if file.trashed_time:
            file_response["trashedTime"] = file.trashed_time.isoformat() + "Z"
        file_response["starred"] = bool(file.starred)
        file_response["trashed"] = bool(file.trashed)
        file_response["explicitlyTrashed"] = bool(file.explicitly_trashed)
        file_response["shared"] = bool(file.shared)
        file_response["ownedByMe"] = file.created_by == current_user.id
        file_response["viewedByMe"] = file.viewed_by_me_time is not None
        file_response["modifiedByMe"] = file.modified_by == current_user.id
        file_response["writersCanShare"] = bool(file.writers_can_share)
        if file.file_extension:
            file_response["fileExtension"] = file.file_extension
        if file.full_file_extension:
            file_response["fullFileExtension"] = file.full_file_extension
        if file.original_filename:
            file_response["originalFilename"] = file.original_filename
        if file.version:
            file_response["version"] = str(file.version)
        if file.head_revision_id:
            file_response["headRevisionId"] = file.head_revision_id
        if file.web_view_link:
            file_response["webViewLink"] = file.web_view_link
        else:
            file_response[
                "webViewLink"
            ] = f"https://drive.google.com/file/d/{file.id}/view"

        if file.web_content_link:
            file_response["webContentLink"] = file.web_content_link
        else:
            file_response[
                "webContentLink"
            ] = f"https://drive.google.com/uc?id={file.id}&export=download"

        if file.thumbnail_link:
            file_response["thumbnailLink"] = file.thumbnail_link

        if file.icon_link:
            file_response["iconLink"] = file.icon_link
        else:
            file_response[
                "iconLink"
            ] = f"https://ssl.gstatic.com/docs/doclist/images/mediatype/icon_{file.mime_type.replace('/', '_')}_list.png"
        if file.is_shortcut:
            file_response["isShortcut"] = True
            if file.shortcut_target_id:
                file_response["shortcutDetails"] = {
                    "targetId": file.shortcut_target_id,
                    "targetMimeType": file.shortcut_target_mime,
                }
        if file.properties:
            file_response["properties"] = file.properties
        if file.app_properties:
            file_response["appProperties"] = file.app_properties
        if file.drive_id:
            file_response["driveId"] = file.drive_id

        if (
            file.parent_ids
            and isinstance(file.parent_ids, list)
            and len(file.parent_ids) > 0
        ):
            file_response["parents"] = file.parent_ids
        elif file.parent_id:
            file_response["parents"] = [file.parent_id]
        else:
            file_response["parents"] = []

        owners = []
        owners = []
        if file.created_by:
            owner = db.query(User).filter(User.id == file.created_by).first()
            if owner:
                owners.append(
                    {
                        "kind": "drive#user",
                        "displayName": owner.display_name,
                        "emailAddress": owner.email,
                        "photoLink": owner.photo_url,
                        "me": owner.id == current_user.id,
                        "permissionId": owner.permission_id or owner.id,
                    }
                )

        for owner in getattr(file, "owners", []):
            if not any(
                o["permissionId"] == (owner.permission_id or owner.id) for o in owners
            ):
                owners.append(
                    {
                        "kind": "drive#user",
                        "displayName": owner.display_name,
                        "emailAddress": owner.email,
                        "photoLink": owner.photo_url,
                        "me": owner.id == current_user.id,
                        "permissionId": owner.permission_id or owner.id,
                    }
                )

        if owners:
            file_response["owners"] = owners

        if file.modified_by:
            last_modifying_user = (
                db.query(User).filter(User.id == file.modified_by).first()
            )
            if last_modifying_user:
                file_response["lastModifyingUser"] = {
                    "kind": "drive#user",
                    "displayName": last_modifying_user.display_name,
                    "emailAddress": last_modifying_user.email,
                    "photoLink": last_modifying_user.photo_url,
                    "me": last_modifying_user.id == current_user.id,
                    "permissionId": last_modifying_user.permission_id
                    or last_modifying_user.id,
                }

        file_response["capabilities"] = _build_enhanced_file_capabilities(
            current_user, file, user_permission_level, db
        )

        if validated_label_ids:
            # First, validate that all requested labels are actually associated with this file
            file_label_ids = (
                db.query(FileLabel.label_id)
                .filter(
                    FileLabel.file_id == file.id,
                    FileLabel.label_id.in_(validated_label_ids),
                )
                .all()
            )
            file_label_ids = [fl.label_id for fl in file_label_ids]

            missing_labels = set(validated_label_ids) - set(file_label_ids)
            missing_labels = set(validated_label_ids) - set(file_label_ids)
            if missing_labels:
                missing_label_list = ", ".join(missing_labels)
                raise HTTPException(
                    status_code=400,
                    detail={
                        "error": {
                            "code": 400,
                            "message": f"The following labels are not associated with file '{fileId}': {missing_label_list}",
                            "status": "INVALID_ARGUMENT",
                        }
                    },
                )

            file_labels = (
                db.query(FileLabel)
                .join(Label)
                .filter(
                    FileLabel.file_id == file.id,
                    FileLabel.label_id.in_(validated_label_ids),
                )
                .all()
            )

            label_list = []
            if file_labels:
                for file_label in file_labels:
                    label_data = {"kind": "drive#labelFieldValue"}

                    # Add the appropriate value based on label type
                    if file_label.value_string is not None:
                        label_data["valueType"] = "text"
                        label_data["textValues"] = [file_label.value_string]
                    elif file_label.value_number is not None:
                        label_data["valueType"] = "integer"
                        label_data["integerValues"] = [int(file_label.value_number)]
                    elif file_label.value_boolean is not None:
                        label_data["valueType"] = "selection"
                        label_data["selectionValues"] = [str(file_label.value_boolean)]
                    elif file_label.value_date is not None:
                        label_data["valueType"] = "dateString"
                        label_data["dateStringValues"] = [
                            file_label.value_date.isoformat()
                        ]
                    elif file_label.value_enum is not None:
                        label_data["valueType"] = "selection"
                        label_data["selectionValues"] = [file_label.value_enum]

                    # Get label information
                    label = (
                        file_label.label
                        if hasattr(file_label, "label")
                        else db.query(Label)
                        .filter(Label.id == file_label.label_id)
                        .first()
                    )
                    if label:
                        label_list.append(
                            {
                                "kind": "drive#label",
                                "id": label.id,
                                "fields": {label.key or "value": label_data},
                            }
                        )

            if validated_label_ids:
                file_response["labelInfo"] = {"labels": label_list}

        if (
            includePermissionsForView
            and includePermissionsForView.lower() == "published"
        ):
            permissions = (
                db.query(Permission)
                .filter(
                    Permission.file_id == file.id,
                    Permission.view == PermissionView.PUBLISHED,
                )
                .all()
            )

            permission_list = []
            if permissions:
                for perm in permissions:
                    permission_data = {
                        "kind": "drive#permission",
                        "id": perm.id,
                        "type": perm.type.value if perm.type else None,
                        "role": perm.role.value if perm.role else None,
                    }

                    if perm.email_address:
                        permission_data["emailAddress"] = perm.email_address
                    if perm.domain:
                        permission_data["domain"] = perm.domain
                    if perm.display_name:
                        permission_data["displayName"] = perm.display_name
                    if perm.photo_link:
                        permission_data["photoLink"] = perm.photo_link

                    permission_data["allowFileDiscovery"] = bool(
                        perm.allow_file_discovery
                    )
                    permission_data["deleted"] = bool(perm.deleted)

                    if perm.created_time:
                        permission_data["createdTime"] = (
                            perm.created_time.isoformat() + "Z"
                        )

                    permission_list.append(permission_data)

            file_response["permissions"] = permission_list

        if file.mime_type.startswith("image/"):
            file_response["imageMediaMetadata"] = {
                "width": 1920,
                "height": 1080,
                "rotation": 0,
            }
        elif file.mime_type.startswith("video/"):
            file_response["videoMediaMetadata"] = {
                "width": 1920,
                "height": 1080,
                "durationMillis": "120000",
            }

        return file_response

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": {
                    "code": 500,
                    "message": f"Internal server error: {str(e)}",
                    "status": "INTERNAL",
                }
            },
        )


def _has_file_access(user: User, file: File, db: Session) -> bool:
    """
    Strict access control check based on the requirements.
    A file should ONLY be accessible by:
    1. File owner
    2. People having access to the drive based on drive membership table
    """
    from app.models.google_drive_model import DriveMembership

    # Check if user is the file owner
    if file.created_by == user.id:
        return True

    # Check if user is in the file owners many-to-many relationship
    if hasattr(file, "owners") and user in file.owners:
        return True

    # Check drive membership
    if file.drive_id:
        drive_membership = (
            db.query(DriveMembership)
            .filter(
                DriveMembership.drive_id == file.drive_id,
                DriveMembership.user_id == user.id,
            )
            .first()
        )

        if drive_membership:
            return True

    # NO OTHER ACCESS METHODS ALLOWED
    # (Removed direct permissions, group permissions, domain permissions, anyone permissions)

    return False


def _build_enhanced_file_capabilities(
    user: User, file: File, permission_level: str, db: Session
) -> dict:
    """
    Build enhanced capabilities object based on user's actual permission level for the file.
    Includes all capabilities from Google Drive API specification.
    """
    is_folder = file.mime_type == "application/vnd.google-apps.folder"
    is_owner = permission_level == "owner"
    is_organizer = permission_level in ["organizer", "owner"]
    is_file_organizer = permission_level in ["fileOrganizer", "organizer", "owner"]
    is_writer = permission_level in ["writer", "fileOrganizer", "organizer", "owner"]
    # is_commenter = permission_level in [
    #     "commenter",
    #     "writer",
    #     "fileOrganizer",
    #     "organizer",
    #     "owner",
    # ]
    is_reader = permission_level in [
        "reader",
        "commenter",
        "writer",
        "fileOrganizer",
        "organizer",
        "owner",
    ]

    capabilities = {}

    # Basic read capabilities
    if is_reader:
        capabilities["canComment"] = True
        capabilities["canCopy"] = True
        capabilities["canReadRevisions"] = True
        capabilities["canDownload"] = not file.download_restricted_for_readers

    # Write capabilities
    if is_writer:
        capabilities["canEdit"] = True
        capabilities["canModifyContent"] = True
        capabilities["canRename"] = True
        capabilities["canMoveItemWithinDrive"] = True
        capabilities["canMoveItemOutOfDrive"] = is_owner
        capabilities["canShare"] = file.writers_can_share or is_owner
        capabilities["canTrash"] = True
        capabilities["canUntrash"] = True
        capabilities["canModifyContentRestriction"] = is_owner
        capabilities["canAddMyDriveParent"] = True
        capabilities["canRemoveMyDriveParent"] = True

    # Folder-specific capabilities
    if is_folder:
        if is_writer:
            capabilities["canAddChildren"] = True
            capabilities["canRemoveChildren"] = True
            capabilities["canMoveChildrenWithinDrive"] = True
            capabilities["canMoveChildrenOutOfDrive"] = is_owner
        if is_reader:
            capabilities["canListChildren"] = True

    # Owner/organizer capabilities
    if is_owner:
        capabilities["canDelete"] = True
        capabilities["canModifyOwnerContentRestriction"] = True
        capabilities["canModifyEditorContentRestriction"] = True
        capabilities["canModifyViewerContentRestriction"] = True
        capabilities["canChangeCopyRequiresWriterPermission"] = True
        capabilities["canChangeViewersCanCopyContent"] = True
        capabilities["canAcceptOwnership"] = False  # Already owner

    # File organizer capabilities
    if is_file_organizer:
        capabilities["canMoveItemIntoTeamDrive"] = True
        capabilities["canMoveTeamDriveItem"] = True

    # Drive-specific capabilities
    drive = (
        db.query(Drive).filter(Drive.id == file.drive_id).first()
        if file.drive_id
        else None
    )
    if drive:
        capabilities["canMoveItemOutOfTeamDrive"] = is_organizer
        capabilities["canChangeRestrictedDownload"] = is_organizer

    return capabilities


# ----------------------------
# Endpoint: files.create
# ----------------------------
@files_router.post("/files", status_code=status.HTTP_200_OK, response_model=FileSchema)
def create_file(
    payload: FileCreateRequest,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    """
    Create a new file (metadata only).
    Aligns with Google Drive API:
    - Requires extension in name unless Google-native mimeType.
    - Supports shortcuts with targetId.
    - Parent must be a folder.
    """
    try:
        # Normalize incoming fields from body
        incoming_name = (payload.name or "").strip() if payload.name else None
        incoming_mime = (payload.mimeType or "").strip() if payload.mimeType else None

        logger.info(
            "Creating file with name='%s', mime='%s' by user=%s",
            incoming_name,
            incoming_mime,
            current_user.id,
        )

        # Validate parent folders when provided
        parent_ids = payload.parents or []
        drive_id_from_parent = None
        if parent_ids:
            # Validate all parent folders exist and are folders
            # Also check if parent_id is a drive ID (for creating in root of shared drive)
            valid_parents = []
            for parent_id in parent_ids:
                parent_file = db.query(File).filter(File.id == parent_id).first()
                if (
                    parent_file
                    and parent_file.mime_type == "application/vnd.google-apps.folder"
                ):
                    valid_parents.append(parent_id)
                else:
                    # Check if parent_id is actually a drive ID
                    from app.models.google_drive_model import DriveMembership

                    drive = db.query(Drive).filter(Drive.id == parent_id).first()
                    if drive:
                        # Validate user has access to this drive
                        # Check direct user membership
                        user_drive_membership = (
                            db.query(DriveMembership)
                            .filter(
                                DriveMembership.user_id == current_user.id,
                                DriveMembership.drive_id == parent_id,
                                DriveMembership.type == "user",
                            )
                            .first()
                        )

                        if not user_drive_membership:
                            # Check group membership
                            from app.models.google_drive_model import GroupMembership

                            group_membership = (
                                db.query(GroupMembership)
                                .join(
                                    DriveMembership,
                                    GroupMembership.group_id
                                    == DriveMembership.group_id,
                                )
                                .filter(
                                    DriveMembership.drive_id == parent_id,
                                    DriveMembership.type == "group",
                                    GroupMembership.user_id == current_user.id,
                                )
                                .first()
                            )

                            if not group_membership:
                                # Check domain membership
                                if current_user.email and "@" in current_user.email:
                                    user_domain = current_user.email.split("@")[1]
                                    domain_membership = (
                                        db.query(DriveMembership)
                                        .filter(
                                            DriveMembership.drive_id == parent_id,
                                            DriveMembership.type == "domain",
                                            DriveMembership.domain == user_domain,
                                        )
                                        .first()
                                    )

                                    if not domain_membership:
                                        raise HTTPException(
                                            status_code=403,
                                            detail=f"User does not have access to drive '{parent_id}'",
                                        )
                                else:
                                    raise HTTPException(
                                        status_code=403,
                                        detail=f"User does not have access to drive '{parent_id}'",
                                    )

                        # Drive ID is valid - create in root of this drive
                        drive_id_from_parent = parent_id
                        # Empty parent_ids means root folder of the drive
                        valid_parents = []
                        break
                    else:
                        raise HTTPException(
                            status_code=400,
                            detail=f"Parent folder '{parent_id}' not found or not a folder, and is not a valid drive ID",
                        )
            parent_ids = valid_parents
        if not incoming_name:
            raise HTTPException(status_code=400, detail="name is required")
        if not incoming_mime:
            raise HTTPException(status_code=400, detail="mimeType is required")
        # Validate Google-native mime types against enum; allow any non-Google mime
        allowed_google_mimes = {m.value for m in GoogleDriveMimeTypes}
        if incoming_mime not in allowed_google_mimes:
            raise HTTPException(
                status_code=400, detail=f"Invalid google mimeType: {incoming_mime}"
            )

        # --- validate drive ---
        if drive_id_from_parent:
            # Drive ID was provided as parent - create in root of that drive
            drive_id = drive_id_from_parent
            drive = db.query(Drive).filter(Drive.id == drive_id).first()
            if not drive:
                raise HTTPException(
                    status_code=404, detail=f"Drive '{drive_id}' not found"
                )
        elif parent_ids:
            # Place the new file in the same drive as the first parent folder
            first_parent = db.query(File).filter(File.id == parent_ids[0]).first()
            if first_parent:
                drive_id = first_parent.drive_id
                drive = db.query(Drive).filter(Drive.id == drive_id).first()
            else:
                raise HTTPException(
                    status_code=400, detail="First parent folder not found"
                )
        elif getattr(payload, "driveId", None):
            # Ignore any driveId in payload; create always derives drive from parent or user's My Drive
            from app.models.google_drive_model import DriveMembership

            drive_id = payload.driveId
            user_drive_membership = (
                db.query(DriveMembership)
                .filter(
                    DriveMembership.user_id == current_user.id,
                    DriveMembership.drive_id == drive_id,
                )
                .first()
            )

            if user_drive_membership:
                drive_id = user_drive_membership.drive_id
                drive = db.query(Drive).filter(Drive.id == drive_id).first()

            else:
                return HTTPException(
                    status_code=400,
                    detail="No parent provided and no My Drive available",
                )
        else:
            # If no parent provided, place in current user's My Drive root folder
            from app.models.google_drive_model import DriveMembership

            user_drive_membership = (
                db.query(DriveMembership.drive_id)
                .filter(DriveMembership.user_id == current_user.id)
                .first()
            )
            if user_drive_membership:
                drive_id = user_drive_membership.drive_id
                drive = db.query(Drive).filter(Drive.id == drive_id).first()
                # When no parent is provided, use root folder (parent_id=None)
                parent_ids = []  # Empty parent_ids means root folder
            else:
                # fallback: default drive
                drive = db.query(Drive).filter(not Drive.hidden).first()
                if not drive:
                    drive = Drive(
                        id=generate_uuid(),
                        name="My Drive",
                        hidden=False,
                        created_time=datetime.utcnow(),
                        modified_time=datetime.utcnow(),
                    )
                    db.add(drive)
                    db.flush()
                drive_id = drive.id
                parent_ids = []  # Empty parent_ids means root folder

        # --- validate shortcut logic ---
        is_shortcut = False
        shortcut_target_mime = None
        if incoming_mime == "application/vnd.google-apps.shortcut":
            target_id = (
                payload.shortcutDetails.targetId if payload.shortcutDetails else None
            )
            if not target_id:
                raise HTTPException(
                    status_code=400,
                    detail="shortcutTargetId is required when creating a shortcut",
                )
            target = db.query(File).filter(File.id == target_id).first()
            if not target:
                raise HTTPException(
                    status_code=404,
                    detail=f"Shortcut target '{target_id}' not found",
                )
            is_shortcut = True
            shortcut_target_mime = target.mime_type
        else:
            is_shortcut = False

        # --- sanitize name ---
        safe_name = _sanitize_filename(incoming_name)

        # Check for duplicates in any of the parent folders
        existing = None
        if parent_ids:
            for parent_id in parent_ids:
                existing = (
                    db.query(File)
                    .filter(
                        File.drive_id == drive_id,
                        File.parent_ids.contains([parent_id]),
                        File.name == safe_name,
                        not File.trashed,
                    )
                    .first()
                )
                if existing:
                    break
        if existing:
            logger.warning(
                f"Duplicate file '{safe_name}' already exists in folder '{payload.parent_id}'. "
                "Allowing new file creation per Google Drive API spec."
            )

        # --- create file ---
        # Set primary parent_id (first parent in the list)
        primary_parent_id = parent_ids[0] if parent_ids else None

        new_file = File(
            id=generate_uuid(),
            name=safe_name,
            mime_type=incoming_mime,
            description=payload.description,
            size_bytes=0,
            starred=bool(payload.starred) if payload.starred is not None else False,
            properties=payload.properties,
            app_properties=payload.appProperties,
            parent_ids=parent_ids,
            parent_id=primary_parent_id,  # Set the primary parent_id field
            created_by=current_user.id,
            drive_id=drive_id,
            is_shortcut=is_shortcut,
            shortcut_target_id=(
                payload.shortcutDetails.targetId
                if (is_shortcut and payload.shortcutDetails)
                else None
            ),
            shortcut_target_mime=shortcut_target_mime,
        )
        db.add(new_file)
        db.flush()

        # Parent folders are already handled via parent_ids field

        # --- optional flags from body/query ---
        if payload.writersCanShare is not None:
            new_file.writers_can_share = bool(payload.writersCanShare)
        if payload.copyRequiresWriterPermission is not None:
            new_file.copy_requires_writer_permission = bool(
                payload.copyRequiresWriterPermission
            )
        if (
            payload.downloadRestrictions
            and payload.downloadRestrictions.restricted is not None
        ):
            # Apply download restriction broadly (both readers and writers) for simplicity
            restricted = bool(payload.downloadRestrictions.restricted)
            new_file.download_restricted_for_readers = restricted
            new_file.download_restricted_for_writers = restricted

        db.commit()
        db.refresh(new_file)

        return JSONResponse(
            status_code=status.HTTP_200_OK,
            content=map_file_model_to_file_schema(new_file).model_dump(mode="json"),
        )

    except HTTPException:
        raise
    except SQLAlchemyError as e:
        logger.error("Database error creating file: %s", str(e))
        db.rollback()
        raise HTTPException(
            status_code=500, detail="Database error while creating file"
        )
    except Exception as e:
        logger.error("Unexpected error creating file: %s", str(e))
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create file: {str(e)}")


@files_router.delete("/files/trash")
def empty_trash(
    request: Request,
    driveId: Optional[str] = None,
    enforceSingleParent: Optional[bool] = Query(
        None, description="Deprecated: no longer supported, kept for compatibility"
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    """
    Permanently delete all trashed files.
    If driveId is provided, empties the trash of that shared drive.
    Response matches Google Drive API: empty JSON object {}.
    """
    try:
        query = db.query(File).filter(File.trashed == True)
        query = db.query(File).filter(File.trashed == True)
        if driveId:
            query = query.filter(File.drive_id == driveId)
        else:
            query = query.filter(File.created_by == current_user.id)

        trashed_files = query.all()

        for f in trashed_files:
            log_entry = TrashLog(
                id=generate_uuid(),
                file_id=f.id,
                emptied_time=datetime.utcnow(),
                actor_id=current_user.id,
            )
            db.add(log_entry)
            db.delete(f)

        db.commit()

        return {}

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to empty trash: {str(e)}")


@files_router.delete("/files/{fileId}")
def delete_file(
    fileId: str,
    request: Request,
    supportsAllDrives: bool = Query(
        True,
        description="Whether the requesting application supports both My Drives and shared drives",
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    """
    Move a file to trash (soft delete).
    - Only file owners can delete files (matches Google Drive API behavior)
    - For shared drives, organizers and fileOrganizers can also delete files
    - If the file is a folder, also moves all its children to trash.
    - Response matches Google Drive API: empty JSON object {}.
    """
    try:
        file_obj = db.query(File).filter(File.id == fileId).first()
        if not file_obj:
            raise HTTPException(status_code=404, detail=f"File '{fileId}' not found")

        # Check if user has permission to delete the file
        from app.models.google_drive_model import DriveMembership

        # user_permission = get_user_file_permission(current_user, file_obj, db)
        # Check if user is the file owner
        is_owner = file_obj.created_by == current_user.id

        # Check if user has delete permission through shared drive roles
        can_delete_via_drive = False
        if file_obj.drive_id and not is_owner:
            # Check direct user membership
            user_membership = (
                db.query(DriveMembership)
                .filter(
                    DriveMembership.drive_id == file_obj.drive_id,
                    DriveMembership.type == "user",
                    DriveMembership.user_id == current_user.id,
                    DriveMembership.role.in_(
                        [PermissionRole.ORGANIZER, PermissionRole.FILE_ORGANIZER]
                    ),
                )
                .first()
            )

            # Check group membership if no direct membership
            group_membership = None
            if not user_membership:
                from app.models.google_drive_model import GroupMembership

                group_membership = (
                    db.query(DriveMembership)
                    .join(
                        GroupMembership,
                        DriveMembership.group_id == GroupMembership.group_id,
                    )
                    .filter(
                        DriveMembership.drive_id == file_obj.drive_id,
                        DriveMembership.type == "group",
                        GroupMembership.user_id == current_user.id,
                        DriveMembership.role.in_(
                            [PermissionRole.ORGANIZER, PermissionRole.FILE_ORGANIZER]
                        ),
                    )
                    .first()
                )

            can_delete_via_drive = (
                user_membership is not None or group_membership is not None
            )

        # Only owners and shared drive organizers/fileOrganizers can delete files
        if not is_owner and not can_delete_via_drive:
            if file_obj.drive_id:
                raise HTTPException(
                    status_code=403,
                    detail=f"User '{current_user.id}' does not have permission to delete file '{fileId}'. Only file owners or shared drive organizers/fileOrganizers can delete files.",
                )
            else:
                raise HTTPException(
                    status_code=403,
                    detail=f"User '{current_user.id}' is not the owner of file '{fileId}'. Only file owners can delete files.",
                )

        # Move file to trash (soft delete)
        from datetime import datetime

        file_obj.trashed = True
        file_obj.trashed_time = datetime.utcnow()

        if file_obj.mime_type == "application/vnd.google-apps.folder":
            for child in list(file_obj.children):
                child.trashed = True
                child.trashed_time = datetime.utcnow()

        db.commit()

        return {}

    except HTTPException:
        raise
    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=500, detail="Database error while moving file to trash"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500, detail=f"Failed to move file to trash: {str(e)}"
        )


# ----------------------------
# Endpoint: files.export
# ----------------------------
@files_router.get("/files/{fileId}/export", status_code=status.HTTP_200_OK)
def export_file(
    request: Request,
    fileId: str = Path(..., min_length=1, description="The ID of the file to export"),
    mimeType: str = Query(
        ...,
        min_length=1,
        description="The MIME type to export the file as. Must be a supported export format.",
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    """
    Export a Google Workspace file to the requested MIME type.

    Reference: https://developers.google.com/workspace/drive/api/reference/rest/v3/files/export

    Requirements:
    - Only Workspace-native files (Google Docs, Sheets, Slides, Drawings) can be exported
    - User must have a valid role (owner, organizer, fileOrganizer, writer, commenter, reader)
    - Owner/organizer may restrict export with content restrictions
    - mimeType must be a valid export format for the file's type
    """

    try:
        if not mimeType or not mimeType.strip():
            raise HTTPException(
                status_code=400,
                detail={
                    "error": {
                        "code": 400,
                        "message": "mimeType is required and cannot be empty",
                        "status": "INVALID_ARGUMENT",
                    }
                },
            )

        mimeType_clean = mimeType.strip()

        # Validate mimeType format (should be "type/subtype")
        if "/" not in mimeType_clean:
            raise HTTPException(
                status_code=400,
                detail={
                    "error": {
                        "code": 400,
                        "message": f"Invalid mimeType format: '{mimeType_clean}'. Expected format: 'type/subtype'",
                        "status": "INVALID_ARGUMENT",
                    }
                },
            )

        # Check if mimeType is in the list of all supported export formats
        all_supported_formats = [
            m for group in EXPORTABLE_TYPES.values() for m in group
        ]
        if mimeType_clean not in all_supported_formats:
            raise HTTPException(
                status_code=400,
                detail={
                    "error": {
                        "code": 400,
                        "message": f"Unsupported export format: '{mimeType_clean}'. Supported formats: {', '.join(sorted(set(all_supported_formats)))}",
                        "status": "INVALID_ARGUMENT",
                    }
                },
            )

        # ----------------------------
        # Validate input using schema
        # ----------------------------
        args = FilesExportArgs(fileId=fileId, mimeType=mimeType_clean)

        # ----------------------------
        # Query file from DB
        # ----------------------------
        file_obj = db.query(File).filter(File.id == args.fileId).first()
        if not file_obj:
            raise HTTPException(
                status_code=404, detail=f"File '{args.fileId}' not found"
            )

        # ----------------------------
        # Permission check
        # ----------------------------
        # If user is not the creator, check permissions table
        if file_obj.created_by != current_user.id:
            perm = (
                db.query(Permission)
                .filter(
                    Permission.file_id == args.fileId,
                    Permission.user_id == current_user.id,
                )
                .first()
            )
            if not perm:
                raise HTTPException(
                    status_code=403,
                    detail=f"User '{current_user.id}' is not authorized to export this file",
                )

            allowed_roles = {
                "owner",
                "organizer",
                "fileOrganizer",
                "writer",
                "commenter",
                "reader",
            }
            user_role = perm.role.value if perm.role else None

            if user_role not in allowed_roles:
                raise HTTPException(
                    status_code=403,
                    detail=f"Role '{user_role}' does not allow exporting this file",
                )

            # Restriction: if owner set download restrictions
            if (
                file_obj.copy_requires_writer_permission
                or file_obj.download_restricted_for_readers
            ):
                if user_role in {"reader", "commenter"}:
                    raise HTTPException(
                        status_code=403, detail="Export is restricted by the file owner"
                    )

        # ----------------------------
        # Validate MIME type
        # ----------------------------
        supported_types = EXPORTABLE_TYPES.get(file_obj.mime_type, [])
        if not supported_types:
            raise HTTPException(
                status_code=400,
                detail={
                    "error": {
                        "code": 400,
                        "message": f"File '{file_obj.name}' (mimeType={file_obj.mime_type}) is not exportable",
                        "status": "INVALID_ARGUMENT",
                    }
                },
            )

        if args.mimeType not in supported_types:
            raise HTTPException(
                status_code=400,
                detail={
                    "error": {
                        "code": 400,
                        "message": f"Invalid mimeType '{args.mimeType}'. Supported: {supported_types}",
                        "status": "INVALID_ARGUMENT",
                    }
                },
            )

        # ----------------------------
        # Mock binary content
        # ----------------------------
        exported_content = generate_export_bytes(
            file_obj.mime_type, args.mimeType, file_obj.name
        )
        extension = args.mimeType.split("/")[-1]

        # ----------------------------
        # Return raw bytes response (200)
        # ----------------------------
        return Response(
            content=exported_content,
            media_type=args.mimeType,
            headers={
                "Content-Disposition": f"attachment; filename={file_obj.name}.{extension}"
            },
        )

    except (ValidationError, PydanticCoreValidationError) as e:
        # Handle Pydantic validation errors
        # Check if it's a mimeType-related error - return 400 for mimeType validation errors
        logger.warning(f"Validation error for file export {fileId}: {e}")
        error_errors = e.errors() if hasattr(e, "errors") else []

        # Check if any error is related to mimeType
        is_mimetype_error = any(
            "mimeType" in str(error.get("loc", [])).lower()
            or "mimetype" in str(error.get("loc", [])).lower()
            or "mime" in str(error.get("msg", "")).lower()
            for error in error_errors
        )

        if is_mimetype_error:
            # Return 400 for mimeType validation errors
            error_msg = (
                error_errors[0].get("msg", "Invalid mimeType")
                if error_errors
                else "Invalid mimeType"
            )
            # Extract the actual message if it's in "Value error, <message>" format
            if "Value error, " in error_msg:
                error_msg = error_msg.split("Value error, ", 1)[1]
            raise HTTPException(
                status_code=400,
                detail={
                    "error": {
                        "code": 400,
                        "message": error_msg,
                        "status": "INVALID_ARGUMENT",
                    }
                },
            )
        else:
            # Return 422 for other validation errors
            raise HTTPException(
                status_code=422,
                detail={"message": "Validation error", "errors": error_errors},
            )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error exporting file {fileId}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to export file: {str(e)}")


# ----------------------------
# Endpoint: generateIds.get
# ----------------------------
@files_router.get("/files/generateIds", response_model=FilesGenerateIdsResponse)
def generate_ids(
    request: Request,
    count: int = Query(
        10, ge=1, le=100, description="Number of IDs to generate (max 100)"
    ),
    space: str = Query(
        "drive",
        description="Space in which the IDs can be used. Allowed values: 'drive' or 'appDataFolder'.",
        pattern="^(drive|appDataFolder)$",
    ),
    type: str = Query(
        "files",
        description="Type of items for which the IDs can be used. 'files' or 'shortcuts'. Note: 'shortcuts' only valid when space=drive.",
        pattern="^(files|shortcuts)$",
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    """
    Generate a set of file IDs that can be used in create or copy requests.

    Validation aligned with Google Drive API:
    - count: 1-100 (validated by Query)
    - space: 'drive' or 'appDataFolder' (validated by Query regex)
    - type: 'files' or 'shortcuts' (validated by Query regex)
    - Additional business rule: if space='appDataFolder' then type must be 'files'
    """
    try:
        # Business rule validation: appDataFolder only supports type='files'
        if space == "appDataFolder" and type != "files":
            raise HTTPException(
                status_code=400,
                detail="Only type='files' is allowed when space='appDataFolder'.",
            )

        # Generate IDs
        ids = [str(uuid.uuid4()) for _ in range(count)]
        return {"ids": ids, "space": space, "kind": "drive#generatedIds"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error generating IDs: %s", str(e))
        raise HTTPException(status_code=500, detail=f"Failed to generate IDs: {str(e)}")


# ----------------------------
# Request / Response Schemas for Copy
# ----------------------------
class FilesCopyRequest(BaseModel):
    name: Optional[str] = Field(None, description="The name of the copied file")
    parents: Optional[List[str]] = Field(
        None, description="A list of parent folder IDs"
    )
    description: Optional[str] = Field(
        None, description="A short description of the file"
    )
    mimeType: Optional[str] = Field(None, description="The MIME type of the file")
    starred: Optional[bool] = Field(
        None, description="Whether the user has starred the file"
    )
    properties: Optional[Dict[str, Any]] = Field(
        None, description="Public key-value properties"
    )
    appProperties: Optional[Dict[str, Any]] = Field(
        None, description="App-private key-value properties"
    )

    class Config:
        populate_by_name = True


class FilesCopyResponse(BaseModel):
    success: bool
    file: Dict[str, Any]
    message: str


# ----------------------------
# Endpoint: files.copy
# ----------------------------
@files_router.post("/files.copy", response_model=FilesCopyResponse)
def copy_file(
    fileId: str = Query(..., description="The ID of the file to copy"),
    keepRevisionForever: Optional[bool] = Query(
        None,
        description="Whether to set the keepForever field in the new head revision",
    ),
    ocrLanguage: Optional[str] = Query(
        None,
        description="A language hint for OCR processing during image import (ISO 639-1 code)",
    ),
    supportsAllDrives: bool = Query(
        True,
        description="Whether the requesting application supports both My Drives and shared drives",
    ),
    ignoreDefaultVisibility: Optional[bool] = Query(
        None,
        description="Whether to ignore the domain's default visibility settings for the created file",
    ),
    includePermissionsForView: Optional[str] = Query(
        None,
        description="Specifies which additional view's permissions to include in the response. Only published is supported",
    ),
    includeLabels: Optional[str] = Query(
        None,
        description="A comma-separated list of IDs of labels to include in the labelInfo part of the response",
    ),
    copy_data: FilesCopyRequest = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    """
    Creates a copy of a file and applies any requested updates with patch semantics.
    """
    try:
        logger.info(f"Copying file {fileId} for user {current_user.id}")

        # Find the source file
        source_file = db.query(File).filter(File.id == fileId).first()
        if not source_file:
            raise HTTPException(
                status_code=404, detail=f"Source file '{fileId}' not found"
            )

        # Check if user has permission to copy the file
        can_copy, permission_type = can_copy_file(current_user, source_file, db)
        if not can_copy:
            logger.warning(
                f"User {current_user.id} does not have permission to copy file {fileId} (permission: {permission_type})"
            )
            raise HTTPException(
                status_code=403,
                detail="You don't have permission to copy this file. You need owner, organizer, writer, or reader role.",
            )

        # Generate new file ID
        new_file_id = generate_uuid()

        # Handle parent folders if specified
        parent_id = None

        if copy_data and copy_data.parents:
            if len(copy_data.parents) > 1:
                raise HTTPException(
                    status_code=400,
                    detail="Copying files into multiple folders is no longer supported. Use shortcuts instead.",
                )

            for parent_id in copy_data.parents:
                parent_file = db.query(File).filter(File.id == parent_id).first()
                if (
                    parent_file
                    and parent_file.mime_type == "application/vnd.google-apps.folder"
                ):
                    parent_id = parent_id
                else:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Parent folder '{parent_id}' not found or not a folder",
                    )
        else:
            # If no parent provided, place in current user's My Drive root folder
            parent_id = _get_user_my_drive_root_folder(db, current_user)
            if parent_id is None:
                # Root folder is represented by None
                parent_id = None

        # Determine the name for the copied file
        desired_name = (
            copy_data.name
            if copy_data and copy_data.name
            else f"Copy of {source_file.name}"
        )

        # Generate a unique name to avoid conflicts
        unique_name = _generate_unique_filename(db, desired_name, parent_id)

        # Create the copied file
        copied_file = File(
            id=new_file_id,
            name=unique_name,
            mime_type=copy_data.mimeType
            if copy_data and copy_data.mimeType
            else source_file.mime_type,
            description=copy_data.description
            if copy_data and copy_data.description
            else source_file.description,
            size_bytes=source_file.size_bytes,
            starred=copy_data.starred
            if copy_data and copy_data.starred is not None
            else source_file.starred,
            trashed=False,  # Copied files are not trashed
            properties=copy_data.properties
            if copy_data and copy_data.properties
            else source_file.properties,
            app_properties=copy_data.appProperties
            if copy_data and copy_data.appProperties
            else source_file.app_properties,
            created_by=current_user.id,  # The copier becomes the owner
            drive_id=source_file.drive_id,
            space=source_file.space,  # Preserve the space from source file
            created_time=datetime.utcnow(),
            modified_time=datetime.utcnow(),
            modified_by=current_user.id,
            viewed_by_me_time=None,
            trashed_time=None,
            md5_checksum=source_file.md5_checksum,
            shortcut_target_id=source_file.shortcut_target_id,
            shortcut_target_mime=source_file.shortcut_target_mime,
            parent_ids=[parent_id]
            if parent_id
            else [],  # Set the parent_ids field (empty list if None)
            parent_id=parent_id,  # Set the primary parent_id field
        )

        # Save the copied file to database
        db.add(copied_file)
        db.commit()
        db.refresh(copied_file)

        logger.info(f"Successfully copied file {fileId} to {new_file_id}")

        # Get owner information for response
        owner = db.query(User).filter(User.id == copied_file.created_by).first()

        # Build file response
        file_response = {
            "id": copied_file.id,
            "name": copied_file.name,
            "mimeType": copied_file.mime_type,
            "size": str(copied_file.size_bytes) if copied_file.size_bytes else "0",
            "md5Checksum": copied_file.md5_checksum,
            "createdTime": copied_file.created_time.isoformat() + "Z"
            if copied_file.created_time
            else None,
            "modifiedTime": copied_file.modified_time.isoformat() + "Z"
            if copied_file.modified_time
            else None,
            "viewedByMeTime": copied_file.viewed_by_me_time.isoformat() + "Z"
            if copied_file.viewed_by_me_time
            else None,
            "trashedTime": copied_file.trashed_time.isoformat() + "Z"
            if copied_file.trashed_time
            else None,
            "starred": copied_file.starred,
            "trashed": copied_file.trashed,
            "properties": copied_file.properties,
            "shortcutTargetId": copied_file.shortcut_target_id,
            "shortcutTargetMimeType": copied_file.shortcut_target_mime,
            "kind": "drive#file",
            "version": str(getattr(copied_file, "version", 1)),
            "ownedByMe": copied_file.created_by == current_user.id,
            "modifiedByMe": copied_file.modified_by == current_user.id,
            "viewedByMe": copied_file.viewed_by_me_time is not None,
            "shared": False,  # Simplified - would need permission checking
            "copyRequiresWriterPermission": False,
            "writersCanShare": True,
            "hasThumbnail": False,
            "iconLink": f"https://drive.google.com/thumbnail?id={copied_file.id}&sz=w16-h16",
            "webViewLink": f"https://drive.google.com/file/d/{copied_file.id}/view",
            "webContentLink": f"https://drive.google.com/uc?id={copied_file.id}&export=download",
        }

        # Add owner information
        if owner:
            file_response["owners"] = [
                {
                    "kind": "drive#user",
                    "displayName": owner.display_name,
                    "photoLink": owner.photo_url,
                    "me": owner.id == current_user.id,
                    "permissionId": owner.id,
                    "emailAddress": owner.email,
                }
            ]

        return {
            "success": True,
            "file": file_response,
            "message": f"File '{fileId}' copied successfully as '{copied_file.name}'",
        }

    except HTTPException:
        raise
    except SQLAlchemyError as e:
        logger.error(f"Database error copying file {fileId}: {str(e)}")
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to copy file: {str(e)}")
    except Exception as e:
        logger.error(f"Error copying file {fileId}: {str(e)}")
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to copy file: {str(e)}")


# ----------------------------
# Endpoint: files.update
# ----------------------------
@files_router.patch(
    "/files/{fileId}",
    status_code=status.HTTP_200_OK,
    response_model=FileResponse,
)
def update_files(
    request: Request,
    fileId: str = Path(..., description="The ID of the file to update"),
    addParents: Optional[str] = Query(
        None, description="A comma-separated list of parent IDs to add"
    ),
    enforceSingleParent: Optional[bool] = Query(
        None,
        description="Deprecated: Adding files to multiple folders is no longer supported. Use shortcuts instead.",
    ),
    keepRevisionForever: Optional[bool] = Query(
        None,
        description="Whether to set the keepForever field in the new head revision",
    ),
    ocrLanguage: Optional[str] = Query(
        None,
        description="A language hint for OCR processing during image import (ISO 639-1 code)",
    ),
    removeParents: Optional[str] = Query(
        None, description="A comma-separated list of parent IDs to remove"
    ),
    supportsAllDrives: bool = Query(
        True,
        description="Whether the requesting application supports both My Drives and shared drives",
    ),
    supportsTeamDrives: Optional[bool] = Query(
        None, description="Deprecated: Use supportsAllDrives instead"
    ),
    uploadType: Optional[str] = Query(
        None, description="The type of upload request to the /upload URI"
    ),
    useContentAsIndexableText: Optional[bool] = Query(
        None, description="Whether to use the uploaded content as indexable text"
    ),
    includePermissionsForView: Optional[str] = Query(
        None,
        description="Specifies which additional view's permissions to include in the response. Only published is supported",
    ),
    includeLabels: Optional[str] = Query(
        None,
        description="A comma-separated list of IDs of labels to include in the labelInfo part of the response",
    ),
    update_data: FilesUpdateRequest = Body(
        ...,
        description="The file metadata to update. At least one field must be provided.",
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db_for_session),
):
    try:
        logger.info(f"Updating file {fileId} for user {current_user.id}")

        # Find the file
        file_obj = db.query(File).filter(File.id == fileId).first()
        if not file_obj:
            raise HTTPException(status_code=404, detail=f"File '{fileId}' not found")

        # Permission check - user must own the file or have write access
        if file_obj.created_by != current_user.id:
            # Check if user has write permission through shared access

            has_permission = (
                db.query(Permission)
                .filter(
                    Permission.file_id == fileId,
                    Permission.user_id == current_user.id,
                    Permission.role.in_(["writer", "owner"]),
                )
                .first()
            )

            if not has_permission:
                raise HTTPException(
                    status_code=403,
                    detail=f"User {current_user.id} does not have permission to update file {fileId}",
                )
            logger.info(
                f"User {current_user.id} updating file {fileId} with shared access"
            )

        updated_fields = []

        # === Metadata updates ===
        if update_data and update_data.name is not None:
            file_obj.name = _sanitize_filename(update_data.name)
            updated_fields.append("name")

        if update_data and update_data.description is not None:
            file_obj.description = update_data.description
            updated_fields.append("description")

        if update_data and update_data.starred is not None:
            file_obj.starred = update_data.starred
            updated_fields.append("starred")

        if update_data and update_data.trashed is not None:
            file_obj.trashed = update_data.trashed
            file_obj.trashed_time = datetime.utcnow() if update_data.trashed else None
            updated_fields.append("trashed")

        if update_data and update_data.properties is not None:
            if file_obj.properties is None:
                file_obj.properties = {}
            file_obj.properties.update(update_data.properties)
            # Flag the JSON field as modified so SQLAlchemy detects the change
            flag_modified(file_obj, "properties")
            updated_fields.append("properties")

        if update_data and update_data.appProperties is not None:
            file_obj.app_properties = update_data.appProperties
            updated_fields.append("appProperties")

        # === Additional metadata fields ===
        if update_data and update_data.writersCanShare is not None:
            file_obj.writers_can_share = update_data.writersCanShare
            updated_fields.append("writersCanShare")

        if update_data and update_data.mimeType is not None:
            # Validate MIME type if it's a Google-native type
            if update_data.mimeType.startswith("application/vnd.google-apps."):
                allowed_google_mimes = {m.value for m in GoogleDriveMimeTypes}
                if update_data.mimeType not in allowed_google_mimes:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Invalid google mimeType: {update_data.mimeType}",
                    )
            file_obj.mime_type = update_data.mimeType
            updated_fields.append("mimeType")

        if update_data and update_data.folderColorRgb is not None:
            file_obj.folder_color_rgb = update_data.folderColorRgb
            updated_fields.append("folderColorRgb")

        if update_data and update_data.originalFilename is not None:
            file_obj.original_filename = update_data.originalFilename
            updated_fields.append("originalFilename")

        if update_data and update_data.inheritedPermissionsDisabled is not None:
            file_obj.inherited_permissions_disabled = (
                update_data.inheritedPermissionsDisabled
            )
            updated_fields.append("inheritedPermissionsDisabled")

        # === Content restrictions ===
        if update_data and update_data.contentRestrictions is not None:
            if file_obj.properties is None:
                file_obj.properties = {}
            file_obj.properties["contentRestrictions"] = [
                {
                    "readOnly": cr.readOnly,
                    "reason": cr.reason,
                    "ownerRestricted": cr.ownerRestricted,
                    "systemRestricted": cr.systemRestricted,
                }
                for cr in update_data.contentRestrictions
            ]
            # Flag the JSON field as modified so SQLAlchemy detects the change
            flag_modified(file_obj, "properties")
            updated_fields.append("contentRestrictions")

        # === Copy requires writer permission ===
        if update_data and update_data.copyRequiresWriterPermission is not None:
            file_obj.copy_requires_writer_permission = (
                update_data.copyRequiresWriterPermission
            )
            updated_fields.append("copyRequiresWriterPermission")

        # === Content hints ===
        if update_data and update_data.contentHints is not None:
            if file_obj.properties is None:
                file_obj.properties = {}
            file_obj.properties["contentHints"] = {
                "indexableText": update_data.contentHints.indexableText,
                "thumbnail": update_data.contentHints.thumbnail,
            }
            # Flag the JSON field as modified so SQLAlchemy detects the change
            flag_modified(file_obj, "properties")
            updated_fields.append("contentHints")

        # === Download restrictions ===
        if update_data and update_data.downloadRestrictions is not None:
            file_obj.download_restricted_for_readers = (
                update_data.downloadRestrictions.restricted
            )
            file_obj.download_restricted_for_writers = (
                update_data.downloadRestrictions.restricted
            )
            updated_fields.append("downloadRestrictions")

        # === Shortcut details ===
        if update_data and update_data.shortcutDetails is not None:
            file_obj.shortcut_target_id = update_data.shortcutDetails.targetId
            updated_fields.append("shortcutDetails")

        # === Parent updates from request body ===
        if (
            update_data
            and update_data.parents is not None
            and len(update_data.parents) > 0
        ):
            # Validate all parent folders exist and are folders
            valid_parents = []
            for parent_id in update_data.parents:
                parent_file = db.query(File).filter(File.id == parent_id).first()
                if (
                    parent_file
                    and parent_file.mime_type == "application/vnd.google-apps.folder"
                ):
                    valid_parents.append(parent_id)
                else:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Parent folder '{parent_id}' not found or not a folder",
                    )

            file_obj.parent_ids = valid_parents
            # Keep parent_id in sync (first parent in the list, or None if empty)
            file_obj.parent_id = valid_parents[0] if valid_parents else None
            updated_fields.append(f"parents:{','.join(valid_parents)}")

        # === Parent updates via query parameters ===
        if addParents:
            # Parse comma-separated parent IDs
            parent_ids_to_add = [
                pid.strip() for pid in addParents.split(",") if pid.strip()
            ]
            current_parents = file_obj.parent_ids or []

            # Validate all parent folders exist and are folders
            valid_new_parents = []
            for parent_id in parent_ids_to_add:
                parent_file = db.query(File).filter(File.id == parent_id).first()
                if (
                    parent_file
                    and parent_file.mime_type == "application/vnd.google-apps.folder"
                    and parent_id not in current_parents
                ):
                    valid_new_parents.append(parent_id)
                elif parent_id in current_parents:
                    continue  # Already a parent, skip
                else:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Parent folder '{parent_id}' not found or not a folder",
                    )

            # Add new parents to existing ones
            file_obj.parent_ids = current_parents + valid_new_parents
            # Keep parent_id in sync (first parent in the list, or None if empty)
            file_obj.parent_id = file_obj.parent_ids[0] if file_obj.parent_ids else None
            updated_fields.append(f"addParents:{','.join(valid_new_parents)}")

        if removeParents:
            # Parse comma-separated parent IDs to remove
            parent_ids_to_remove = [
                pid.strip() for pid in removeParents.split(",") if pid.strip()
            ]
            current_parents = file_obj.parent_ids or []

            # Remove specified parents
            file_obj.parent_ids = [
                pid for pid in current_parents if pid not in parent_ids_to_remove
            ]
            # Keep parent_id in sync (first parent in the list, or None if empty)
            file_obj.parent_id = file_obj.parent_ids[0] if file_obj.parent_ids else None
            updated_fields.append(f"removeParents:{','.join(parent_ids_to_remove)}")

        # === System fields ===
        file_obj.modified_time = datetime.utcnow()
        file_obj.modified_by = current_user.id
        updated_fields.extend(["modified_time", "modified_by"])

        # Save changes
        try:
            db.commit()
            db.refresh(file_obj)
            logger.info(
                f"Successfully updated file {fileId}. Updated fields: {updated_fields}"
            )
        except SQLAlchemyError as e:
            db.rollback()
            logger.error(f"Database error updating file {fileId}: {str(e)}")
            raise HTTPException(
                status_code=500, detail=f"Failed to update file: {str(e)}"
            )

        # Owner and modifier info
        owner = db.query(User).filter(User.id == file_obj.created_by).first()
        last_modifying_user = (
            db.query(User).filter(User.id == file_obj.modified_by).first()
            if file_obj.modified_by
            else None
        )

        # Build complete FileResponse
        file_response = {
            "id": file_obj.id,
            "name": file_obj.name,
            "mimeType": file_obj.mime_type,
            "description": file_obj.description,
            "fileExtension": file_obj.file_extension,
            "fullFileExtension": file_obj.full_file_extension,
            "originalFilename": getattr(file_obj, "original_filename", None),
            "size": str(file_obj.size_bytes) if file_obj.size_bytes else "0",
            "md5Checksum": file_obj.md5_checksum,
            "sha1Checksum": getattr(file_obj, "sha1_checksum", None),
            "sha256Checksum": getattr(file_obj, "sha256_checksum", None),
            "createdTime": file_obj.created_time.isoformat() + "Z"
            if file_obj.created_time
            else None,
            "modifiedTime": file_obj.modified_time.isoformat() + "Z"
            if file_obj.modified_time
            else None,
            "modifiedByMeTime": getattr(file_obj, "modified_by_me_time", None),
            "viewedByMeTime": file_obj.viewed_by_me_time.isoformat() + "Z"
            if file_obj.viewed_by_me_time
            else None,
            "sharedWithMeTime": getattr(file_obj, "shared_with_me_time", None),
            "trashedTime": file_obj.trashed_time.isoformat() + "Z"
            if file_obj.trashed_time
            else None,
            "starred": file_obj.starred,
            "trashed": file_obj.trashed,
            # FIX (gym-patch): these columns EXIST but are NULL in typical seeds, so getattr returns
            # None (not the default) and the strict-bool FileResponse model raised ResponseValidationError
            # AFTER db.commit() — a masked 500 on every successful update. Coerce None to a real bool.
            "explicitlyTrashed": bool(getattr(file_obj, "explicitly_trashed", False) or False),
            "viewedByMe": file_obj.viewed_by_me_time is not None,
            "modifiedByMe": file_obj.modified_by == current_user.id,
            "ownedByMe": file_obj.created_by == current_user.id,
            "shared": bool(getattr(file_obj, "shared", False) or False),
            "copyRequiresWriterPermission": file_obj.copy_requires_writer_permission
            or False,
            "writersCanShare": bool(getattr(file_obj, "writers_can_share", True)) if getattr(file_obj, "writers_can_share", True) is not None else True,
            "hasThumbnail": getattr(file_obj, "has_thumbnail", False),
            "thumbnailVersion": getattr(file_obj, "thumbnail_version", None),
            "thumbnailLink": getattr(file_obj, "thumbnail_link", None),
            "iconLink": getattr(file_obj, "icon_link", None)
            or f"https://drive.google.com/thumbnail?id={file_obj.id}&sz=w16-h16",
            "webViewLink": getattr(file_obj, "web_view_link", None)
            or f"https://drive.google.com/file/d/{file_obj.id}/view",
            "webContentLink": getattr(file_obj, "web_content_link", None)
            or f"https://drive.google.com/uc?id={file_obj.id}&export=download",
            "folderColorRgb": getattr(file_obj, "folder_color_rgb", None),
            "contentRestricted": getattr(file_obj, "content_restricted", False),
            "contentRestrictionReason": getattr(
                file_obj, "content_restriction_reason", None
            ),
            "contentRestrictionTime": getattr(
                file_obj, "content_restriction_time", None
            ),
            "ownerRestricted": getattr(file_obj, "owner_restricted", False),
            "systemRestricted": getattr(file_obj, "system_restricted", False),
            "downloadRestrictedForReaders": file_obj.download_restricted_for_readers
            or False,
            "downloadRestrictedForWriters": file_obj.download_restricted_for_writers
            or False,
            "resourceKey": getattr(file_obj, "resource_key", None),
            "securityUpdateEligible": getattr(
                file_obj, "security_update_eligible", False
            ),
            "securityUpdateEnabled": getattr(
                file_obj, "security_update_enabled", False
            ),
            "inheritedPermissionsDisabled": getattr(
                file_obj, "inherited_permissions_disabled", False
            ),
            "hasAugmentedPermissions": getattr(
                file_obj, "has_augmented_permissions", False
            ),
            "version": str(getattr(file_obj, "version", 1)),
            "headRevisionId": getattr(file_obj, "head_revision_id", None),
            "quotaBytesUsed": str(getattr(file_obj, "quota_bytes_used", 0))
            if getattr(file_obj, "quota_bytes_used", None) is not None
            else None,
            "imageMediaMetadata": getattr(file_obj, "image_media_metadata", None),
            "videoMediaMetadata": getattr(file_obj, "video_media_metadata", None),
            "properties": file_obj.properties,
            "appProperties": file_obj.app_properties,
            "shortcutTargetId": file_obj.shortcut_target_id,
            "shortcutTargetMimeType": file_obj.shortcut_target_mime,
            "shortcutTargetResourceKey": getattr(
                file_obj, "shortcut_target_resource_key", None
            ),
            "kind": file_obj.kind,
            "driveId": file_obj.drive_id,
            # Use parent_ids (JSON array) if available, filter out None values, otherwise fall back to parent_id
            "parents": (
                [p for p in file_obj.parent_ids if p is not None]
                if file_obj.parent_ids and isinstance(file_obj.parent_ids, list)
                else ([file_obj.parent_id] if file_obj.parent_id else [])
            ),
        }

        if owner:
            file_response["owners"] = [
                {
                    "kind": "drive#user",
                    "displayName": owner.display_name,
                    "photoLink": owner.photo_url,
                    "me": owner.id == current_user.id,
                    "permissionId": owner.id,
                    "emailAddress": owner.email,
                }
            ]

        if last_modifying_user:
            file_response["lastModifyingUser"] = {
                "kind": "drive#user",
                "displayName": last_modifying_user.display_name,
                "photoLink": last_modifying_user.photo_url,
                "me": last_modifying_user.id == current_user.id,
                "permissionId": last_modifying_user.id,
                "emailAddress": last_modifying_user.email,
            }

        # Add sharingUser and trashingUser (null for now)
        file_response["sharingUser"] = None
        file_response["trashingUser"] = None

        return file_response

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating file {fileId}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to update file: {str(e)}")
