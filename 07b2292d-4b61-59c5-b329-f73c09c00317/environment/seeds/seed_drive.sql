INSERT INTO users (id, display_name, email, photo_url, auth_token, created_time, kind, permission_id, me) VALUES
('DRV_USER_V12_ESC', 'Rina Shah', 'rina.shah@northstar.example', NULL, 'drive_v12_escalation_token', '2026-07-20 09:00:00', 'drive#user', 'DRV_PERM_USER_V12_ESC', TRUE);

INSERT INTO drives (
  id, name, color_rgb, theme_id, background_image_link, hidden,
  restricted_to_domain, trashed, created_time, modified_time,
  copy_requires_writer_permission, domain_users_only, drive_members_only,
  admin_managed_restrictions, sharing_folders_requires_organizer_permission,
  download_restricted_for_readers, download_restricted_for_writers,
  org_unit_id, kind
) VALUES
('DRV_V12_ESC', 'Operations Standards', '#4285F4', NULL, NULL, FALSE, TRUE, FALSE,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00', FALSE, FALSE, FALSE, FALSE,
 FALSE, FALSE, FALSE, NULL, 'drive#drive');

INSERT INTO drive_memberships (id, drive_id, type, user_id, group_id, domain, role, created_time) VALUES
('DRV_MEM_V12_ESC', 'DRV_V12_ESC', 'user', 'DRV_USER_V12_ESC', NULL, NULL, 'organizer', '2026-07-20 09:05:00');

INSERT INTO files (
  id, drive_id, name, mime_type, size_bytes, description, parent_id, parent_ids,
  starred, trashed, created_by, modified_by, created_time, modified_time,
  properties, app_properties, is_shortcut, shortcut_target_id,
  shortcut_target_mime, kind, shared, owned_by_me, viewed_by_me,
  modified_by_me, explicitly_trashed, writers_can_share, version,
  quota_bytes_used, space
) VALUES
('DRV_FILE_V12_STANDARD_27', 'DRV_V12_ESC', 'V12 Change Routing Standard 27',
 'text/plain', 1240,
 'R1 Select the configuration item serial from appProperties.selected_serial. R2 For a regulated edge target, the in-scope incident set is every incident on that resolved configuration item whose status is new, in_progress, or on_hold. R3 R2 overrides any single-container shortcut and incidents on another configuration item or in resolved status are excluded. R4 Create exactly one change with short description Regulated edge maintenance for selected configuration item, status assess, impact high, risk high, priority critical, category hardware, and cab_required true. R5 Update every in-scope incident with the created change reference and work note Escalated under V12 Change Routing Standard 27. R6 Send exactly one Teams channel message to team TEAM_V12_ESC and channel CHAN_V12_ESC with content Regulated edge escalation target <resolved_serial>, replacing the token with the byte-exact ITSM-returned serial. For this selected file the exact rendered message is Regulated edge escalation target SRV-EDGE-417.',
 NULL, '[]', FALSE, FALSE, 'DRV_USER_V12_ESC', 'DRV_USER_V12_ESC',
 '2026-07-20 09:10:00', '2026-07-20 09:10:00', '{}',
 '{"selected_serial":"SRV-EDGE-417","team_id":"TEAM_V12_ESC","channel_id":"CHAN_V12_ESC"}',
 FALSE, NULL, NULL, 'drive#file', TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, 1, 1240, 'drive');

INSERT INTO file_owners (file_id, user_id, created_time) VALUES
('DRV_FILE_V12_STANDARD_27', 'DRV_USER_V12_ESC', '2026-07-20 09:10:00');

INSERT INTO change_tokens (scope, last_token) VALUES
('user', '1'),
('DRV_V12_ESC', '1');
