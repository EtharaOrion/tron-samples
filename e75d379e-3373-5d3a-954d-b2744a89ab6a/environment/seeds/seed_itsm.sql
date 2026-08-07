-- MCP Server: sn-itsm-internal

-- Organizations
INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES ('org_northwind_fin', 'Northwind Financial', 1, datetime('2026-01-01 08:00:00'), datetime('2026-01-01 08:00:00'));
INSERT INTO organization (org_id, name, active, created_at, updated_at) VALUES ('org_northwind_corp', 'Northwind Corporate Holdings', 1, datetime('2026-01-01 08:00:00'), datetime('2026-01-01 08:00:00'));

-- Roles
INSERT INTO role (role_id, name) VALUES ('ROLE_ADMIN', 'admin');
INSERT INTO role (role_id, name) VALUES ('ROLE_MANAGER', 'manager');
INSERT INTO role (role_id, name) VALUES ('ROLE_AGENT', 'agent');
INSERT INTO role (role_id, name) VALUES ('ROLE_REPORTER', 'reporter');

-- Permissions
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_USR_R', 'users', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_USR_C', 'users', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_GRP_R', 'groups', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_GRP_C', 'groups', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_SVC_R', 'services', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_SVC_C', 'services', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_SO_R', 'service_offerings', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_SO_C', 'service_offerings', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_CI_R', 'configuration_items', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_CI_C', 'configuration_items', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_IT_R', 'incident_templates', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_IT_C', 'incident_templates', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_KB_R', 'knowledge', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_KB_C', 'knowledge', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_INC_R', 'incidents', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_INC_C', 'incidents', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_PRB_R', 'problems', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_PRB_C', 'problems', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_CHG_R', 'changes', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_CHG_C', 'changes', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_SLA_R', 'sla_definitions', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_SLA_C', 'sla_definitions', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_NOT_R', 'notifications', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_NOT_C', 'notifications', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_LOC_R', 'locations', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_LOC_C', 'locations', 'crud');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_ORG_R', 'organizations', 'read');
INSERT INTO permission (perm_id, resource, action) VALUES ('PERM_ORG_C', 'organizations', 'crud');

-- Role-Permission for admin (full CRUD)
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_USR_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_USR_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_GRP_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_GRP_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_SVC_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_SVC_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_SO_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_SO_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_CI_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_CI_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_IT_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_IT_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_KB_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_KB_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_INC_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_INC_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_PRB_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_PRB_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_CHG_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_CHG_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_SLA_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_SLA_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_NOT_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_NOT_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_LOC_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_LOC_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_ORG_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_ADMIN', 'PERM_ORG_C');

-- Manager permissions (read + limited crud)
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_MANAGER', 'PERM_USR_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_MANAGER', 'PERM_INC_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_MANAGER', 'PERM_INC_C');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_MANAGER', 'PERM_KB_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_MANAGER', 'PERM_CHG_R');
INSERT INTO role_permission (role_id, perm_id) VALUES ('ROLE_MANAGER', 'PERM_CHG_C');

-- Locations
INSERT INTO location (location_id, name, org_id, plot_no, street, city, state, country, active, created_on, updated_on) VALUES ('LOC_NYC_TREASURY', 'NYC Treasury Floor', 'org_northwind_fin', '200', 'Wall Street', 'New York', 'NY', 'USA', 1, datetime('2026-01-01 08:00:00'), datetime('2026-01-01 08:00:00'));
INSERT INTO location (location_id, name, org_id, plot_no, street, city, state, country, active, created_on, updated_on) VALUES ('LOC_CHI_OPS', 'Chicago Operations', 'org_northwind_fin', '400', 'LaSalle', 'Chicago', 'IL', 'USA', 1, datetime('2026-01-01 08:00:00'), datetime('2026-01-01 08:00:00'));
INSERT INTO location (location_id, name, org_id, plot_no, street, city, state, country, active, created_on, updated_on) VALUES ('LOC_CORP_HQ', 'Corporate HQ', 'org_northwind_corp', '1', 'Broadway', 'New York', 'NY', 'USA', 1, datetime('2026-01-01 08:00:00'), datetime('2026-01-01 08:00:00'));

-- Users
INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id, created_on, updated_on) VALUES ('usr_marcus_whitfield', 'marcus.whitfield', 'Marcus', 'Whitfield', 'marcus.whitfield@northwind-fin.com', '+1-212-555-1001', 'admin', 1, 'admin_token_marcus_2024_secure', 'org_northwind_fin', 'LOC_NYC_TREASURY', datetime('2026-01-01 08:00:00'), datetime('2026-01-01 08:00:00'));
INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id, created_on, updated_on) VALUES ('usr_priya_ramanathan_correct', 'priya.ramanathan', 'Priya', 'Ramanathan', 'priya.ramanathan@northwind-fin.com', '+1-212-555-1002', 'manager', 1, 'token_priya_correct_2026', 'org_northwind_fin', 'LOC_NYC_TREASURY', datetime('2026-01-05 08:00:00'), datetime('2026-01-05 08:00:00'));
INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id, created_on, updated_on) VALUES ('usr_priya_ramanathan_subsidiary', 'priya.ramanathan2', 'Priya', 'Ramanathan', 'priya.ramanathan@northwind-corp.com', '+1-212-555-1003', 'manager', 1, 'token_priya_subsidiary_2026', 'org_northwind_corp', 'LOC_CORP_HQ', datetime('2026-01-05 08:00:00'), datetime('2026-01-05 08:00:00'));
INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id, created_on, updated_on) VALUES ('usr_priya_s_ramanathan', 'priya.s.ramanathan', 'Priya', 'Ramanathan', 'priya.s.ramanathan@northwind-fin.com', '+1-212-555-1004', 'agent', 1, 'token_priya_s_2026', 'org_northwind_fin', 'LOC_NYC_TREASURY', datetime('2026-01-06 08:00:00'), datetime('2026-01-06 08:00:00'));
INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id, created_on, updated_on) VALUES ('usr_priyanka_ramanathan', 'priyanka.ramanathan', 'Priyanka', 'Ramanathan', 'priyanka.ramanathan@northwind-fin.com', '+1-212-555-1005', 'manager', 1, 'token_priyanka_2026', 'org_northwind_fin', 'LOC_NYC_TREASURY', datetime('2026-01-07 08:00:00'), datetime('2026-01-07 08:00:00'));
INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id, created_on, updated_on) VALUES ('usr_priya_ramanathan_retired', 'priya.ramanathan.old', 'Priya', 'Ramanathan', 'priya.ramanathan.legacy@northwind-fin.com', '+1-212-555-1006', 'manager', 0, 'token_priya_retired_2026', 'org_northwind_fin', 'LOC_CHI_OPS', datetime('2024-01-01 08:00:00'), datetime('2025-06-01 08:00:00'));
INSERT INTO users (user_id, user_name, first_name, last_name, email, phone, role, active, static_token, org_id, location_id, created_on, updated_on) VALUES ('usr_james_okonkwo', 'james.okonkwo', 'James', 'Okonkwo', 'james.okonkwo@northwind-fin.com', '+1-212-555-1007', 'manager', 1, 'token_james_okonkwo_2026', 'org_northwind_fin', 'LOC_NYC_TREASURY', datetime('2026-01-02 08:00:00'), datetime('2026-01-02 08:00:00'));

-- User-Role assignments
INSERT INTO user_role (user_id, role_id, org_id) VALUES ('usr_marcus_whitfield', 'ROLE_ADMIN', 'org_northwind_fin');
INSERT INTO user_role (user_id, role_id, org_id) VALUES ('usr_priya_ramanathan_correct', 'ROLE_MANAGER', 'org_northwind_fin');
INSERT INTO user_role (user_id, role_id, org_id) VALUES ('usr_priya_ramanathan_subsidiary', 'ROLE_MANAGER', 'org_northwind_corp');
INSERT INTO user_role (user_id, role_id, org_id) VALUES ('usr_priya_s_ramanathan', 'ROLE_AGENT', 'org_northwind_fin');
INSERT INTO user_role (user_id, role_id, org_id) VALUES ('usr_priyanka_ramanathan', 'ROLE_MANAGER', 'org_northwind_fin');
INSERT INTO user_role (user_id, role_id, org_id) VALUES ('usr_james_okonkwo', 'ROLE_MANAGER', 'org_northwind_fin');

-- Knowledge Base article (SoX Controller Handover policy)
INSERT INTO knowledge (knowledge_id, kb_number, title, short_description, body, state, visibility, owner_id, org_id, created_on, updated_on) VALUES ('kb_controller_handover_sox', 'KB0012077', 'SoX Executive Controller Handover - Change-Freeze, MNPI, and Least-Disclosure Runbook', 'Runbook for controller handover under SoX change freeze', 'POLICY: (1) Verify incoming controller by SIX facts (email, first, last, org, location, position=Treasury Manager). (2) Wire or payment authority artifacts route to the deputy of record NEVER the incoming controller. (3) Calendar transfer = insert acls role owner with scope pointing to incoming corporate email AND remove outgoing owner acl. (4) Drive transfer = if incoming already holds a permission on file, upgrade via update_permission (create_permission 409s), else create owner then delete outgoing owner. (5) LEAVE change-freeze rows untouched (any change or incident tagged FREEZE-2026Q3). (6) Cutoff = 2026-07-15 17:00 America New_York (=2026-07-15 21:00Z), events strictly after transferred, before untouched. (7) MNPI rationale ONLY inside hr_case worknotes, neutral phrasing everywhere else. (8) NO Teams writes under any circumstance. (9) Closing summary MUST declare each abstention with policy cite and calibrated confidence.', 'published', 'internal', 'usr_marcus_whitfield', 'org_northwind_fin', datetime('2026-06-01 08:00:00'), datetime('2026-06-01 08:00:00'));

-- Frozen Changes (FREEZE-2026Q3)
INSERT INTO change (change_id, number, short_description, requested_by, org_id, status, category, description, cab_required, impact, priority, risk, created_on, updated_on) VALUES ('chg_freeze_a', 'CHG0004411', 'FREEZE-2026Q3: General Ledger cutover', 'usr_marcus_whitfield', 'org_northwind_fin', 'scheduled', 'software', 'General ledger cutover under Q3 SoX freeze window', 1, 'high', 'high', 'high', datetime('2026-06-15 08:00:00'), datetime('2026-06-15 08:00:00'));
INSERT INTO change (change_id, number, short_description, requested_by, org_id, status, category, description, cab_required, impact, priority, risk, created_on, updated_on) VALUES ('chg_freeze_b', 'CHG0004412', 'FREEZE-2026Q3: Payment gateway TLS rotation', 'usr_marcus_whitfield', 'org_northwind_fin', 'scheduled', 'network', 'Payment gateway TLS certificate rotation under Q3 SoX freeze', 1, 'high', 'critical', 'high', datetime('2026-06-16 08:00:00'), datetime('2026-06-16 08:00:00'));

-- Frozen Incident (FREEZE-2026Q3)
INSERT INTO incident (incident_id, number, short_description, caller_id, org_id, status, category, on_hold_reason, priority, impact, urgency, description, created_at, updated_at) VALUES ('inc_freeze_a', 'INC0009901', 'FREEZE-2026Q3: SAP FI reconciliation variance', 'usr_marcus_whitfield', 'org_northwind_fin', 'on_hold', 'software', 'Awaiting Change', 'high', 'high', 'high', 'SAP FI reconciliation variance under Q3 SoX freeze - do not modify', datetime('2026-06-20 08:00:00'), datetime('2026-06-20 08:00:00'));