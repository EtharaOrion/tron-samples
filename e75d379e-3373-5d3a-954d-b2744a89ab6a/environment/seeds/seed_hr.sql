-- MCP Server: sn-hr-internal

INSERT INTO organization (name, active, created_at, updated_at) VALUES ('Northwind Financial', 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO organization (name, active, created_at, updated_at) VALUES ('Northwind Corporate', 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO role (name, created_at, updated_at) VALUES ('admin', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role (name, created_at, updated_at) VALUES ('manager', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role (name, created_at, updated_at) VALUES ('agent', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role (name, created_at, updated_at) VALUES ('employee', '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('users', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('groups', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('hr_services', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('hr_cases', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('hr_profiles', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('topic_categories', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('topic_details', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('service_templates', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('hr_criteria', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('skills', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('knowledge', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('surveys', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('assignment_rules', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('escalation_rules', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('notifications', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('checklists', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('survey_instances', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('reports', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO permission (resource, action, created_at, updated_at) VALUES ('hr_case_tasks', 'crud', '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 2, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 3, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 4, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 5, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 6, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 7, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 8, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 9, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 10, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 11, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 12, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 13, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 14, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 15, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 16, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 17, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 18, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (1, 19, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (2, 4, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (2, 5, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO role_permission (role_id, perm_id, created_at, updated_at) VALUES (2, 3, '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (3301, 'Marcus', 'Whitfield', 'marcus.whitfield@northwind-fin.com', NULL, 'admin', 1, 1, 'hr_token_marcus_whitfield_042', '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (3355, 'Priya', 'Ramanathan', 'priya.ramanathan@northwind-fin.com', NULL, 'manager', 1, 1, NULL, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (3356, 'Priya', 'Ramanathan', 'priya.ramanathan@northwind-corp.com', NULL, 'manager', 1, 2, NULL, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, active, org_id, static_token, created_at, updated_at) VALUES (3360, 'James', 'Okonkwo', 'james.okonkwo@northwind-fin.com', NULL, 'manager', 1, 1, NULL, '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (3301, 1, 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (3355, 2, 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (3356, 2, 2, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO user_role (user_id, role_id, org_id, created_at, updated_at) VALUES (3360, 2, 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO hr_profile (hr_profile_id, number, user_id, personal_email, national_tax_id, position, nationality, location_type, type, marital_status, gender, org_id, created_at, updated_at) VALUES (3355, 'HRP0002211', 3355, 'priya.r.personal@example.com', '***-**-4477', 'Manager', 'US', 'Office Based', 'full-time', 'Married', 'Female', 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
INSERT INTO hr_profile (hr_profile_id, number, user_id, personal_email, national_tax_id, position, nationality, location_type, type, marital_status, gender, org_id, created_at, updated_at) VALUES (3356, 'HRP0002212', 3356, 'p.ramanathan@example.com', '***-**-9911', 'Sales', 'IN', 'Remote', 'full-time', 'Single', 'Female', 2, '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO skill (name, active, org_id, created_at, updated_at) VALUES ('Treasury Operations', 1, 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO user_skill (skill, user, org_id, created_at, updated_at) VALUES (1, 3355, 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');

INSERT INTO hr_service (service_name, fulfillment_type, topic_detail, service_template, hr_criteria, active, org_id, created_at, updated_at) VALUES ('SoX Controller Handover', 'workflow', NULL, NULL, NULL, 1, 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
-- QC fix: acting user Marcus (3301) needs an hr_profile with id==user_id for opened_by FK
INSERT INTO hr_profile (hr_profile_id, number, user_id, personal_email, national_tax_id, position, nationality, location_type, type, marital_status, gender, org_id, created_at, updated_at) VALUES (3301, 'HRP0003301', 3301, 'marcus.w.personal@example.com', '***-**-0042', 'Manager', 'US', 'Office Based', 'full-time', 'Married', 'Male', 1, '2024-01-01 00:00:00', '2024-01-01 00:00:00');
