-- MCP Server: sn-csm-server
INSERT INTO location (location_id, name, city, country, active) VALUES (1, 'HQ New York', 'new_york', 'usa', 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (1001, 'Piyush', 'Chandra', 'chandrapiyush357@gmail.com', '+1-555-0001', 'admin', 1, 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (1101, 'Dana', 'Okoro', 'dana.okoro@stellarsystems.com', '+1-555-0100', 'customer', 1, 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (1102, 'Marco', 'Vega', 'marco.vega@stellarsystems.com', '+1-555-0101', 'customer', 1, 1);
INSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (201, 'Stellar Systems', 'customer', 'stellarsystems.com', 1);
INSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (202, 'Stellar Solutions', 'customer', 'stellarsolutions.com', 1);
INSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (601, 'OrbitSuite Pro', 'software', 5000, 'active');
INSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (602, 'OrbitSuite Lite', 'software', 2000, 'active');
INSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (401, 201, 1101, 1, 1);
INSERT INTO contact (contact_id, account_id, portal_user_id, active, is_primary) VALUES (402, 201, 1102, 1, 0);
INSERT INTO contract (contract_id, account_id, contract_type, status, contract_price, start_date, end_date) VALUES (301, 201, 'support', 'active', 45000, '2024-01-01', '2026-12-31');
INSERT INTO contract (contract_id, account_id, contract_type, status, contract_price, start_date, end_date) VALUES (302, 201, 'warranty', 'expired', 12000, '2022-01-01', '2023-12-31');
INSERT INTO entitlement (entitlement_id, account_id, product_id, contract_id, support_level, coverage_hours, max_cases_per_month, active) VALUES (501, 201, 601, 301, 'premium', 'h24x7', 20, 1);
INSERT INTO entitlement (entitlement_id, account_id, product_id, contract_id, support_level, coverage_hours, max_cases_per_month, active) VALUES (502, 201, 602, 302, 'standard', 'h8x5', 5, 0);
