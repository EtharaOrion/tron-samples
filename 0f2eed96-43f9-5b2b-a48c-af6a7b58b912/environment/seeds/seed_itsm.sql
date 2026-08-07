-- MCP Server: sn-itsm-internal
INSERT INTO organization (org_id, name, active) VALUES ('org_techcorp', 'TechCorp', 1);

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
('loc_hq_sf', 'TechCorp HQ', 'org_techcorp', 'San Francisco', 'published', 'USA', 1);

INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id) VALUES
('u_whitfield_dana', 'dana.whitfield', 'Dana', 'Whitfield', 'dana.whitfield@techcorp.com', '+1-415-555-0101', 'admin', 1, 'agent_token_dana_2024_secure', 'org_techcorp', 'loc_hq_sf'),
('u_hale_victor_ctr', 'victor.hale.ctr', 'Victor', 'Hale', 'victor.hale@contractor.techcorp.com', '+1-415-555-0102', 'reporter', 1, 'reporter_token_victorctr_2024_secure', 'org_techcorp', 'loc_hq_sf'),
('u_hale_victor_emp', 'victor.hale', 'Victor', 'Hale', 'victor.hale@techcorp.com', '+1-415-555-0103', 'agent', 1, 'agent_token_victor_2024_secure', 'org_techcorp', 'loc_hq_sf');

INSERT INTO user_group (group_id, name, type, active, email, description, manager_id, org_id) VALUES
('grp_sec_oncall', 'Security On-Call', 'IT Support', 1, 'security-oncall@techcorp.com', 'Primary security on-call rotation', 'u_whitfield_dana', 'org_techcorp'),
('grp_sec_review', 'Security Review Board', 'IT Support', 1, 'security-review@techcorp.com', 'Security policy review group', 'u_whitfield_dana', 'org_techcorp'),
('grp_field_support', 'Field Support', 'Field Support Technicians', 1, 'field-support@techcorp.com', 'Field support technicians', 'u_whitfield_dana', 'org_techcorp');

INSERT INTO user_group_member (member_id, group_id, user_id, org_id) VALUES
('mem_001', 'grp_field_support', 'u_hale_victor_ctr', 'org_techcorp'),
('mem_002', 'grp_sec_oncall', 'u_whitfield_dana', 'org_techcorp');

INSERT INTO user_role (user_id, role_id, org_id) VALUES
('u_whitfield_dana', 'ROLE_001', 'org_techcorp'),
('u_hale_victor_ctr', 'ROLE_004', 'org_techcorp'),
('u_hale_victor_emp', 'ROLE_003', 'org_techcorp');

INSERT INTO incident (incident_id, number, short_description, caller_id, assigned_to, assignment_group, status, category, channel, org_id, impact, urgency, priority) VALUES
('inc_open_001', 'INC0012001', 'Contractor VPN access anomaly review', 'u_whitfield_dana', 'u_hale_victor_ctr', 'grp_field_support', 'in_progress', 'network', 'email', 'org_techcorp', 'medium', 'medium', 'moderate'),
('inc_open_002', 'INC0012002', 'Contractor endpoint credential rotation', 'u_whitfield_dana', 'u_hale_victor_ctr', 'grp_field_support', 'new', 'password-reset', 'phone', 'org_techcorp', 'medium', 'medium', 'moderate'),
('inc_closed_003', 'INC0012003', 'Contractor laptop reimage completed', 'u_whitfield_dana', 'u_hale_victor_ctr', 'grp_field_support', 'closed', 'hardware', 'web', 'org_techcorp', 'low', 'low', 'low'),
('inc_other_004', 'INC0012004', 'Firewall rule change request follow-up', 'u_whitfield_dana', 'u_hale_victor_emp', 'grp_field_support', 'in_progress', 'network', 'chat', 'org_techcorp', 'high', 'high', 'high');