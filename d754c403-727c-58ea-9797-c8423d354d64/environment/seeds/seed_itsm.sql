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
('inc_offboarding_tracker', 'INC-OFFB-2207', 'Edge telemetry loss', 'USER_V12_ESC',
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

-- v13 task 01: 18 pre-existing changes so the offboarding change mints CHG0000019
INSERT INTO change (change_id, number, short_description, requested_by, org_id, status, category, impact, priority, risk, cab_required, created_on, updated_on) VALUES
('CHG_SEED_01', 'CHG0000001', 'Backlog change 1', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_02', 'CHG0000002', 'Backlog change 2', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_03', 'CHG0000003', 'Backlog change 3', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_04', 'CHG0000004', 'Backlog change 4', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_05', 'CHG0000005', 'Backlog change 5', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_06', 'CHG0000006', 'Backlog change 6', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_07', 'CHG0000007', 'Backlog change 7', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_08', 'CHG0000008', 'Backlog change 8', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_09', 'CHG0000009', 'Backlog change 9', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_10', 'CHG0000010', 'Backlog change 10', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_11', 'CHG0000011', 'Backlog change 11', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_12', 'CHG0000012', 'Backlog change 12', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_13', 'CHG0000013', 'Backlog change 13', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_14', 'CHG0000014', 'Backlog change 14', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_15', 'CHG0000015', 'Backlog change 15', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_16', 'CHG0000016', 'Backlog change 16', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_17', 'CHG0000017', 'Backlog change 17', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
('CHG_SEED_18', 'CHG0000018', 'Backlog change 18', 'USER_V12_ESC', 'ORG_V12_ESC', 'assess', 'other', 'high', 'high', 'high', FALSE, '2026-07-01 09:00:00', '2026-07-01 09:00:00');

-- v13 task 01: grant users/read so get_user is exercisable by the acting admin
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_V12_ESC_USERS_READ', 'users', 'read');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_USERS_READ');

-- v13 task 01: grant knowledge/read so a bare retrieve_knowledge_articles probe on ITSM does not trap V4
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_V12_ESC_KB_READ', 'knowledge', 'read');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_V12_ESC_ADMIN', 'PERM_V12_ESC_KB_READ');
