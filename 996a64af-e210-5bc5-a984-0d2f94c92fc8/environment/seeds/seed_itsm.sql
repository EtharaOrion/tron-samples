INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES
('ORG_V12_ENT', 'Northstar Entitlement Operations', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO role (role_id, name) VALUES
('ROLE_V12_ENT_ADMIN', 'admin');

INSERT INTO permission (perm_id, resource, action) VALUES
('PERM_V12_ENT_CI_READ', 'configuration_items', 'read'),
('PERM_V12_ENT_CI_CRUD', 'configuration_items', 'crud');

INSERT INTO role_permission (role_id, perm_id) VALUES
('ROLE_V12_ENT_ADMIN', 'PERM_V12_ENT_CI_READ'),
('ROLE_V12_ENT_ADMIN', 'PERM_V12_ENT_CI_CRUD');

INSERT INTO location (
  location_id, name, org_id, plot_no, street, city, state, country,
  active, created_on, updated_on
) VALUES
('LOC_V12_ENT', 'Aurora Transit Control', 'ORG_V12_ENT', '9007', 'Entitlement Road',
 'Bengaluru', 'Karnataka', 'India', TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO users (
  user_id, user_name, first_name, last_name, email, phone, role, active,
  static_token, org_id, location_id, created_on, updated_on
) VALUES
('USER_V12_ENT', 'maya.chen', 'Maya', 'Chen', 'maya.chen@northstar.example',
 '+91-90000-09007', 'admin', TRUE, 'itsm_v12_entitlement_token',
 'ORG_V12_ENT', 'LOC_V12_ENT', '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO user_role (user_id, role_id, org_id) VALUES
('USER_V12_ENT', 'ROLE_V12_ENT_ADMIN', 'ORG_V12_ENT');

INSERT INTO configuration_item (
  configuration_item_id, name, serial_number, owner_id, location_id, org_id,
  status, cost, created_on, updated_on
) VALUES
('CI_V12_ENT_9007', 'Aurora TransitEdge Controller', 'ENT-AX-9007',
 'USER_V12_ENT', 'LOC_V12_ENT', 'ORG_V12_ENT', 'in_use', 48000.00,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
('CI_V12_ENT_9008', 'Aurora Logistics Controller', 'ENT-AX-9008',
 'USER_V12_ENT', 'LOC_V12_ENT', 'ORG_V12_ENT', 'in_use', 48000.00,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00');
