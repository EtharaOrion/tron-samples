-- MCP Server: sn-itsm-internal
INSERT INTO organization (org_id, name, active) VALUES ('org_acme', 'Acme Corporation', 1);

INSERT INTO role (role_id, name) VALUES
('ROLE_001', 'admin'),
('ROLE_002', 'manager'),
('ROLE_003', 'agent'),
('ROLE_004', 'reporter');

INSERT INTO permission (perm_id, resource, action) VALUES
('PERM_001', 'users', 'read'),
('PERM_002', 'users', 'crud'),
('PERM_003', 'groups', 'read'),
('PERM_004', 'groups', 'crud'),
('PERM_005', 'services', 'read'),
('PERM_006', 'services', 'crud'),
('PERM_007', 'service_offerings', 'read'),
('PERM_008', 'service_offerings', 'crud'),
('PERM_009', 'configuration_items', 'read'),
('PERM_010', 'configuration_items', 'crud'),
('PERM_011', 'incident_templates', 'read'),
('PERM_012', 'incident_templates', 'crud'),
('PERM_013', 'problems', 'read'),
('PERM_014', 'problems', 'crud'),
('PERM_015', 'changes', 'read'),
('PERM_016', 'changes', 'crud'),
('PERM_017', 'notifications', 'read'),
('PERM_018', 'notifications', 'crud'),
('PERM_019', 'notification_analysis', 'read'),
('PERM_020', 'notification_analysis', 'crud'),
('PERM_021', 'sla_definitions', 'read'),
('PERM_022', 'sla_definitions', 'crud'),
('PERM_023', 'sla_metrics', 'read'),
('PERM_024', 'sla_metrics', 'crud'),
('PERM_025', 'incidents', 'read'),
('PERM_026', 'incidents', 'crud'),
('PERM_027', 'knowledge', 'read'),
('PERM_028', 'knowledge', 'crud'),
('PERM_029', 'locations', 'read'),
('PERM_030', 'locations', 'crud'),
('PERM_031', 'change_mappings', 'read'),
('PERM_032', 'change_mappings', 'crud'),
('PERM_033', 'incident_affected_cis', 'read'),
('PERM_034', 'incident_affected_cis', 'crud'),
('PERM_035', 'incident_slas', 'read'),
('PERM_036', 'incident_slas', 'crud');

INSERT INTO role_permission (role_id, perm_id) VALUES
('ROLE_001', 'PERM_002'), ('ROLE_001', 'PERM_004'), ('ROLE_001', 'PERM_006'), ('ROLE_001', 'PERM_008'),
('ROLE_001', 'PERM_010'), ('ROLE_001', 'PERM_012'), ('ROLE_001', 'PERM_014'), ('ROLE_001', 'PERM_016'),
('ROLE_001', 'PERM_018'), ('ROLE_001', 'PERM_020'), ('ROLE_001', 'PERM_022'), ('ROLE_001', 'PERM_024'),
('ROLE_001', 'PERM_026'), ('ROLE_001', 'PERM_028'), ('ROLE_001', 'PERM_030'), ('ROLE_001', 'PERM_032'),
('ROLE_001', 'PERM_034'), ('ROLE_001', 'PERM_036');

INSERT INTO role_permission (role_id, perm_id) VALUES
('ROLE_002', 'PERM_002'), ('ROLE_002', 'PERM_004'), ('ROLE_002', 'PERM_006'), ('ROLE_002', 'PERM_008'),
('ROLE_002', 'PERM_010'), ('ROLE_002', 'PERM_012'), ('ROLE_002', 'PERM_014'), ('ROLE_002', 'PERM_016'),
('ROLE_002', 'PERM_018'), ('ROLE_002', 'PERM_020'), ('ROLE_002', 'PERM_022'), ('ROLE_002', 'PERM_024'),
('ROLE_002', 'PERM_026'), ('ROLE_002', 'PERM_028'), ('ROLE_002', 'PERM_030'), ('ROLE_002', 'PERM_032'),
('ROLE_002', 'PERM_034'), ('ROLE_002', 'PERM_036');

INSERT INTO role_permission (role_id, perm_id) VALUES
('ROLE_003', 'PERM_001'), ('ROLE_003', 'PERM_003'), ('ROLE_003', 'PERM_005'), ('ROLE_003', 'PERM_007'),
('ROLE_003', 'PERM_010'), ('ROLE_003', 'PERM_011'), ('ROLE_003', 'PERM_014'), ('ROLE_003', 'PERM_016'),
('ROLE_003', 'PERM_017'), ('ROLE_003', 'PERM_019'), ('ROLE_003', 'PERM_021'), ('ROLE_003', 'PERM_023'),
('ROLE_003', 'PERM_026'), ('ROLE_003', 'PERM_028'), ('ROLE_003', 'PERM_030'), ('ROLE_003', 'PERM_031'),
('ROLE_003', 'PERM_033'), ('ROLE_003', 'PERM_035');

INSERT INTO role_permission (role_id, perm_id) VALUES
('ROLE_004', 'PERM_001'), ('ROLE_004', 'PERM_003'), ('ROLE_004', 'PERM_005'), ('ROLE_004', 'PERM_007'),
('ROLE_004', 'PERM_009'), ('ROLE_004', 'PERM_011'), ('ROLE_004', 'PERM_013'), ('ROLE_004', 'PERM_015'),
('ROLE_004', 'PERM_017'), ('ROLE_004', 'PERM_019'), ('ROLE_004', 'PERM_021'), ('ROLE_004', 'PERM_023'),
('ROLE_004', 'PERM_025'), ('ROLE_004', 'PERM_027'), ('ROLE_004', 'PERM_029'), ('ROLE_004', 'PERM_031'),
('ROLE_004', 'PERM_033'), ('ROLE_004', 'PERM_035');

INSERT INTO location (location_id, name, org_id, city, state, country, active) VALUES
('LOC_001', 'Acme HQ', 'org_acme', 'San Francisco', 'published', 'USA', 1);

INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id) VALUES
('marcus.reed', 'marcus.reed', 'Marcus', 'Reed', 'marcus.reed@acme.com', '+1-415-555-0101', 'admin', 1, 'agent_token_marcus_2024_secure', 'org_acme', 'LOC_001'),
('cust_jordan_blake', 'jordan.blake', 'Jordan', 'Blake', 'jordan.blake@customer.com', '+1-415-555-0202', 'reporter', 1, 'token_jordan_blake_2024', 'org_acme', 'LOC_001');

INSERT INTO user_role (user_id, role_id, org_id) VALUES
('marcus.reed', 'ROLE_001', 'org_acme');

INSERT INTO problem (problem_id, number, problem_statement, opened_by, org_id, status, category, impact, urgency, priority) VALUES
('PRB0040001', 'PRB0040001', 'Recurring service outage on customer-facing API cluster', 'marcus.reed', 'org_acme', 'new', 'network', 'high', 'high', 'critical');

INSERT INTO problem (problem_id, number, problem_statement, opened_by, org_id, status, category, impact, urgency, priority) VALUES
('PRB0040099', 'PRB0040099', 'Unrelated printer driver defect', 'marcus.reed', 'org_acme', 'new', 'hardware', 'low', 'low', 'low');

INSERT INTO incident (incident_id, number, short_description, caller_id, problem, org_id, status, category, impact, urgency, priority) VALUES
('INC0050001', 'INC0050001', 'Master incident - API cluster outage', 'cust_jordan_blake', 'PRB0040001', 'org_acme', 'in_progress', 'network', 'high', 'high', 'critical');

INSERT INTO incident (incident_id, number, short_description, caller_id, problem, parent_incident, org_id, status, category, impact, urgency, priority) VALUES
('INC0050002', 'INC0050002', 'Child incident - node A outage', 'cust_jordan_blake', 'PRB0040001', 'INC0050001', 'org_acme', 'in_progress', 'network', 'medium', 'medium', 'moderate');

INSERT INTO incident (incident_id, number, short_description, caller_id, problem, parent_incident, org_id, status, category, impact, urgency, priority) VALUES
('INC0050003', 'INC0050003', 'Child incident - node B outage', 'cust_jordan_blake', 'PRB0040001', 'INC0050001', 'org_acme', 'in_progress', 'network', 'medium', 'medium', 'moderate');

INSERT INTO child_incident (child_incident_mapping_id, parent_incident, child_incident) VALUES
('CHILD-MAP-1', 'INC0050001', 'INC0050002');

INSERT INTO child_incident (child_incident_mapping_id, parent_incident, child_incident) VALUES
('CHILD-MAP-2', 'INC0050001', 'INC0050003');