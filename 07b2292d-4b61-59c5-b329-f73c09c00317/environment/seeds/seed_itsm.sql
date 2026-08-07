INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES
('ORG_V12_ESC', 'Northstar Edge Operations', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO role (role_id, name) VALUES
('ROLE_V12_ESC_ADMIN', 'admin');

INSERT INTO permission (perm_id, resource, action) VALUES
('PERM_V12_ESC_CI_READ', 'configuration_items', 'read'),
('PERM_V12_ESC_CHANGE_CRUD', 'changes', 'crud'),
('PERM_V12_ESC_INC_READ', 'incidents', 'read'),
('PERM_V12_ESC_INC_CRUD', 'incidents', 'crud');

INSERT INTO role_permission (role_id, perm_id) VALUES
('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_CI_READ'),
('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_CHANGE_CRUD'),
('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_INC_READ'),
('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_INC_CRUD');

INSERT INTO location (
  location_id, name, org_id, plot_no, street, city, state, country,
  active, created_on, updated_on
) VALUES
('LOC_V12_ESC', 'Northstar Edge Site', 'ORG_V12_ESC', '417', 'Relay Way',
 'Pune', 'Maharashtra', 'India', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO users (
  user_id, user_name, first_name, last_name, email, phone, role, active,
  static_token, org_id, location_id, created_on, updated_on
) VALUES
('USER_V12_ESC', 'rina.shah', 'Rina', 'Shah', 'rina.shah@northstar.example',
 '+91-90000-00417', 'admin', TRUE, 'itsm_v12_escalation_token',
 'ORG_V12_ESC', 'LOC_V12_ESC', '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO user_role (user_id, role_id, org_id) VALUES
('USER_V12_ESC', 'ROLE_V12_ESC_ADMIN', 'ORG_V12_ESC');

INSERT INTO configuration_item (
  configuration_item_id, name, serial_number, owner_id, location_id, org_id,
  status, cost, created_on, updated_on
) VALUES
('CI_V12_EDGE_417', 'Regulated Edge Gateway 417', 'SRV-EDGE-417',
 'USER_V12_ESC', 'LOC_V12_ESC', 'ORG_V12_ESC', 'in_use', 41700.00,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
('CI_V12_EDGE_410', 'Neighbour Edge Gateway 410', 'SRV-EDGE-410',
 'USER_V12_ESC', 'LOC_V12_ESC', 'ORG_V12_ESC', 'in_use', 41000.00,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO incident (
  incident_id, number, short_description, caller_id, configuration_item, org_id,
  channel, contact_type, status, category, description, worknotes, impact,
  urgency, priority, on_hold_reason, created_at, updated_at
) VALUES
('INC_V12_ESC_NEW', 'INC-V12-0417-A', 'Edge telemetry loss', 'USER_V12_ESC',
 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'web', 'portal', 'new', 'network',
 'Regulated edge telemetry is intermittent', '', 'high', 'high', 'critical',
 NULL, '2026-07-20 09:15:00', '2026-07-20 09:15:00'),
('INC_V12_ESC_PROGRESS', 'INC-V12-0417-B', 'Edge routing degradation', 'USER_V12_ESC',
 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'phone', 'phone', 'in_progress', 'network',
 'Regulated edge routes are degrading', '', 'high', 'high', 'critical',
 NULL, '2026-07-20 09:20:00', '2026-07-20 09:20:00'),
('INC_V12_ESC_HOLD', 'INC-V12-0417-C', 'Edge maintenance prerequisite', 'USER_V12_ESC',
 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'email', 'email', 'on_hold', 'hardware',
 'Regulated edge awaits coordinated maintenance', '', 'medium', 'high', 'high',
 'Awaiting Change', '2026-07-20 09:25:00', '2026-07-20 09:25:00'),
('INC_V12_ESC_RESOLVED', 'INC-V12-0417-D', 'Historical edge alert', 'USER_V12_ESC',
 'CI_V12_EDGE_417', 'ORG_V12_ESC', 'web', 'portal', 'resolved', 'network',
 'Historical alert is already resolved', 'Closed before this escalation', 'low',
 'low', 'low', NULL, '2026-07-18 09:00:00', '2026-07-19 09:00:00'),
('INC_V12_ESC_NEIGHBOUR', 'INC-V12-0410-A', 'Neighbour gateway alert', 'USER_V12_ESC',
 'CI_V12_EDGE_410', 'ORG_V12_ESC', 'web', 'portal', 'new', 'network',
 'Neighbouring edge alert', 'Neighbour must remain untouched', 'medium', 'medium',
 'moderate', NULL, '2026-07-20 09:30:00', '2026-07-20 09:30:00');
