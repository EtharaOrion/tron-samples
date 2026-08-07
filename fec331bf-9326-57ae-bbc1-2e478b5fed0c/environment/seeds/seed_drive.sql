INSERT INTO users (id, display_name, email, photo_url, auth_token, created_time, kind, permission_id, me) VALUES
('DRV_USER_T02', 'Rina Shah', 'rina.shah@northstar.example', NULL, 'drive_v12_escalation_token', '2026-07-20 09:00:00', 'drive#user', 'DRV_PERM_USER_T02', TRUE);
INSERT INTO drives (id, name, color_rgb, theme_id, background_image_link, hidden, restricted_to_domain, trashed, created_time, modified_time, copy_requires_writer_permission, domain_users_only, drive_members_only, admin_managed_restrictions, sharing_folders_requires_organizer_permission, download_restricted_for_readers, download_restricted_for_writers, org_unit_id, kind) VALUES
('DRV_T02', 'Operations Standards', '#4285F4', NULL, NULL, FALSE, TRUE, FALSE, '2026-07-20 09:00:00', '2026-07-20 09:00:00', FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, NULL, 'drive#drive');
INSERT INTO drive_memberships (id, drive_id, type, user_id, group_id, domain, role, created_time) VALUES
('DRV_MEM_T02', 'DRV_T02', 'user', 'DRV_USER_T02', NULL, NULL, 'organizer', '2026-07-20 09:05:00');
INSERT INTO files (id, drive_id, name, mime_type, size_bytes, description, parent_id, parent_ids, starred, trashed, created_by, modified_by, created_time, modified_time, properties, app_properties, is_shortcut, shortcut_target_id, shortcut_target_mime, kind, shared, owned_by_me, viewed_by_me, modified_by_me, explicitly_trashed, writers_can_share, version, quota_bytes_used, space) VALUES
('DRV_FILE_ROUTING_STD', 'DRV_T02', 'Change Routing Standard', 'text/plain', 1180,
 'R1 General rule. A standard-tier network device change is routed as a normal change with no special handling. R2 Exception. A regulated grid gateway is a special-handling target and its device serial for this cycle is recorded in appProperties.policy_serial. The routing change for a regulated grid gateway must be raised carrying the installed-product identifier that the customer-service system returns for that serial, never the serial itself. R3 Precedence. Where both R1 and R2 match, R2 overrides R1. For this cycle the regulated grid gateway is in scope and the policy serial is GRD-NX-4471.',
 NULL, '[]', FALSE, FALSE, 'DRV_USER_T02', 'DRV_USER_T02', '2026-07-20 09:10:00', '2026-07-20 09:10:00', '{}',
 '{"policy_serial":"GRD-NX-4471"}',
 FALSE, NULL, NULL, 'drive#file', TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, 1, 1180, 'drive');
INSERT INTO file_owners (file_id, user_id, created_time) VALUES ('DRV_FILE_ROUTING_STD', 'DRV_USER_T02', '2026-07-20 09:10:00');
INSERT INTO change_tokens (scope, last_token) VALUES ('user', '1'), ('DRV_T02', '1');
