-- MCP Server: sn-csm-server
INSERT INTO location (location_id, name, city, country, active) VALUES (11, 'London Operations Center', 'london', 'uk', 1);
INSERT INTO location (location_id, name, city, country, active) VALUES (12, 'New York Operations Center', 'new_york', 'usa', 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (601, 'Marcus', 'Feldman', 'marcus.feldman@acme-support.example', '+44-20-555-0601', 'agent', 11, 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (602, 'Nina', 'Alvarez', 'nina.alvarez@acme-support.example', '+1-212-555-0602', 'agent', 12, 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (603, 'Owen', 'Blake', 'owen.blake@acme-support.example', '+1-212-555-0603', 'agent', 12, 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (604, 'Marcus', 'Feldman', 'marcus.feldman@acme-old.example', '+44-20-555-0604', 'agent', 11, 0);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (701, 'Priya', 'Menon', 'priya.menon@acme-customer.com', '+1-408-555-0701', 'customer', NULL, 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (501, 'Nadia', 'Rahman', 'chandrapiyush357@gmail.com', '+44-20-555-0501', 'agent', 11, 1);
INSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (1001, 'Acme Corporation', 'customer', 'acme-customer.com', 1);
INSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (1002, 'Acme Holdings', 'partner', 'acmeholdings.example', 1);
INSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (3001, 1001, 701, 1, 1);
INSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9001, 'CS0012345', 1001, 3001, NULL, NULL, 'phone', 'high', 'new', 'Reported wire fraud on outbound payment', NULL, NULL, 0, NULL, 0);
INSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9002, 'CS0012346', 1001, 3001, NULL, NULL, 'phone', 'high', 'new', 'Finance recovery sub-case for wire fraud', NULL, NULL, 0, NULL, 0);
INSERT INTO customer_case (case_id, number, account_id, contact_id, product_id, installed_product_id, channel, priority, state, short_description, assignment_group_id, assigned_to, escalation, escalation_reason, reopen_count) VALUES (9003, 'CS0012347', 1001, 3001, NULL, NULL, 'email', 'moderate', 'new', 'General billing inquiry for Acme Corporation', NULL, NULL, 0, NULL, 0);
