INSERT INTO user (
  user_id, first_name, last_name, email, phone, role, location_id, active,
  sys_created_on, sys_updated_on
) VALUES
(1300, 'Maya', 'Chen', 'maya.chen@northstar.example', '+91-90000-09007',
 'admin', NULL, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
(1301, 'Ava', 'Rao', 'ava.rao@aurora-transit.example', '+91-90000-09008',
 'customer', NULL, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
(1302, 'Noah', 'Rao', 'noah.rao@aurora-logistics.example', '+91-90000-09009',
 'customer', NULL, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO account (
  account_id, name, account_type, email_domain, active, sys_created_on, sys_updated_on
) VALUES
(1300, 'Aurora Transit', 'customer', 'aurora-transit.example', TRUE,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
(1301, 'Aurora Logistics', 'customer', 'aurora-logistics.example', TRUE,
 '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO contact (
  contact_id, account_id, portal_user_id, active, is_primary,
  sys_created_on, sys_updated_on
) VALUES
(1300, 1300, 1301, TRUE, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
(1301, 1301, 1302, TRUE, TRUE, '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO product (
  product_id, name, category, product_price, lifecycle_state,
  sys_created_on, sys_updated_on
) VALUES
(1300, 'TransitEdge Controller', 'hardware', 48000.00, 'active',
 '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
(1301, 'TransitEdge Sensor', 'hardware', 12000.00, 'active',
 '2026-07-20 09:00:00', '2026-07-20 09:00:00');

INSERT INTO contract (
  contract_id, account_id, contract_type, status, contract_price, start_date,
  end_date, sys_created_on, sys_updated_on
) VALUES
(1300, 1300, 'support', 'active', 80000.00, '2026-01-01', '2026-12-31',
 '2026-01-01 09:00:00', '2026-01-01 09:00:00'),
(1301, 1301, 'support', 'active', 12000.00, '2026-01-01', '2026-12-31',
 '2026-01-01 09:00:00', '2026-01-01 09:00:00');

INSERT INTO entitlement (
  entitlement_id, account_id, product_id, contract_id, support_level,
  coverage_hours, max_cases_per_month, active, sys_created_on, sys_updated_on
) VALUES
(1300, 1300, 1300, 1300, 'enterprise', 'h24x7', 100, TRUE,
 '2026-01-01 09:00:00', '2026-01-01 09:00:00'),
(1301, 1301, 1300, 1301, 'standard', 'h8x5', 10, FALSE,
 '2026-01-01 09:00:00', '2026-01-01 09:00:00');

INSERT INTO installed_product (
  installed_product_id, account_id, product_id, location_id, serial_number,
  status, warranty_end, sys_created_on, sys_updated_on
) VALUES
(1300, 1300, 1300, NULL, 'ENT-AX-9007', 'in_use', '2028-12-31',
 '2026-02-01 09:00:00', '2026-02-01 09:00:00'),
(1301, 1301, 1300, NULL, 'ENT-AX-9008', 'in_use', '2028-12-31',
 '2026-02-01 09:00:00', '2026-02-01 09:00:00'),
(1302, 1300, 1301, NULL, 'ENT-SN-2100', 'in_use', '2028-12-31',
 '2026-02-01 09:00:00', '2026-02-01 09:00:00');

INSERT INTO customer_case (
  case_id, number, account_id, contact_id, product_id, installed_product_id,
  channel, priority, state, short_description, assignment_group_id, assigned_to,
  escalation, escalation_reason, reopen_count, sys_created_on, sys_updated_on,
  closed_on
) VALUES
(1300, 'CS-V12-09007', 1300, 1300, 1300, 1300, 'email', 'moderate', 'pending',
 'V12 entitlement exception review for Aurora Transit', NULL, 1300, FALSE, NULL,
 0, '2026-07-20 10:00:00', '2026-07-20 10:00:00', NULL),
(1301, 'CS-V12-09008', 1301, 1301, 1300, 1301, 'email', 'moderate', 'new',
 'V12 entitlement exception review for Aurora Logistics', NULL, 1300, FALSE, NULL,
 0, '2026-07-20 10:05:00', '2026-07-20 10:05:00', NULL),
(1302, 'CS-V12-02100', 1300, 1300, 1301, 1302, 'web', 'low', 'new',
 'Routine TransitEdge sensor question', NULL, 1300, FALSE, NULL,
 0, '2026-07-20 10:10:00', '2026-07-20 10:10:00', NULL);

INSERT INTO knowledge (
  knowledge_id, kb_number, title, body, state, visibility, product_id, owner_id,
  sys_created_on, sys_updated_on
) VALUES
(1300, 'KB-CSM-ENT-077', 'V12 Entitlement Exception Standard',
 'R1 A new or pending customer case associated with an in-use installed product is a candidate for escalation. R2 Exception: act only when the same account has an active enterprise entitlement for the installed product product_id. R3 R2 overrides R1, so a look-alike account with inactive or non-enterprise coverage remains untouched. R4 For the qualifying case set state to in_progress, priority to high, escalation to true, and escalation_reason to impact. R5 Resolve the qualifying installed product serial in ITSM and set only that configuration item status to maintenance. R6 Create exactly one Drive file whose entire name is the ITSM-returned serial, mime type text/plain, and description Entitlement exception evidence for Aurora Transit.',
 'published', 'internal', 1300, 1300, '2026-07-20 09:30:00', '2026-07-20 09:30:00');
