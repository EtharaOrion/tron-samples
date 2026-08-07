-- MCP Server: sn-csm-server
INSERT INTO location (location_id, name, city, country, active) VALUES (3010, 'Meridian Site A - Austin', 'new_york', 'usa', 1);
INSERT INTO location (location_id, name, city, country, active) VALUES (3011, 'Meridian Site B - Austin', 'new_york', 'usa', 1);
INSERT INTO location (location_id, name, city, country, active) VALUES (3012, 'Meridian Site C - Austin', 'new_york', 'usa', 1);
INSERT INTO user (user_id, first_name, last_name, email, phone, role, location_id, active) VALUES (5001, 'Dana', 'Whitfield', 'chandrapiyush357@gmail.com', '+1-512-555-5001', 'admin', 3010, 1);
INSERT INTO account (account_id, name, account_type, email_domain, active) VALUES (7001, 'Meridian Corp', 'customer', 'meridian.com', 1);
INSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (8001, 'Meridian Gateway 7731', 'hardware', 1200.00, 'active');
INSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (8002, 'Meridian Router 2200', 'hardware', 800.00, 'active');
INSERT INTO product (product_id, name, category, product_price, lifecycle_state) VALUES (8003, 'Meridian Switch 4400', 'hardware', 600.00, 'active');
INSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9001, 7001, 8001, 3011, 'SN-7731-AX', 'in_use');
INSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9002, 7001, 8002, 3011, 'SN-2200-BX', 'in_use');
INSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9003, 7001, 8001, 3010, 'SN-7731-CY', 'in_use');
INSERT INTO installed_product (installed_product_id, account_id, product_id, location_id, serial_number, status) VALUES (9004, 7001, 8003, 3011, 'SN-7731-DZ', 'retired');
