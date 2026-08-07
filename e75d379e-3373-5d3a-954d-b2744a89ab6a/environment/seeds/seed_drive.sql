-- MCP Server: gdrive-v5

INSERT INTO users (id, email, display_name, auth_token, created_time, kind) VALUES ('01HZMWWHITFIELDMARCUS0001', 'marcus.whitfield@northwind-fin.com', 'Marcus Whitfield', 'JWT_MARCUS_WF', '2026-01-01 00:00:00', 'drive#user');
INSERT INTO users (id, email, display_name, auth_token, created_time, kind) VALUES ('01HZMWPRIYARAMANATHAN0002', 'priya.ramanathan@northwind-fin.com', 'Priya Ramanathan', 'JWT_PRIYA_R', '2026-01-01 00:00:00', 'drive#user');

INSERT INTO drives (id, name, created_time, modified_time, kind, hidden, trashed) VALUES ('drv_finops', 'FinOps Shared Drive', '2026-01-01 00:00:00', '2026-01-01 00:00:00', 'drive#drive', 0, 0);

INSERT INTO files (id, drive_id, name, mime_type, created_by, created_time, modified_time, kind, space, trashed, starred, shared) VALUES ('file_wire_matrix', 'drv_finops', 'Controller Wire Authority Matrix — 2026Q3.xlsx', 'application/vnd.google-apps.spreadsheet', '01HZMWWHITFIELDMARCUS0001', '2026-05-01 10:00:00', '2026-06-01 10:00:00', 'drive#file', 'drive', 0, 0, 1);
INSERT INTO files (id, drive_id, name, mime_type, created_by, created_time, modified_time, kind, space, trashed, starred, shared) VALUES ('file_close_binder', 'drv_finops', 'Monthly Close Binder — Master.gdoc', 'application/vnd.google-apps.document', '01HZMWWHITFIELDMARCUS0001', '2026-05-01 10:00:00', '2026-06-01 10:00:00', 'drive#file', 'drive', 0, 0, 1);

INSERT INTO permissions (id, file_id, user_id, role, type, kind, email_address, domain, inherited, created_time) VALUES ('perm_marcus_owner_wire', 'file_wire_matrix', '01HZMWWHITFIELDMARCUS0001', 'owner', 'user', 'drive#permission', NULL, NULL, 0, '2026-05-01 10:00:00');
INSERT INTO permissions (id, file_id, user_id, role, type, kind, email_address, domain, inherited, created_time) VALUES ('perm_priya_reader_wire', 'file_wire_matrix', '01HZMWPRIYARAMANATHAN0002', 'reader', 'user', 'drive#permission', NULL, NULL, 0, '2026-05-15 10:00:00');
INSERT INTO permissions (id, file_id, user_id, role, type, kind, email_address, domain, inherited, created_time) VALUES ('perm_marcus_owner_binder', 'file_close_binder', '01HZMWWHITFIELDMARCUS0001', 'owner', 'user', 'drive#permission', NULL, NULL, 0, '2026-05-01 10:00:00');
