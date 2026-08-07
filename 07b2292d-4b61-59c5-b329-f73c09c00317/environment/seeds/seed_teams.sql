INSERT INTO teams_orgs (
  org_id, tenant_id, display_name, domain_name, country_letter_code,
  preferred_language, created_at, updated_at, soft_deleted
) VALUES
('TEAMS_ORG_V12_ESC', 'TENANT_V12_ESC', 'Northstar Operations',
 'northstar.example', 'IN', 'en-IN', '2026-07-20 09:00:00',
 '2026-07-20 09:00:00', FALSE);

INSERT INTO teams_users (
  org_id, user_id, display_name, mail, static_token, job_title, department,
  account_enabled, soft_deleted, created_at, updated_at
) VALUES
('TEAMS_ORG_V12_ESC', 'TEAMS_USER_V12_ESC', 'Rina Shah',
 'rina.shah@northstar.example', 'teams_v12_escalation_token',
 'Edge Operations Lead', 'Operations', TRUE, FALSE,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO permissions_catalog (
  id, name, type, admin_consent_required, description, resource, operation,
  category, permission_level_rank, requires_resource_ownership,
  applies_to_scope, created_at, updated_at
) VALUES
('ChannelMessage.Send:delegated', 'ChannelMessage.Send', 'delegated', FALSE,
 'Send channel messages', 'ChannelMessage', 'Send', 'communication', 30, TRUE,
 'own',
 '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO user_permissions (
  org_id, user_id, permission_id, granted_at, granted_by
) VALUES
('TEAMS_ORG_V12_ESC', 'TEAMS_USER_V12_ESC', 'ChannelMessage.Send:delegated',
 '2026-07-20 09:00:00', 'system');

INSERT INTO module_permissions (module_name, permission_id, created_at) VALUES
('channels', 'ChannelMessage.Send:delegated', '2026-07-20 09:00:00');

INSERT INTO teams_user_roles (
  org_id, user_id, role_id, role_name, assigned_at, assigned_by
) VALUES
('TEAMS_ORG_V12_ESC', 'TEAMS_USER_V12_ESC', 'member', 'member',
 '2026-07-20 09:00:00', 'system');

INSERT INTO teams (
  org_id, team_id, display_name, description, visibility, specialization,
  internal_id, is_archived, migration_mode, created_date_time,
  updated_date_time, soft_delete
) VALUES
('TEAMS_ORG_V12_ESC', 'TEAM_V12_ESC', 'Regulated Edge Operations',
 'Regulated edge coordination', 'private', 'none', 'TEAM_V12_ESC_INTERNAL',
 FALSE, 'none', '2026-07-20 09:00:00', '2026-07-20 09:00:00', FALSE);

INSERT INTO channels (
  channel_id, org_id, team_id, display_name, description, membership_type,
  is_favorite_by_default, is_archived, migration_mode, created_date_time,
  soft_delete
) VALUES
('CHAN_V12_ESC', 'TEAMS_ORG_V12_ESC', 'TEAM_V12_ESC', 'escalations',
 'Regulated edge escalation channel', 'standard', TRUE, FALSE, NULL,
 '2026-07-20 09:00:00', FALSE);

INSERT INTO channel_members (
  channel_id, user_id, roles, display_name, email, tenant_id, added_at
) VALUES
('CHAN_V12_ESC', 'TEAMS_USER_V12_ESC', 'owner', 'Rina Shah',
 'rina.shah@northstar.example', 'TENANT_V12_ESC', '2026-07-20 09:00:00');
