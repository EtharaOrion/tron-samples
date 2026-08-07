-- MCP Server: sn-csm-server

INSERT INTO location (location_id, name, plot_no, street, city, country, active, sys_created_on, sys_updated_on) VALUES
(1, 'Globex HQ - New York', 'Plot 10', 'Wall Street', 'new_york', 'usa', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(2, 'Globex Office - London', 'Plot 22', 'Baker Street', 'london', 'uk', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO user_group (group_id, name, type, active, sys_created_on, sys_updated_on) VALUES
(101, 'CSM Tier 2 Support', 'support', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(102, 'Finance Back Office', 'backoffice', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES
(4021, 'Priya', 'Sharma', 'priya.sharma@globex.com', '+1-555-4021', 'manager', 1, 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(4025, 'James', 'Wilson', 'james.wilson@globex.com', '+1-555-4025', 'agent', 1, 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(4032, 'Anita', 'Rodriguez', 'anita.rodriguez@globex.com', '+1-555-4032', 'agent', 1, 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(6001, 'John', 'Baker', 'john.baker@acmefin.com', '+1-555-6001', 'customer', NULL, 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO account (account_id, name, account_type, email_domain, active, sys_created_on, sys_updated_on) VALUES
(5001, 'Acme Financial Holdings', 'customer', 'acmefin.com', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO product (product_id, name, category, product_price, lifecycle_state, sys_created_on, sys_updated_on) VALUES
(9001, 'WirePay Settlement Suite', 'software', 25000, 'active', '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(9002, 'Acme Portal Access', 'service', 5000, 'active', '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary, sys_created_on, sys_updated_on) VALUES
(7001, 5001, 6001, 1, 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status, warranty_end, sys_created_on, sys_updated_on) VALUES
(4501, 5001, 9001, 1, 'WPSS-ACME-0001', 'in_use', '2027-12-31', '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO contract (contract_id, account_id, contract_type, status, contract_price, start_date, end_date, sys_created_on, sys_updated_on) VALUES
(3001, 5001, 'support', 'active', 100000, '2025-01-01', '2026-12-31', '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO entitlement (entitlement_id, account_id, product_id, contract_id, support_level, coverage_hours, max_cases_per_month, active, sys_created_on, sys_updated_on) VALUES
(2001, 5001, 9001, 3001, 'enterprise', 'h24x7', 100, 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO sla_definition (sla_def_id, name, metric, target_mins, pause_on_pending, applies_to_priority, active, sys_created_on, sys_updated_on) VALUES
(501, 'Critical Response SLA', 'response', 30, 0, 'critical', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(502, 'Critical Resolution SLA', 'resolution', 240, 1, 'critical', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00'),
(503, 'High Response SLA', 'response', 60, 0, 'high', 1, '2025-01-01 00:00:00', '2025-01-01 00:00:00');

INSERT INTO user_group_member (member_id, group_id, user_id, sys_created_on) VALUES
(1, 101, 4025, '2025-01-01 00:00:00'),
(2, 101, 4032, '2025-01-01 00:00:00'),
(3, 102, 4032, '2025-01-01 00:00:00');

INSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count, sys_created_on, sys_updated_on, closed_on) VALUES
(8801, 'CS0002345', 5001, 7001, 9001, 4501, 'phone', 'critical', 'in_progress', 'Wire transfer settlement failure - customer funds pending finance review', 101, NULL, 1, 'impact', 0, '2026-07-15 09:00:00', '2026-07-15 09:00:00', NULL),
(8790, 'CS0002310', 5001, 7001, 9002, NULL, 'web', 'high', 'in_progress', 'Portal login intermittent', 101, 4025, 0, NULL, 0, '2026-07-14 10:00:00', '2026-07-14 10:00:00', NULL);

INSERT INTO case_sla (case_sla_id, case_id, sla_def_id, stage, start_time, breach_time, has_breached, completed_time) VALUES
(1, 8801, 501, 'in_progress', '2026-07-15 09:00:00', '2026-07-15 09:30:00', 0, NULL),
(2, 8801, 502, 'in_progress', '2026-07-15 09:00:00', '2026-07-15 13:00:00', 0, NULL),
(3, 8790, 503, 'in_progress', '2026-07-14 10:00:00', '2026-07-14 11:00:00', 0, NULL);

INSERT INTO knowledge (knowledge_id, kb_number, title, body, state, visibility, product_id, owner_id, sys_created_on, sys_updated_on) VALUES
(701, 'KB0001001', 'Wire Transfer Settlement Failure Runbook', 'Steps to review pending wire settlement in the finance reconciliation queue and validate counterparty bank routing details before releasing funds.', 'published', 'internal', 9001, 4021, '2025-01-01 00:00:00', '2025-01-01 00:00:00');
