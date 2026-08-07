INSERT INTO users (id, display_name, email, photo_url, auth_token, created_time, kind, permission_id, me) VALUES
('DRV_USER_V12_ENT', 'Maya Chen', 'maya.chen@northstar.example', NULL,
 'drive_v12_entitlement_token', '2026-07-20 09:00:00', 'drive#user',
 'DRV_PERM_USER_V12_ENT', TRUE);

INSERT INTO drives (
  id, name, color_rgb, theme_id, background_image_link, hidden,
  restricted_to_domain, trashed, created_time, modified_time,
  copy_requires_writer_permission, domain_users_only, drive_members_only,
  admin_managed_restrictions, sharing_folders_requires_organizer_permission,
  download_restricted_for_readers, download_restricted_for_writers,
  org_unit_id, kind
) VALUES
('DRV_V12_ENT', 'Entitlement Evidence', '#34A853', NULL, NULL, FALSE, TRUE, FALSE,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00', FALSE, FALSE, FALSE, FALSE,
 FALSE, FALSE, FALSE, NULL, 'drive#drive');

INSERT INTO drive_memberships (id, drive_id, type, user_id, group_id, domain, role, created_time) VALUES
('DRV_MEM_V12_ENT', 'DRV_V12_ENT', 'user', 'DRV_USER_V12_ENT', NULL, NULL,
 'organizer', '2026-07-20 09:05:00');

INSERT INTO files (
  id, drive_id, name, mime_type, size_bytes, description, parent_id, parent_ids,
  starred, trashed, created_by, modified_by, created_time, modified_time,
  properties, app_properties, is_shortcut, shortcut_target_id,
  shortcut_target_mime, kind, shared, owned_by_me, viewed_by_me,
  modified_by_me, explicitly_trashed, writers_can_share, version,
  quota_bytes_used, space
) VALUES
('DRV_FILE_V12_ENT_DECOY', 'DRV_V12_ENT', 'ENT-AX-9008', 'text/plain', 64,
 'Pre-existing evidence for the neighbouring account', NULL, '[]', FALSE, FALSE,
 'DRV_USER_V12_ENT', 'DRV_USER_V12_ENT', '2026-07-19 09:00:00',
 '2026-07-19 09:00:00', '{}', '{}', FALSE, NULL, NULL, 'drive#file', TRUE, TRUE,
 TRUE, TRUE, FALSE, TRUE, 1, 64, 'drive');

INSERT INTO file_owners (file_id, user_id, created_time) VALUES
('DRV_FILE_V12_ENT_DECOY', 'DRV_USER_V12_ENT', '2026-07-19 09:00:00');

INSERT INTO permissions (
  id, file_id, drive_id, role, type, user_id, group_id, email_address, domain,
  allow_file_discovery, kind, deleted, view, created_time, updated_time, inherited
) VALUES
('DRV_PERMISSION_V12_ENT_DECOY', 'DRV_FILE_V12_ENT_DECOY', NULL, 'owner', 'user',
 'DRV_USER_V12_ENT', NULL, NULL, NULL, FALSE, 'drive#permission', FALSE,
 'published', '2026-07-19 09:00:00', '2026-07-19 09:00:00', FALSE);

INSERT INTO change_tokens (scope, last_token) VALUES
('user', '1'),
('DRV_V12_ENT', '1');
