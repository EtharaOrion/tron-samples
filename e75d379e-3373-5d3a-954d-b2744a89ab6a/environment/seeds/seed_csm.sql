-- MCP Server: sn-csm-server

INSERT INTO location (location_id, name, city, country, active, sys_created_on, sys_updated_on) VALUES (1, 'Northwind Finance HQ', 'new_york', 'usa', 1, '2025-01-10 09:00:00', '2025-01-10 09:00:00');
INSERT INTO location (location_id, name, city, country, active, sys_created_on, sys_updated_on) VALUES (2, 'Northwind Finance London', 'london', 'uk', 1, '2025-01-10 09:00:00', '2025-01-10 09:00:00');

INSERT INTO user_group (group_id, name, type, active, sys_created_on, sys_updated_on) VALUES (10, 'Controllers Desk', 'backoffice', 1, '2025-01-10 09:00:00', '2025-01-10 09:00:00');
INSERT INTO user_group (group_id, name, type, active, sys_created_on, sys_updated_on) VALUES (11, 'Client Ops Support', 'support', 1, '2025-01-10 09:00:00', '2025-01-10 09:00:00');

INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES (4501, 'Marcus', 'Whitfield', 'marcus.whitfield@northwind-fin.com', '+1-212-555-0101', 'admin', 1, 1, '2025-01-10 09:00:00', '2026-06-01 09:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES (4522, 'Priya', 'Ramanathan', 'priya.ramanathan@northwind-fin.com', '+1-212-555-0122', 'manager', 1, 1, '2025-01-15 09:00:00', '2026-06-15 09:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES (4523, 'Priya', 'Ramanathan', 'priya.ramanathan@northwind-corp.com', '+1-212-555-0123', 'manager', 1, 1, '2025-02-01 09:00:00', '2026-06-01 09:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES (4524, 'Priyanka', 'Ramanathan', 'priyanka.ramanathan@northwind-fin.com', '+1-212-555-0124', 'agent', 1, 1, '2025-02-10 09:00:00', '2026-06-01 09:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES (4530, 'James', 'Okonkwo', 'james.okonkwo@northwind-fin.com', '+1-212-555-0130', 'manager', 1, 1, '2025-01-20 09:00:00', '2026-06-01 09:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES (4600, 'Elena', 'Kovalenko', 'elena.kovalenko@bluecrest-client.com', '+1-646-555-1000', 'customer', 2, 1, '2025-03-01 09:00:00', '2026-06-01 09:00:00');
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active, sys_created_on, sys_updated_on) VALUES (4601, 'Harold', 'Cheng', 'harold.cheng@bluecrest-client.com', '+1-646-555-1001', 'customer', 2, 1, '2025-03-01 09:00:00', '2026-06-01 09:00:00');

INSERT INTO account (account_id, name, account_type, email_domain, active, sys_created_on, sys_updated_on) VALUES (1, 'Bluecrest Capital Partners', 'customer', 'bluecrest-client.com', 1, '2025-01-15 09:00:00', '2025-01-15 09:00:00');
INSERT INTO account (account_id, name, account_type, email_domain, active, sys_created_on, sys_updated_on) VALUES (2, 'Marston Trust Advisors', 'customer', 'marston-trust.com', 1, '2025-01-20 09:00:00', '2025-01-20 09:00:00');

INSERT INTO product (product_id, name, category, product_price, lifecycle_state, sys_created_on, sys_updated_on) VALUES (100, 'Northwind Treasury Portal', 'software', 25000.00, 'active', '2025-01-01 09:00:00', '2025-01-01 09:00:00');
INSERT INTO product (product_id, name, category, product_price, lifecycle_state, sys_created_on, sys_updated_on) VALUES (101, 'Wire Authorization Service', 'service', 5000.00, 'active', '2025-01-01 09:00:00', '2025-01-01 09:00:00');

INSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary, sys_created_on, sys_updated_on) VALUES (500, 1, 4600, 1, 1, '2025-03-01 09:00:00', '2025-03-01 09:00:00');
INSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary, sys_created_on, sys_updated_on) VALUES (501, 1, 4601, 1, 0, '2025-03-01 09:00:00', '2025-03-01 09:00:00');

INSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status, warranty_end, sys_created_on, sys_updated_on) VALUES (700, 1, 100, 2, 'NWT-BLU-0001', 'in_use', '2027-01-01', '2025-03-01 09:00:00', '2025-03-01 09:00:00');

INSERT INTO contract (contract_id, account_id, contract_type, status, contract_price, start_date, end_date, sys_created_on, sys_updated_on) VALUES (800, 1, 'support', 'active', 60000.00, '2025-04-01', '2026-03-31', '2025-04-01 09:00:00', '2025-04-01 09:00:00');

INSERT INTO entitlement (entitlement_id, account_id, product_id, contract_id, support_level, coverage_hours, max_cases_per_month, active, sys_created_on, sys_updated_on) VALUES (900, 1, 100, 800, 'premium', 'h24x7', 40, 1, '2025-04-01 09:00:00', '2025-04-01 09:00:00');

INSERT INTO sla_definition (sla_def_id, name, metric, target_mins, pause_on_pending, applies_to_priority, active, sys_created_on, sys_updated_on) VALUES (60, 'High Priority Response', 'response', 60, 1, 'high', 1, '2025-01-01 09:00:00', '2025-01-01 09:00:00');
INSERT INTO sla_definition (sla_def_id, name, metric, target_mins, pause_on_pending, applies_to_priority, active, sys_created_on, sys_updated_on) VALUES (61, 'Moderate Response', 'response', 240, 1, 'moderate', 1, '2025-01-01 09:00:00', '2025-01-01 09:00:00');

INSERT INTO user_group_member (member_id, group_id, user_id, sys_created_on) VALUES (1, 10, 4501, '2025-01-10 09:00:00');
INSERT INTO user_group_member (member_id, group_id, user_id, sys_created_on) VALUES (2, 10, 4522, '2025-01-15 09:00:00');
INSERT INTO user_group_member (member_id, group_id, user_id, sys_created_on) VALUES (3, 10, 4530, '2025-01-20 09:00:00');
INSERT INTO user_group_member (member_id, group_id, user_id, sys_created_on) VALUES (4, 11, 4524, '2025-02-10 09:00:00');

INSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count, sys_created_on, sys_updated_on, closed_on) VALUES (6611, 'CS0006611', 1, 500, 101, NULL, 'email', 'high', 'in_progress', 'Client wire authorization renewal - SoX signatory refresh', 10, 4501, 0, NULL, 0, '2026-07-01 10:00:00', '2026-07-10 10:00:00', NULL);
INSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count, sys_created_on, sys_updated_on, closed_on) VALUES (6612, 'CS0006612', 1, 500, 100, 700, 'web', 'moderate', 'in_progress', 'Quarterly account review - reassign to new controller', 10, 4501, 0, NULL, 0, '2026-07-05 10:00:00', '2026-07-12 10:00:00', NULL);

INSERT INTO case_sla (case_sla_id, case_id, sla_def_id, stage, start_time, breach_time, has_breached, completed_time) VALUES (1, 6611, 60, 'in_progress', '2026-07-01 10:00:00', '2026-07-01 11:00:00', 0, NULL);
INSERT INTO case_sla (case_sla_id, case_id, sla_def_id, stage, start_time, breach_time, has_breached, completed_time) VALUES (2, 6612, 61, 'in_progress', '2026-07-05 10:00:00', '2026-07-05 14:00:00', 0, NULL);

INSERT INTO knowledge (knowledge_id, kb_number, title, body, state, visibility, product_id, owner_id, sys_created_on, sys_updated_on) VALUES (200, 'KB0000200', 'Controller Handover SOP', 'Standard operating procedure for controller transitions. Wire authority cases require deputy approval and cannot be transferred to incoming controller until SoX signatory refresh is complete.', 'published', 'internal', 101, 4501, '2025-06-01 09:00:00', '2025-06-01 09:00:00');

INSERT INTO case_knowledge (case_kb_id, case_id, knowledge_id, used_as) VALUES (1, 6611, 200, 'suggested');

INSERT INTO notification (notification_id, case_id, knowledge_id, email, type, status, sys_created_on) VALUES (1, 6611, 200, 'marcus.whitfield@northwind-fin.com', 'update', 'success', '2026-07-10 10:00:00');

INSERT INTO interaction (interaction_id, channel, account_id, contact_id, case_id, interacted_user, status, started_at, ended_at, sys_created_on) VALUES (1, 'email', 1, 500, 6611, 4501, 'handled', '2026-07-01 10:00:00', '2026-07-01 10:30:00', '2026-07-01 10:00:00');
INSERT INTO interaction (interaction_id, channel, account_id, contact_id, case_id, interacted_user, status, started_at, ended_at, sys_created_on) VALUES (2, 'web', 1, 500, 6612, 4501, 'handled', '2026-07-05 10:00:00', '2026-07-05 10:20:00', '2026-07-05 10:00:00');