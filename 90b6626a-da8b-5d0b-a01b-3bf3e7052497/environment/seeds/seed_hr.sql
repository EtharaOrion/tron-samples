-- Database Seed Data for: qsm-2x-sn-hr-internal
-- Database ID: db_1765529350682_48wb3wot7
-- MCP Server: sn-hr-internal
-- Created: 2025-12-12 08:49:13.297900+00:00
-- Description: No description provided
-- NOTE: This is seed data fallback (export-sql API was unavailable)

-- ============================================
-- SEED DATA (SQL Statements)
-- ============================================


-- HR Sample Data - Comprehensive Schema Compliant Data with RBAC & Tenant Scoping
-- =====================================================

-- Organizations (organization) - Tenant boundaries
INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES
(1, 'TechCorp HR', 1, datetime('2024-01-01 08:00:00'), datetime('2024-01-01 08:00:00')),
(2, 'Acme Corp HR', 1, datetime('2024-01-01 08:00:00'), datetime('2024-01-01 08:00:00'));

-- Roles (role) - Shared across organizations
INSERT INTO role (role_id, name) VALUES
(1, 'admin'),
(2, 'manager'),
(3, 'agent'),
(4, 'employee');

-- Permissions (permission) - Simplified model: CRUD and READ only
-- 19 resources × 2 actions = 38 permissions total
INSERT INTO permission (perm_id, resource, action) VALUES
-- Users permissions
(1, 'users', 'read'),
(2, 'users', 'crud'),
-- Groups permissions
(3, 'groups', 'read'),
(4, 'groups', 'crud'),
-- HR Services permissions
(5, 'hr_services', 'read'),
(6, 'hr_services', 'crud'),
-- HR Cases permissions
(7, 'hr_cases', 'read'),
(8, 'hr_cases', 'crud'),
-- HR Profiles permissions
(9, 'hr_profiles', 'read'),
(10, 'hr_profiles', 'crud'),
-- Topic Categories permissions
(11, 'topic_categories', 'read'),
(12, 'topic_categories', 'crud'),
-- Topic Details permissions
(13, 'topic_details', 'read'),
(14, 'topic_details', 'crud'),
-- Service Templates permissions
(15, 'service_templates', 'read'),
(16, 'service_templates', 'crud'),
-- HR Criteria permissions
(17, 'hr_criteria', 'read'),
(18, 'hr_criteria', 'crud'),
-- Skills permissions
(19, 'skills', 'read'),
(20, 'skills', 'crud'),
-- Knowledge permissions
(21, 'knowledge', 'read'),
(22, 'knowledge', 'crud'),
-- Surveys permissions
(23, 'surveys', 'read'),
(24, 'surveys', 'crud'),
-- Assignment Rules permissions
(25, 'assignment_rules', 'read'),
(26, 'assignment_rules', 'crud'),
-- Escalation Rules permissions
(27, 'escalation_rules', 'read'),
(28, 'escalation_rules', 'crud'),
-- Notifications permissions
(29, 'notifications', 'read'),
(30, 'notifications', 'crud'),
-- Checklists permissions
(31, 'checklists', 'read'),
(32, 'checklists', 'crud'),
-- Survey Instances permissions
(33, 'survey_instances', 'read'),
(34, 'survey_instances', 'crud'),
-- Reports permissions
(35, 'reports', 'read'),
(36, 'reports', 'crud'),
-- HR Case Tasks permissions
(37, 'hr_case_tasks', 'read'),
(38, 'hr_case_tasks', 'crud');

-- Role-Permission mappings (role_permission)
-- Admin: all CRUD permissions (19 resources)
INSERT INTO role_permission (role_id, perm_id) VALUES
(1, 2), (1, 4), (1, 6), (1, 8), (1, 10), (1, 12), (1, 14), (1, 16), (1, 18), (1, 20), (1, 22), (1, 24), (1, 26), (1, 28), (1, 30), (1, 32), (1, 34), (1, 36), (1, 38);

-- Manager: all CRUD permissions (19 resources)
INSERT INTO role_permission (role_id, perm_id) VALUES
(2, 2), (2, 4), (2, 6), (2, 8), (2, 10), (2, 12), (2, 14), (2, 16), (2, 18), (2, 20), (2, 22), (2, 24), (2, 26), (2, 28), (2, 30), (2, 32), (2, 34), (2, 36), (2, 38);

-- Agent: mixed permissions
-- CRUD: hr_cases
-- READ: all other resources (18 resources, including hr_case_tasks)
INSERT INTO role_permission (role_id, perm_id) VALUES
(3, 1), (3, 3), (3, 5), (3, 8), (3, 9), (3, 11), (3, 13), (3, 15), (3, 17), (3, 19), (3, 21), (3, 23), (3, 25), (3, 27), (3, 29), (3, 31), (3, 33), (3, 35), (3, 37);

-- Employee: all READ permissions (19 resources)
INSERT INTO role_permission (role_id, perm_id) VALUES
(4, 1), (4, 3), (4, 5), (4, 7), (4, 9), (4, 11), (4, 13), (4, 15), (4, 17), (4, 19), (4, 21), (4, 23), (4, 25), (4, 27), (4, 29), (4, 31), (4, 33), (4, 35), (4, 37);

-- Users table (15 users - distributed across 2 organizations)
INSERT INTO user (user_id, first_name, last_name, email, phone, role, active, static_token, org_id, created_at, updated_at) VALUES
-- Organization 1 (TechCorp HR) - Users 1-8
(1, 'Sarah', 'Chen', 'sarah.chen@techcorp.com', '+1-555-0101', 'admin', 1, 'hr_token_sarah_chen_001', 1, datetime('2024-01-15 09:00:00'), datetime('2024-01-15 09:00:00')),
(2, 'Michael', 'Rodriguez', 'michael.rodriguez@techcorp.com', '+1-555-0102', 'manager', 1, 'hr_token_michael_rodriguez_002', 1, datetime('2024-01-16 10:00:00'), datetime('2024-01-16 10:00:00')),
(3, 'Emily', 'Watson', 'emily.watson@techcorp.com', '+1-555-0103', 'agent', 1, 'hr_token_emily_watson_003', 1, datetime('2024-01-17 11:00:00'), datetime('2024-01-17 11:00:00')),
(4, 'David', 'Kim', 'david.kim@techcorp.com', '+1-555-0104', 'agent', 1, 'hr_token_david_kim_004', 1, datetime('2024-01-18 12:00:00'), datetime('2024-01-18 12:00:00')),
(5, 'Lisa', 'Anderson', 'lisa.anderson@techcorp.com', '+1-555-0105', 'employee', 1, 'hr_token_lisa_anderson_005', 1, datetime('2024-01-19 13:00:00'), datetime('2024-01-19 13:00:00')),
(6, 'James', 'Brown', 'james.brown@techcorp.com', '+1-555-0106', 'employee', 1, 'hr_token_james_brown_006', 1, datetime('2024-01-20 14:00:00'), datetime('2024-01-20 14:00:00')),
(7, 'Maria', 'Garcia', 'maria.garcia@techcorp.com', '+1-555-0107', 'employee', 1, 'hr_token_maria_garcia_007', 1, datetime('2024-01-21 15:00:00'), datetime('2024-01-21 15:00:00')),
(8, 'Robert', 'Taylor', 'robert.taylor@techcorp.com', '+1-555-0108', 'employee', 1, 'hr_token_robert_taylor_008', 1, datetime('2024-01-22 16:00:00'), datetime('2024-01-22 16:00:00')),
-- Organization 2 (Acme Corp HR) - Users 9-15
(9, 'Jennifer', 'Martinez', 'jennifer.martinez@acme.com', '+1-555-0109', 'admin', 1, 'hr_token_jennifer_martinez_009', 2, datetime('2024-01-23 17:00:00'), datetime('2024-01-23 17:00:00')),
(10, 'William', 'Lee', 'william.lee@acme.com', '+1-555-0110', 'manager', 1, 'hr_token_william_lee_010', 2, datetime('2024-01-24 18:00:00'), datetime('2024-01-24 18:00:00')),
(11, 'Jessica', 'White', 'jessica.white@acme.com', '+1-555-0111', 'agent', 1, 'hr_token_jessica_white_011', 2, datetime('2024-01-25 19:00:00'), datetime('2024-01-25 19:00:00')),
(12, 'Christopher', 'Harris', 'christopher.harris@acme.com', '+1-555-0112', 'employee', 1, 'hr_token_christopher_harris_012', 2, datetime('2024-01-26 20:00:00'), datetime('2024-01-26 20:00:00')),
(13, 'Amanda', 'Clark', 'amanda.clark@acme.com', '+1-555-0113', 'employee', 1, 'hr_token_amanda_clark_013', 2, datetime('2024-01-27 21:00:00'), datetime('2024-01-27 21:00:00')),
(14, 'Daniel', 'Lewis', 'daniel.lewis@acme.com', '+1-555-0114', 'employee', 1, 'hr_token_daniel_lewis_014', 2, datetime('2024-01-28 22:00:00'), datetime('2024-01-28 22:00:00')),
(15, 'Ashley', 'Walker', 'ashley.walker@acme.com', '+1-555-0115', 'employee', 1, 'hr_token_ashley_walker_015', 2, datetime('2024-01-29 23:00:00'), datetime('2024-01-29 23:00:00'));

-- User-Role assignments (user_role) - Org-wide roles
INSERT INTO user_role (user_id, role_id, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 1, 1),  -- Sarah Chen - Admin
(2, 2, 1),  -- Michael Rodriguez - Manager
(3, 3, 1),  -- Emily Watson - Agent
(4, 3, 1),  -- David Kim - Agent
(5, 4, 1),  -- Lisa Anderson - Employee
(6, 4, 1),  -- James Brown - Employee
(7, 4, 1),  -- Maria Garcia - Employee
(8, 4, 1),  -- Robert Taylor - Employee
-- Organization 2 (Acme Corp HR)
(9, 1, 2),  -- Jennifer Martinez - Admin
(10, 2, 2), -- William Lee - Manager
(11, 3, 2), -- Jessica White - Agent
(12, 4, 2), -- Christopher Harris - Employee
(13, 4, 2), -- Amanda Clark - Employee
(14, 4, 2), -- Daniel Lewis - Employee
(15, 4, 2); -- Ashley Walker - Employee

-- HR Profiles (1:1 with users, scoped to organizations)
INSERT INTO hr_profile (hr_profile_id, number, gender, user_id, personal_email, marital_status, type, dob, nationality, employment_start_date, employment_end_date, manager, location_type, national_tax_id, position, org_id, created_at, updated_at) VALUES
-- Organization 1 (TechCorp HR)
(1, 'HR-001', 'Female', 1, 'sarah.chen.personal@gmail.com', 'Married', 'full-time', datetime('1985-03-15'), 'US', datetime('2020-01-15'), NULL, NULL, 'Office Based', 'TAX-001-001', 'Manager', 1, datetime('2024-01-15 09:00:00'), datetime('2024-01-15 09:00:00')),
(2, 'HR-002', 'Male', 2, 'michael.rodriguez.personal@gmail.com', 'Single', 'full-time', datetime('1988-07-22'), 'US', datetime('2019-06-01'), NULL, 1, 'Remote', 'TAX-001-002', 'Manager', 1, datetime('2024-01-16 10:00:00'), datetime('2024-01-16 10:00:00')),
(3, 'HR-003', 'Female', 3, 'emily.watson.personal@gmail.com', 'Married', 'full-time', datetime('1990-11-08'), 'GB', datetime('2021-03-10'), NULL, 2, 'Hotdesk', 'TAX-002-001', 'IT Support', 1, datetime('2024-01-17 11:00:00'), datetime('2024-01-17 11:00:00')),
(4, 'HR-004', 'Male', 4, 'david.kim.personal@gmail.com', 'Single', 'full-time', datetime('1992-05-14'), 'US', datetime('2022-01-05'), NULL, 2, 'Office Based', 'TAX-001-003', 'IT Support', 1, datetime('2024-01-18 12:00:00'), datetime('2024-01-18 12:00:00')),
(5, 'HR-005', 'Female', 5, 'lisa.anderson.personal@gmail.com', 'Divorced', 'full-time', datetime('1987-09-30'), 'CA', datetime('2020-08-20'), NULL, 1, 'Remote', 'TAX-003-001', 'Software Engineer', 1, datetime('2024-01-19 13:00:00'), datetime('2024-01-19 13:00:00')),
(6, 'HR-006', 'Male', 6, 'james.brown.personal@gmail.com', 'Married', 'full-time', datetime('1989-12-05'), 'US', datetime('2021-02-15'), NULL, 1, 'Office Based', 'TAX-001-004', 'Software Engineer', 1, datetime('2024-01-20 14:00:00'), datetime('2024-01-20 14:00:00')),
(7, 'HR-007', 'Female', 7, 'maria.garcia.personal@gmail.com', 'Single', 'part-time', datetime('1991-04-18'), 'US', datetime('2022-05-10'), NULL, 1, 'Hotdesk', 'TAX-001-005', 'QA', 1, datetime('2024-01-21 15:00:00'), datetime('2024-01-21 15:00:00')),
(8, 'HR-008', 'Male', 8, 'robert.taylor.personal@gmail.com', 'Married', 'full-time', datetime('1986-08-25'), 'GB', datetime('2019-11-01'), NULL, 2, 'Office Based', 'TAX-002-002', 'Sales', 1, datetime('2024-01-22 16:00:00'), datetime('2024-01-22 16:00:00')),
-- Organization 2 (Acme Corp HR)
(9, 'HR-009', 'Female', 9, 'jennifer.martinez.personal@gmail.com', 'Single', 'full-time', datetime('1993-01-12'), 'US', datetime('2023-01-10'), NULL, NULL, 'Remote', 'TAX-002-001', 'HR', 2, datetime('2024-01-23 17:00:00'), datetime('2024-01-23 17:00:00')),
(10, 'HR-010', 'Male', 10, 'william.lee.personal@gmail.com', 'Married', 'full-time', datetime('1984-06-20'), 'US', datetime('2018-09-15'), NULL, 9, 'Office Based', 'TAX-002-002', 'Administration', 2, datetime('2024-01-24 18:00:00'), datetime('2024-01-24 18:00:00')),
(11, 'HR-011', 'Female', 11, 'jessica.white.personal@gmail.com', 'Married', 'full-time', datetime('1990-03-25'), 'US', datetime('2022-07-01'), NULL, 10, 'Remote', 'TAX-002-003', 'HR', 2, datetime('2024-01-25 19:00:00'), datetime('2024-01-25 19:00:00')),
(12, 'HR-012', 'Male', 12, 'christopher.harris.personal@gmail.com', 'Single', 'full-time', datetime('1991-08-10'), 'US', datetime('2023-02-15'), NULL, 10, 'Office Based', 'TAX-002-004', 'Software Engineer', 2, datetime('2024-01-26 20:00:00'), datetime('2024-01-26 20:00:00')),
(13, 'HR-013', 'Female', 13, 'amanda.clark.personal@gmail.com', 'Married', 'full-time', datetime('1989-05-18'), 'US', datetime('2021-11-20'), NULL, 10, 'Hotdesk', 'TAX-002-005', 'Manager', 2, datetime('2024-01-27 21:00:00'), datetime('2024-01-27 21:00:00')),
(14, 'HR-014', 'Male', 14, 'daniel.lewis.personal@gmail.com', 'Single', 'full-time', datetime('1992-12-03'), 'CA', datetime('2022-09-10'), NULL, 10, 'Office Based', 'TAX-003-001', 'QA', 2, datetime('2024-01-28 22:00:00'), datetime('2024-01-28 22:00:00')),
(15, 'HR-015', 'Female', 15, 'ashley.walker.personal@gmail.com', 'Married', 'part-time', datetime('1993-07-22'), 'US', datetime('2023-05-01'), NULL, 10, 'Remote', 'TAX-002-006', 'Sales', 2, datetime('2024-01-29 23:00:00'), datetime('2024-01-29 23:00:00'));

-- User Groups (scoped to organizations)
INSERT INTO user_group (group_id, name, type, active, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 'IT Support', 'IT Support', 1, 1),
(2, 'Service Desk', 'Service Desk', 1, 1),
(3, 'Field Support Team', 'Field Support Technicians', 1, 1),
(4, 'Infrastructure Team', 'Infrastructure Problem Team', 1, 1),
(5, 'Level 1 Support', 'Service Desk', 1, 1),
(6, 'Level 2 Support', 'IT Support', 1, 1),
(7, 'Level 3 Support', 'Infrastructure Problem Team', 1, 1),
(8, 'Network Operations', 'Infrastructure Problem Team', 1, 1),
(9, 'Application Support', 'IT Support', 1, 1),
(10, 'Security Team', 'IT Support', 1, 1),
-- Organization 2 (Acme Corp HR)
(11, 'Field Support Technicians', 'Field Support Technicians', 1, 2),
(12, 'Infrastructure Problem Team', 'Infrastructure Problem Team', 1, 2),
(13, 'Service Desk Team', 'Service Desk', 1, 2),
(14, 'IT Operations', 'IT Support', 1, 2),
(15, 'Database Team', 'Infrastructure Problem Team', 1, 2),
(16, 'Cloud Operations', 'Infrastructure Problem Team', 1, 2),
(17, 'Desktop Support', 'Field Support Technicians', 1, 2),
(18, 'Help Desk', 'Service Desk', 1, 2);

-- User Group Members (some users in groups, some not - for future association)
INSERT INTO user_group_member (member_id, group_id, user_id, org_id) VALUES
(1, 1, 3, 1),
(2, 1, 4, 1),
(3, 2, 3, 1),
(4, 2, 4, 1),
(5, 3, 3, 1),
(6, 4, 2, 1);

-- Topic Categories (scoped to organizations)
INSERT INTO topic_category (topic_category_id, active, name, coe_type, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 1, 'Onboarding', 'HRIT', 1),
(2, 1, 'Benefits Enrollment', 'Total Rewards', 1),
(3, 1, 'Payroll Issues', 'Payroll', 1),
-- Organization 2 (Acme Corp HR)
(4, 1, 'Performance Review', 'Talent Management', 2),
(5, 1, 'Workplace Policies', 'Workforce Administration', 2);

-- Topic Details (scoped to organizations)
INSERT INTO topic_detail (topic_detail_id, active, name, topic_category, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 1, 'New Employee Setup', 1, 1),
(2, 1, 'Equipment Request', 1, 1),
(3, 1, 'Health Insurance', 2, 1),
(4, 1, '401k Enrollment', 2, 1),
(5, 1, 'Paycheck Discrepancy', 3, 1),
-- Organization 2 (Acme Corp HR)
(6, 1, 'Tax Form Update', 3, 2),
(7, 1, 'Annual Review', 4, 2),
(8, 1, 'Goal Setting', 4, 2),
(9, 1, 'Remote Work Policy', 5, 2),
(10, 1, 'Time Off Request', 5, 2);

-- Service Templates (scoped to organizations)
INSERT INTO service_template (service_template_id, name, change_request_values, active, coe_type, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 'Onboarding Template', '{"short_description": "New employee onboarding request", "category": "onboarding"}', 1, 'HRIT', 1),
(2, 'Benefits Template', '{"short_description": "Benefits enrollment assistance", "category": "benefits"}', 1, 'Total Rewards', 1),
(3, 'Payroll Template', '{"short_description": "Payroll inquiry", "category": "payroll"}', 1, 'Payroll', 1),
-- Organization 2 (Acme Corp HR)
(4, 'Performance Template', '{"short_description": "Performance review setup", "category": "performance"}', 1, 'Talent Management', 2),
(5, 'Policy Template', '{"short_description": "Workplace policy question", "category": "policy"}', 1, 'Workforce Administration', 2);

-- HR Criteria (scoped to organizations)
INSERT INTO hr_criteria (hr_criteria_id, name, type, active, user_group, users, org_id, created_at, updated_at) VALUES
-- Organization 1 (TechCorp HR)
(1, 'Admin Only Visibility', 'case_visibility', 1, 4, '[1, 2]', 1, datetime('2024-01-10 08:00:00'), datetime('2024-01-10 08:00:00')),
(2, 'Manager Approval Required', 'approval', 1, NULL, '[2]', 1, datetime('2024-01-10 09:00:00'), datetime('2024-01-10 09:00:00')),
-- Organization 2 (Acme Corp HR)
(3, 'HR Team Visibility', 'case_visibility', 1, 2, '[9, 10]', 2, datetime('2024-01-10 10:00:00'), datetime('2024-01-10 10:00:00'));

-- HR Services (scoped to organizations)
INSERT INTO hr_service (hr_service_id, service_name, fulfillment_type, topic_detail, service_template, hr_criteria, active, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 'Employee Onboarding', 'workflow', 1, 1, 1, 1, 1),
(2, 'Benefits Enrollment', 'manual', 3, 2, 1, 1, 1),
(3, 'Payroll Support', 'service_activity', 5, 3, 2, 1, 1),
-- Organization 2 (Acme Corp HR)
(4, 'Performance Review', 'workflow', 7, 4, 3, 1, 2),
(5, 'Policy Questions', 'manual', 9, 5, 3, 1, 2);

-- Skills (scoped to organizations)
INSERT INTO skill (skill_id, name, active, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 'Onboarding Specialist', 1, 1),
(2, 'Benefits Advisor', 1, 1),
(3, 'Payroll Expert', 1, 1),
(4, 'Performance Management', 1, 1),
-- Organization 2 (Acme Corp HR)
(5, 'Policy Interpretation', 1, 2),
(6, 'HRIS Administration', 1, 2),
(7, 'Compliance', 1, 2),
(8, 'Employee Relations', 1, 2);

-- User Skills (some users have skills, some don't - for future association)
INSERT INTO user_skill (user_skill_id, skill, user, org_id) VALUES
-- Organization 1 (TechCorp HR) - Users 1-8, Skills 1-4
(1, 1, 3, 1),
(2, 2, 3, 1),
(3, 3, 4, 1),
(4, 4, 2, 1),
-- Organization 2 (Acme Corp HR) - Users 9-15, Skills 5-8
(5, 5, 11, 2),
(6, 6, 9, 2),
(7, 7, 10, 2),
(8, 8, 11, 2);

-- HR Cases (scoped to organizations)
INSERT INTO hr_case (hr_case_id, number, status, hr_service, opened_for, opened_by, priority, source, assigned_to, assignment_group, short_description, worknotes, skills, approval_criteria, coe_type, approver, request_status, account_number, account_type, org_id, created_at, updated_at) VALUES
-- Organization 1 (TechCorp HR)
(1, 'HRC-0001', 'work_in_progress', 1, 5, 2, 'high', 'self-service', 3, 1, 'New employee onboarding for Lisa Anderson', 'Setting up equipment and access', '[1, 2]', 1, 'HRIT', 2, 'approved', 'ACC-001-001', NULL, 1, datetime('2024-02-01 09:00:00'), datetime('2024-02-01 14:30:00')),
(2, 'HRC-0002', 'awaiting_approval', 2, 6, 2, 'moderate', 'email', 3, 2, 'Benefits enrollment for James Brown', 'Health insurance and 401k setup', '[2]', 2, 'Total Rewards', 2, 'requested', 'ACC-001-002', NULL, 1, datetime('2024-02-02 10:15:00'), datetime('2024-02-02 10:15:00')),
(3, 'HRC-0003', 'closed_complete', 3, 7, 3, 'high', 'phone', 4, 2, 'Paycheck discrepancy for Maria Garcia', 'Fixed missing overtime pay', '[3]', NULL, 'Payroll', NULL, NULL, 'ACC-001-003', 'checking', 1, datetime('2024-02-03 11:30:00'), datetime('2024-02-03 16:45:00')),
-- Additional awaiting_approval cases for user 1 (Sarah Chen - admin)
(7, 'HRC-0007', 'awaiting_approval', 1, 6, 3, 'high', 'email', 4, 1, 'Emergency onboarding approval for James Brown', 'Requires admin approval for expedited setup', '[1, 2]', 1, 'HRIT', 1, 'requested', 'ACC-001-007', NULL, 1, datetime('2024-02-07 09:00:00'), datetime('2024-02-07 09:00:00')),
(8, 'HRC-0008', 'awaiting_approval', 2, 7, 4, 'critical', 'phone', 3, 2, 'Executive benefits package for Maria Garcia', 'High-level benefits setup needing admin sign-off', '[2]', 2, 'Total Rewards', 1, 'requested', 'ACC-001-008', 'savings', 1, datetime('2024-02-07 10:30:00'), datetime('2024-02-07 10:30:00')),
(9, 'HRC-0009', 'awaiting_approval', 3, 8, 2, 'high', 'self-service', 4, 2, 'Payroll exception for Robert Taylor', 'Special payment approval needed', '[3]', 2, 'Payroll', 1, 'requested', 'ACC-001-009', 'checking', 1, datetime('2024-02-07 11:45:00'), datetime('2024-02-07 11:45:00')),
-- Additional awaiting_approval cases for user 2 (Michael Rodriguez - manager)
(10, 'HRC-0010', 'awaiting_approval', 2, 5, 3, 'moderate', 'chat', 3, 1, 'Benefits update for Lisa Anderson', 'Annual benefits enrollment approval', '[2]', 2, 'Total Rewards', 2, 'requested', 'ACC-001-010', NULL, 1, datetime('2024-02-08 08:30:00'), datetime('2024-02-08 08:30:00')),
(11, 'HRC-0011', 'awaiting_approval', 1, 8, 4, 'high', 'email', 3, 1, 'Onboarding request for Robert Taylor transfer', 'Department transfer requires manager approval', '[1]', 2, 'HRIT', 2, 'requested', 'ACC-001-011', NULL, 1, datetime('2024-02-08 09:15:00'), datetime('2024-02-08 09:15:00')),
-- Additional awaiting_approval cases for user 3 (Emily Watson - agent)
(12, 'HRC-0012', 'awaiting_approval', 2, 5, 2, 'moderate', 'self-service', 4, 2, 'Health insurance change for Lisa Anderson', 'Plan upgrade request pending agent approval', '[2]', 1, 'Total Rewards', 3, 'requested', 'ACC-001-012', NULL, 1, datetime('2024-02-09 10:00:00'), datetime('2024-02-09 10:00:00')),
(13, 'HRC-0013', 'awaiting_approval', 1, 6, 2, 'high', 'email', 3, 1, 'Access request for James Brown', 'System access upgrade needs agent approval', '[1]', 1, 'HRIT', 3, 'requested', 'ACC-001-013', NULL, 1, datetime('2024-02-09 11:20:00'), datetime('2024-02-09 11:20:00')),
(14, 'HRC-0014', 'awaiting_approval', 3, 7, 4, 'moderate', 'phone', 4, 2, 'Payroll adjustment for Maria Garcia', 'Overtime calculation review by agent', '[3]', 1, 'Payroll', 3, 'requested', 'ACC-001-014', 'checking', 1, datetime('2024-02-09 12:40:00'), datetime('2024-02-09 12:40:00')),
-- Organization 2 (Acme Corp HR)
(4, 'HRC-0004', 'draft', 4, 12, 10, 'low', 'self-service', NULL, 13, 'Performance review setup for Christopher Harris', NULL, NULL, NULL, 'Talent Management', NULL, NULL, 'ACC-002-001', NULL, 2, datetime('2024-02-04 12:00:00'), datetime('2024-02-04 12:00:00')),
(5, 'HRC-0005', 'ready', 5, 13, 11, 'moderate', 'chat', NULL, 13, 'Remote work policy question', 'Need clarification on hybrid schedule', '[5]', NULL, 'Workforce Administration', NULL, NULL, 'ACC-002-002', NULL, 2, datetime('2024-02-05 13:20:00'), datetime('2024-02-05 13:20:00')),
(6, 'HRC-0006', 'closed_incomplete', 4, 14, 10, 'moderate', 'walk-in', 11, 13, 'Performance review for Amanda Clark', 'Pending documentation', '[4]', NULL, 'Talent Management', NULL, NULL, 'ACC-002-003', NULL, 2, datetime('2024-02-06 14:00:00'), datetime('2024-02-07 10:00:00'));

-- HR Case Tasks (scoped to organizations via parent_case)
INSERT INTO hr_case_task (hr_case_task_id, number, status, assigned_to, assignment_group, short_description, task_type, hr_service, external_url, worknotes, active, parent_case, org_id) VALUES
-- Organization 1 (TechCorp HR) - Tasks 1-3 belong to cases in org 1
(1, 'TASK-0001', 'work_in_progress', 3, 1, 'Complete equipment setup checklist', 'checklist', 1, NULL, 'Laptop and accessories ordered', 1, 1, 1),
(2, 'TASK-0002', 'ready', 3, 2, 'Review benefits enrollment form', 'survey', 2, NULL, NULL, 1, 2, 1),
(3, 'TASK-0003', 'closed_complete', 4, 2, 'Verify payroll correction', 'mark when complete', 3, NULL, 'Payroll correction verified and processed', 1, 3, 1),
-- Organization 2 (Acme Corp HR) - Tasks 4-5 belong to cases in org 2
(4, 'TASK-0004', 'draft', NULL, NULL, 'Schedule performance review meeting', 'hr service', 4, NULL, NULL, 0, 4, 2),
(5, 'TASK-0005', 'ready', NULL, 13, 'Review remote work policy document', 'url', 5, 'https://company.com/policies/remote-work', NULL, 1, 5, 2);

-- Checklists (scoped to organizations)
INSERT INTO checklist (checklist_id, checklist_item_description, checked, case_task_id, org_id) VALUES
-- Organization 1 (TechCorp HR) - Tasks 1-3 belong to org 1
(1, 'Order laptop', 1, 1, 1),
(2, 'Order monitor', 1, 1, 1),
(3, 'Order keyboard and mouse', 0, 1, 1),
(4, 'Setup email account', 1, 1, 1),
(5, 'Setup access badges', 0, 1, 1);

-- Surveys (scoped to organizations)
INSERT INTO survey (survey_id, question_1, question_2, question_3, question_4, question_5, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 'Which health insurance plan do you prefer?', 'Would you like to enroll in 401k?', 'What is your beneficiary information?', 'Any dependent coverage needed?', 'Additional comments?', 1),
-- Organization 2 (Acme Corp HR)
(2, 'How would you rate the onboarding process?', 'Was the information clear?', 'Any suggestions for improvement?', 'Would you recommend this process?', 'Additional feedback?', 2);

-- Survey Instances
INSERT INTO survey_instance (survey_instance_id, survey_id, case_task_id, assigned_to, org_id, answer_1, answer_2, answer_3, answer_4, answer_5) VALUES
(1, 1, 2, 6, 1, 'Premium Plan', 'Yes', 'Spouse and children', 'Yes, 2 dependents', 'Need dental coverage info');

-- Assignment Rules (scoped to organizations)
INSERT INTO assignment_rules (assignment_rule_id, name, based_on_skills, based_on_country, based_on_priority, active, user_group, users, org_id) VALUES
-- Organization 1 (TechCorp HR)
(1, 'US Payroll Rule', '[3]', 'US', 'high', 1, 2, '[3, 4]', 1),
(2, 'UK Benefits Rule', '[2]', 'GB', 'moderate', 1, 2, '[3]', 1),
-- Organization 2 (Acme Corp HR)
(3, 'Critical Priority Escalation', NULL, NULL, 'critical', 1, 4, '[9, 10]', 2);

-- Escalation Rules (scoped to organizations)
INSERT INTO escalation_rule (escalation_rule_id, escalate_from, escalate_to, org_id) VALUES
-- Organization 1 (TechCorp HR) - Multi-tier escalation path
(1, 5, 6, 1),   -- Level 1 Support -> Level 2 Support
(2, 6, 7, 1),   -- Level 2 Support -> Level 3 Support
(3, 2, 4, 1),   -- Service Desk -> Infrastructure Team
(4, 1, 9, 1),   -- IT Support -> Application Support
(5, 3, 8, 1),   -- Field Support Team -> Network Operations
(6, 9, 10, 1),  -- Application Support -> Security Team
-- Organization 2 (Acme Corp HR) - Multi-tier escalation path
(7, 18, 13, 2),  -- Help Desk -> Service Desk Team
(8, 13, 14, 2),  -- Service Desk Team -> IT Operations
(9, 17, 11, 2),  -- Desktop Support -> Field Support Technicians
(10, 11, 12, 2), -- Field Support Technicians -> Infrastructure Problem Team
(11, 14, 15, 2), -- IT Operations -> Database Team
(12, 15, 16, 2); -- Database Team -> Cloud Operations

-- Knowledge (scoped to organizations)
INSERT INTO knowledge (knowledge_id, kb_number, title, body, state, visibility, owner_id, org_id, created_at, updated_at) VALUES
-- Organization 1 (TechCorp HR)
(1, 'KB-001', 'Onboarding Checklist', 'Complete guide for new employee onboarding process including equipment, access, and documentation requirements.', 'published', 'internal', 1, 1, datetime('2024-01-10 08:00:00'), datetime('2024-01-10 08:00:00')),
(2, 'KB-002', 'Benefits Enrollment Guide', 'Step-by-step instructions for enrolling in health insurance and 401k plans.', 'published', 'internal', 2, 1, datetime('2024-01-11 09:00:00'), datetime('2024-01-11 09:00:00')),
(3, 'KB-003', 'Payroll FAQ', 'Common payroll questions and answers including paycheck timing, deductions, and tax forms.', 'published', 'internal', 3, 1, datetime('2024-01-12 10:00:00'), datetime('2024-01-12 10:00:00')),
-- Organization 2 (Acme Corp HR)
(4, 'KB-001', 'Remote Work Policy', 'Detailed remote work policy including eligibility, requirements, and approval process.', 'published', 'external', 9, 2, datetime('2024-01-13 11:00:00'), datetime('2024-01-13 11:00:00')),
(5, 'KB-002', 'Performance Review Process', 'Guide to the annual performance review process and timeline.', 'draft', 'internal', 10, 2, datetime('2024-01-14 12:00:00'), datetime('2024-01-14 12:00:00'));

-- HR Case Knowledge
INSERT INTO hr_case_knowledge (hr_case_kb_id, hr_case_id, knowledge_id, used_as, org_id) VALUES
(1, 1, 1, 'suggested', 1),
(2, 2, 2, 'applied', 1),
(3, 3, 3, 'resolution', 1),
(4, 5, 4, 'suggested', 2);

-- Notifications (scoped to organizations)
INSERT INTO notification (notification_id, hr_case_id, email, type, status, org_id, created_at) VALUES
-- Organization 1 (TechCorp HR)
(1, 1, 'lisa.anderson@techcorp.com', 'report', 'ready', 1, datetime('2024-02-01 09:05:00')),
(2, 2, 'james.brown@techcorp.com', 'update', 'work_in_progress', 1, datetime('2024-02-02 10:20:00')),
(3, 3, 'maria.garcia@techcorp.com', 'alert', 'closed_complete', 1, datetime('2024-02-03 16:50:00')),
-- Organization 2 (Acme Corp HR)
(4, 5, 'amanda.clark@acme.com', 'reminder', 'awaiting_approval', 2, datetime('2024-02-05 13:25:00'));


-- ============================================
-- End of Seed Data
-- ============================================


-- ============================================
-- TRON task2 v2 trap block (2026-07-13)
-- Inactive near-name group: agents that grab the first plausible
-- 'Service Desk*' group without checking active/exact name fail
-- the criteria verifier (which requires the exact, active group).
-- ============================================
INSERT INTO user_group (group_id, name, type, active, org_id) VALUES
(19, 'Service Desk Support', 'Service Desk', 0, 1);

-- ============================================
-- TRON task 90b6626a additions: offboarding access revocation across HR, ITSM
-- and Email, with the revocation target derived from the departing employee's
-- work location and a second departing employee left untouched.
-- ============================================

INSERT INTO knowledge (knowledge_id, kb_number, title, body, state, visibility, owner_id, org_id, created_at, updated_at) VALUES
(8, 'KB-HR-OFFB-030', 'Offboarding Access Revocation Standard',
 'This article is the binding offboarding procedure and supersedes KB-HR-OFFB-020, which is retired and must not be followed. R1 Record. Open exactly one HR case for the departure, Center of Excellence type Workforce Administration, status ready. R2 Revocation target. Raise exactly one access revocation change in the ITSM system against the configuration item that the departing employee work location maps to. The mapping is fixed. A location type of Office Based maps to the physical access controller with serial number SEC-BDG-01. A location type of Remote maps to the directory synchronisation service with serial number CLD-AZR-772. A location type of Hotdesk maps to the physical access controller with serial number SEC-BDG-01, because a hotdesk user still carries a building badge. R3 Notification. Send exactly one email to the departing employee reporting manager. The subject line quotes the serial number of the configuration item selected under R2, byte for byte, in the exact form Access revocation for FIRST LAST on SERIAL. R4 Precedence. The mapping in R2 is decided by the employee own HR profile and never by the description of the departure request.',
 'published', 'internal', 1, 1, datetime('2026-02-10 08:00:00'), datetime('2026-02-10 08:00:00')),
(9, 'KB-HR-OFFB-020', 'Offboarding Access Revocation Standard (superseded)',
 'RETIRED. Superseded by KB-HR-OFFB-030 and must not be followed. It stated that every access revocation change is raised against the directory synchronisation service with serial number CLD-AZR-772 regardless of work location.',
 'retired', 'internal', 1, 1, datetime('2025-04-01 08:00:00'), datetime('2026-02-10 08:00:00'));
