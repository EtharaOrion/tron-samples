-- Database Seed Data for: Anula_first_database_calender
-- Database ID: db_1762357536790_net0vkzbu
-- MCP Server: CALENDER_INTERNAL_PROD
-- Created: 2025-11-05 15:45:40.612547+00:00
-- Description: No description provided
-- NOTE: This is seed data fallback (export-sql API was unavailable)

-- ============================================
-- SEED DATA (SQL Statements)
-- ============================================

-- Multi-User Calendar Sample Data for multi_user_calendar
-- Generated on: 2025-11-05T15:45:03.134475
-- Contains sample data for 4 users with isolated calendars and events

-- Users
INSERT INTO users (user_id, email, name, given_name, family_name, static_token, timezone, is_active, is_verified, created_at, updated_at) VALUES
('alice_manager', 'alice.manager@techcorp.com', 'Alice Johnson', 'Alice', 'Johnson', 'ya29.A0ARrdaM-k9Vq7GzY2pL4mQf8sN1xT0bR3uHcJWv5yKzP6eF2.qwErTyUIopASDfGhJkLzXcVbNm12_34-56', 'America/New_York', 1, 1, datetime('now'), datetime('now')),
('bob_developer', 'bob.smith@techcorp.com', 'Bob Smith', 'Bob', 'Smith', 'ya29.A0ARrdaM-Zx8Nw3Q4pVb6Ls9R1mT0cG2uF5yH7kJd8sA1Lq2.wErtYuIoPaSdFgHjKlZxCvBnM987_65-43', 'America/Los_Angeles', 1, 1, datetime('now'), datetime('now')),
('carol_designer', 'carol.white@techcorp.com', 'Carol White', 'Carol', 'White', 'ya29.A0ARrdaM-b7Hc5Vn2Qm8R1sT4pL0xY9wK3uF6jZ2eRc1.QaWsEdRfTgHyJuIkOlPzXcVbNmKjHgf_21-098', 'Europe/London', 1, 1, datetime('now'), datetime('now')),
('dave_sales', 'dave.brown@techcorp.com', 'Dave Brown', 'Dave', 'Brown', 'ya29.A0ARrdaM-p3Lk9Vb6Qw2Zx8N1sT4mH7gF5yR0uJc2ePq.ZxCvBnMlKjHgFfDsaQwErTyUiOpAsDfGhJk_77-11', 'America/Chicago', 1, 1, datetime('now'), datetime('now'));

-- Calendars
INSERT INTO calendars (calendar_id, user_id, summary, description, time_zone, is_primary, color_id, hidden, selected, deleted, created_at, updated_at) VALUES
('alice-primary', 'alice_manager', 'Alice Johnson', 'Primary calendar for Alice Johnson - Project Manager', 'America/New_York', 1, '1', 0, 1, 0, datetime('now'), datetime('now')),
('alice-projects', 'alice_manager', 'Project Management', 'Project meetings, deadlines, and milestones', 'America/New_York', 0, '7', 0, 1, 0, datetime('now'), datetime('now')),
('alice-team', 'alice_manager', 'Team Coordination', 'Team meetings, 1-on-1s, and team events', 'America/New_York', 0, '11', 0, 1, 0, datetime('now'), datetime('now')),
('bob-primary', 'bob_developer', 'Bob Smith', 'Primary calendar for Bob Smith - Senior Developer', 'America/Los_Angeles', 1, '2', 0, 1, 0, datetime('now'), datetime('now')),
('bob-development', 'bob_developer', 'Development Schedule', 'Sprint planning, code reviews, and development tasks', 'America/Los_Angeles', 0, '9', 0, 1, 0, datetime('now'), datetime('now')),
('bob-personal', 'bob_developer', 'Personal Time', 'Personal appointments and time off', 'America/Los_Angeles', 0, '14', 0, 1, 0, datetime('now'), datetime('now')),
('carol-primary', 'carol_designer', 'Carol White', 'Primary calendar for Carol White - UX Designer', 'Europe/London', 1, '4', 0, 1, 0, datetime('now'), datetime('now')),
('carol-design', 'carol_designer', 'Design Work', 'Design sessions, user research, and creative time', 'Europe/London', 0, '16', 0, 1, 0, datetime('now'), datetime('now')),
('dave-primary', 'dave_sales', 'Dave Brown', 'Primary calendar for Dave Brown - Sales Director', 'America/Chicago', 1, '6', 0, 1, 0, datetime('now'), datetime('now')),
('dave-sales', 'dave_sales', 'Sales Activities', 'Client meetings, sales calls, and deals', 'America/Chicago', 0, '23', 0, 1, 0, datetime('now'), datetime('now'));

-- Office Locations
INSERT INTO office_locations (
    id, buildingId, deskId, floorId, floorSectionId, label
) VALUES
('office-building-1', 'building-1', NULL, NULL, NULL, 'TechCorp Main Campus - Building 1'),
('office-building-2-floor-3', 'building-2', 'desk-W3-45', 'floor-3', 'west-wing', 'TechCorp Main Campus - Building 2, Floor 3, West Wing, Desk W3-45'),
('office-meeting-room-a', 'building-1', NULL, 'floor-1', 'conference-area', 'Conference Room A - Building 1');

-- Recurring Events
INSERT INTO recurring_events (
    recurring_event_id, original_recurrence
) VALUES
('rec-event-001','["RRULE:COUNT=2"]');

-- Events
INSERT INTO events (
    event_id, calendar_id, user_id, recurring_event_id, summary, description, location,
    start_datetime, end_datetime, start_timezone, end_timezone, originalStartTime_date, originalStartTime_dateTime, originalStartTime_timeZone, recurrence,
    status, visibility, color_id, iCalUID, eventType, focusTimeProperties,
    guestsCanInviteOthers, guestsCanModify, guestsCanSeeOtherGuests,
    outOfOfficeProperties, sequence, source, created_at, updated_at
) VALUES
('event-corrected-001', 'alice-projects', 'alice_manager', 'NULL', 'Sprint Planning & Architecture Review', 'Detailed sprint planning session with architecture discussion for Q4 features. We''ll review user stories, estimate effort, and plan the technical approach.', 'Conference Room A, Building 1', '2025-11-05T09:00:00+00:00', '2025-11-05T11:00:00+00:00', 'America/New_York', 'America/New_York', NULL, '2025-11-05T09:00:00+00:00', 'America/New_York', NULL, 'confirmed', 'default', '7', 'event-corrected-001@gmail.com', 'default', NULL, 1, 0, 1, NULL, 1, '{"title": "Sprint Planning Board", "url": "https://jira.techcorp.com/sprint-planning-q4"}', datetime('now'), datetime('now')),
('event-corrected-002', 'bob-development', 'bob_developer', 'NULL', 'Deep Work: Core Algorithm Implementation', 'Focused development time for implementing the new search algorithm. No interruptions please.', 'Developer Workspace, Building 2', '2025-11-06T10:00:00+00:00', '2025-11-06T13:00:00+00:00', 'America/Los_Angeles', 'America/Los_Angeles', NULL, '2025-11-06T10:00:00+00:00', 'America/Los_Angeles', NULL, 'confirmed', 'private', '9', 'event-corrected-002@gmail.com', 'focusTime', '{"autoDeclineMode": "declineOnlyNewConflictingInvitations", "declineMessage": "I''m in focus time. Please reschedule or reach out via Slack for urgent matters.", "chatStatus": {"type": "doNotDisturb"}}', 0, 0, 0, NULL, 0, NULL, datetime('now'), datetime('now')),
('event-corrected-003', 'carol-primary', 'carol_designer', 'NULL', 'Annual Leave - Family Vacation', 'Taking time off for family vacation. Will have limited access to email.', 'Bali, Indonesia', '2025-11-19T09:00:00+00:00', '2025-11-26T09:00:00+00:00', 'Asia/Makassar', 'Asia/Makassar', NULL, '2025-11-19T09:00:00+00:00', 'Asia/Makassar', NULL, 'confirmed', 'public', '4', 'event-corrected-003@gmail.com', 'outOfOffice', NULL, 0, 0, 1, '{"autoDeclineMode": "declineAllConflictingInvitations", "declineMessage": "I''m currently on vacation and won''t be available. For urgent design matters, please contact Sarah (sarah@techcorp.com). I''ll respond to messages when I return.", "autoDeclineEventTypes": ["default", "focusTime", "workingLocation"]}', 0, NULL, datetime('now'), datetime('now')),
('event-corrected-004', 'bob-primary', 'bob_developer', 'NULL', 'Office Day - Collaboration Sessions', 'In office today for team collaboration and pair programming sessions.', NULL, '2025-11-07T09:00:00+00:00', '2025-11-07T17:00:00+00:00', 'America/Los_Angeles', 'America/Los_Angeles', NULL, '2025-11-07T09:00:00+00:00', 'America/Los_Angeles', NULL, 'confirmed', 'public', '2', 'event-corrected-004@gmail.com', 'workingLocation', NULL, 1, 0, 1, NULL, 0, NULL, datetime('now'), datetime('now')),
('event-corrected-005', 'dave-primary', 'dave_sales', 'NULL', 'Dave''s Birthday', 'Happy Birthday Dave!', NULL, '2025-12-05T09:00:00+00:00', '2025-12-05T10:00:00+00:00', NULL, NULL, '2025-12-05', NULL, 'UTC', NULL, 'confirmed', 'public', '6', 'event-corrected-005@gmail.com', 'birthday', NULL, 1, 0, 1, NULL, 0, NULL, datetime('now'), datetime('now')),
('event-corrected-006', 'dave-sales', 'dave_sales', 'rec-event-001', 'Enterprise Client Demo - TechCorp Solutions', 'Product demonstration for MegaCorp Inc. Focus on enterprise features, security, and scalability. Bring pricing sheets and technical specs.', 'MegaCorp Headquarters, 123 Business Ave, New York, NY', '2025-11-08T11:00:00+00:00', '2025-11-08T13:00:00+00:00', 'America/New_York', 'America/New_York', NULL, '2025-11-08T11:00:00+00:00', 'America/New_York', '["RRULE:COUNT=2"]', 'confirmed', 'default', '1', 'event-icalid-001@gmail.com', 'default', NULL, 0, 0, 1, NULL, 2, '{"title": "CRM System - MegaCorp Deal", "url": "https://crm.techcorp.com/deals/megacorp-2024"}', datetime('now'), datetime('now')),
('event-corrected-007', 'dave-sales', 'dave_sales', 'rec-event-001', 'Enterprise Client Demo - TechCorp Solutions', 'Product demonstration for MegaCorp Inc. Focus on enterprise features, security, and scalability. Bring pricing sheets and technical specs.', 'MegaCorp Headquarters, 123 Business Ave, New York, NY', '2025-11-09T11:00:00+00:00', '2025-11-09T13:00:00+00:00', 'America/New_York', 'America/New_York', NULL, '2025-11-09T11:00:00+00:00', 'America/New_York', '["RRULE:COUNT=2"]', 'confirmed', 'default', '1', 'event-icalid-001@gmail.com', 'default', NULL, 0, 0, 1, NULL, 2, '{"title": "CRM System - MegaCorp Deal", "url": "https://crm.techcorp.com/deals/megacorp-2024"}', datetime('now'), datetime('now')),
('event-corrected-008', 'dave-sales', 'dave_sales', 'rec-event-001', 'Enterprise Client Demo - TechCorp Solutions', 'Product demonstration for MegaCorp Inc. Focus on enterprise features, security, and scalability. Bring pricing sheets and technical specs.', 'MegaCorp Headquarters, 123 Business Ave, New York, NY', '2025-11-10T11:00:00+00:00', '2025-11-10T13:00:00+00:00', 'America/New_York', 'America/New_York', NULL, '2025-11-10T11:00:00+00:00', 'America/New_York', '["RRULE:COUNT=2"]', 'confirmed', 'default', '1', 'event-icalid-001@gmail.com', 'default', NULL, 0, 0, 1, NULL, 2, '{"title": "CRM System - MegaCorp Deal", "url": "https://crm.techcorp.com/deals/megacorp-2024"}', datetime('now'), datetime('now'));

-- ConferenceData
INSERT INTO conference_data (
    id, event_id, request_id, solution_type, status_code, meeting_uri, label
) VALUES
('conf-corrected-001', 'event-corrected-001', 'req-sprint-planning-001', 'hangoutsMeet', 'success', 'https://meet.google.com/abc-defg-hij', 'Sprint Planning Meet'),
('conf-corrected-002', 'event-corrected-006', 'req-client-demo-001', 'hangoutsMeet', 'success', 'https://meet.google.com/enterprise-demo-xyz', 'Client Demo Backup');

-- BirthdayProperties
INSERT INTO birthday_properties (id, event_id, type) VALUES
('birthday-corrected-001', 'event-corrected-005', 'birthday');

-- ExtendedProperties
INSERT INTO extended_properties (id, event_id, scope, properties) VALUES
('ext-corrected-001', 'event-corrected-001', 'private', '{"departmentBudget": "engineering", "projectCode": "PROJ-2024-Q4"}'),
('ext-corrected-002', 'event-corrected-001', 'shared', '{"meetingType": "sprint_planning", "priority": "high"}'),
('ext-corrected-003', 'event-corrected-002', 'private', '{"taskType": "development", "estimatedComplexity": "high"}'),
('ext-corrected-004', 'event-corrected-003', 'shared', '{"backupContact": "sarah@techcorp.com", "vacationType": "personal"}'),
('ext-corrected-005', 'event-corrected-004', 'private', '{"commute_reminder": "Leave by 8:00 AM to avoid traffic"}'),
('ext-corrected-006', 'event-corrected-006', 'private', '{"dealValue": "$250000", "clientPriority": "high", "preparationTime": "2 hours"}'),
('ext-corrected-007', 'event-corrected-006', 'shared', '{"meetingType": "client_demo", "department": "sales"}');

-- Reminders
INSERT INTO reminders (id, event_id, method, minutes, use_default) VALUES
('rem-corrected-001', 'event-corrected-001', 'email', 1440, 0),
('rem-corrected-002', 'event-corrected-001', 'popup', 30, 0),
('rem-corrected-003', 'event-corrected-002', 'popup', 15, 0),
('rem-corrected-004', 'event-corrected-003', 'email', 10080, 0),
('rem-corrected-005', 'event-corrected-005', 'popup', 0, 0),
('rem-corrected-006', 'event-corrected-006', 'email', 2880, 0),
('rem-corrected-007', 'event-corrected-006', 'popup', 60, 0),
('rem-corrected-008', 'event-corrected-006', 'popup', 15, 0);

-- Attendees
INSERT INTO attendees (
    attendees_id, event_id, user_id, comment, displayName,
    additionalGuests, optional, resource, responseStatus
) VALUES
('att-corrected-001', 'event-corrected-001', 'alice_manager', 'Looking forward to planning Q4!', 'Alice Johnson', 0, 0, 0, 'accepted'),
('att-corrected-002', 'event-corrected-001', 'bob_developer', NULL, 'Bob Smith', 0, 0, 0, 'accepted'),
('att-corrected-003', 'event-corrected-001', 'carol_designer', 'Will join if no conflicts with user research session', 'Carol White', 0, 1, 0, 'tentative'),
('att-corrected-004', 'event-corrected-001', NULL, NULL, 'Conference Room A', 0, 0, 1, 'accepted'),
('att-corrected-005', 'event-corrected-006', 'dave_sales', 'Prepared demo materials and pricing', 'Dave Brown', 0, 0, 0, 'accepted'),
('att-corrected-006', 'event-corrected-006', NULL, 'Bringing 2 technical team members', 'John Doe', 2, 0, 0, 'accepted'),
('att-corrected-007', 'event-corrected-006', 'sarah_tech', 'Technical support for enterprise questions', 'Sarah Chen', 0, 1, 0, 'accepted'),
('att-corrected-008', 'event-corrected-006', 'alice_manager', NULL, 'Alice Johnson', 0, 1, 0, 'needsAction');

-- Attachments
INSERT INTO attachments (attachment_id, event_id, file_url) VALUES
('attach-corrected-001', 'event-corrected-001', 'https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/view'),
('attach-corrected-002', 'event-corrected-001', 'https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit'),
('attach-corrected-003', 'event-corrected-006', 'https://drive.google.com/file/d/enterprise-demo-deck-2024/view'),
('attach-corrected-004', 'event-corrected-006', 'https://drive.google.com/file/d/pricing-sheet-enterprise-2024/view'),
('attach-corrected-005', 'event-corrected-006', 'https://docs.google.com/document/d/technical-specs-enterprise/edit');

-- Working Location Properties
INSERT INTO working_location_properties (
    working_location_id, event_id, type, homeOffice, customLocationLabel, officeLocationId
) VALUES
('wl-corrected-001', 'event-corrected-004', 'officeLocation', 0, NULL, 'office-building-2-floor-3');

-- Google Calendar Colors (shared across all users)
INSERT INTO colors (color_id, color_type, background, foreground, created_at, updated_at) VALUES
('1', 'CALENDAR', '#ac725e', '#1d1d1d', datetime('now'), datetime('now')),
('2', 'CALENDAR', '#d06b64', '#1d1d1d', datetime('now'), datetime('now')),
('3', 'CALENDAR', '#f83a22', '#1d1d1d', datetime('now'), datetime('now')),
('4', 'CALENDAR', '#fa57c4', '#1d1d1d', datetime('now'), datetime('now')),
('5', 'CALENDAR', '#9fc6e7', '#1d1d1d', datetime('now'), datetime('now')),
('6', 'CALENDAR', '#9a9cff', '#1d1d1d', datetime('now'), datetime('now')),
('7', 'CALENDAR', '#4986e7', '#1d1d1d', datetime('now'), datetime('now')),
('8', 'CALENDAR', '#9aa116', '#1d1d1d', datetime('now'), datetime('now')),
('9', 'CALENDAR', '#ef6c00', '#1d1d1d', datetime('now'), datetime('now')),
('10', 'CALENDAR', '#ff7537', '#1d1d1d', datetime('now'), datetime('now')),
('11', 'CALENDAR', '#42d692', '#1d1d1d', datetime('now'), datetime('now')),
('12', 'CALENDAR', '#16a765', '#1d1d1d', datetime('now'), datetime('now')),
('13', 'CALENDAR', '#7bd148', '#1d1d1d', datetime('now'), datetime('now')),
('14', 'CALENDAR', '#b3dc6c', '#1d1d1d', datetime('now'), datetime('now')),
('15', 'CALENDAR', '#fbe983', '#1d1d1d', datetime('now'), datetime('now')),
('16', 'CALENDAR', '#fad165', '#1d1d1d', datetime('now'), datetime('now')),
('17', 'CALENDAR', '#92e1c0', '#1d1d1d', datetime('now'), datetime('now')),
('18', 'CALENDAR', '#9fe1e7', '#1d1d1d', datetime('now'), datetime('now')),
('19', 'CALENDAR', '#9fc6e7', '#1d1d1d', datetime('now'), datetime('now')),
('20', 'CALENDAR', '#4986e7', '#1d1d1d', datetime('now'), datetime('now')),
('21', 'CALENDAR', '#9aa116', '#1d1d1d', datetime('now'), datetime('now')),
('22', 'CALENDAR', '#16a765', '#1d1d1d', datetime('now'), datetime('now')),
('23', 'CALENDAR', '#ff7537', '#1d1d1d', datetime('now'), datetime('now')),
('24', 'CALENDAR', '#ffad46', '#1d1d1d', datetime('now'), datetime('now')),
('1', 'EVENT', '#a4bdfc', '#1d1d1d', datetime('now'), datetime('now')),
('2', 'EVENT', '#7ae7bf', '#1d1d1d', datetime('now'), datetime('now')),
('3', 'EVENT', '#dbadff', '#1d1d1d', datetime('now'), datetime('now')),
('4', 'EVENT', '#ff887c', '#1d1d1d', datetime('now'), datetime('now')),
('5', 'EVENT', '#fbd75b', '#1d1d1d', datetime('now'), datetime('now')),
('6', 'EVENT', '#ffb878', '#1d1d1d', datetime('now'), datetime('now')),
('7', 'EVENT', '#46d6db', '#1d1d1d', datetime('now'), datetime('now')),
('8', 'EVENT', '#e1e1e1', '#1d1d1d', datetime('now'), datetime('now')),
('9', 'EVENT', '#5484ed', '#1d1d1d', datetime('now'), datetime('now')),
('10', 'EVENT', '#51b749', '#1d1d1d', datetime('now'), datetime('now')),
('11', 'EVENT', '#dc2127', '#1d1d1d', datetime('now'), datetime('now'));

-- Calendar Settings
INSERT INTO settings (id, user_id, value) VALUES
('alice_timezone', 'alice_manager', 'America/New_York'),
('bob_timezone', 'bob_developer', 'America/Los_Angeles'),
('carol_timezone', 'carol_designer', 'Europe/London'),
('dave_timezone', 'dave_sales', 'America/Chicago');


-- ACL Scopes
INSERT INTO scopes (id, type, value) VALUES
('scope-alice', 'user', 'alice.manager@techcorp.com'),
('scope-bob', 'user', 'bob.smith@techcorp.com'),
('scope-carol', 'user', 'carol.white@techcorp.com'),
('scope-dave', 'user', 'dave.brown@techcorp.com'),
('scope-group', 'group', 'product-team@techcorp.com'),
('scope-domain', 'domain', 'techcorp.com'),
('scope-public', 'default', 'public');


-- Access Control Rules
INSERT INTO acls (id, calendar_id, user_id, role, scope_id, etag) VALUES
('acl-alice-primary', 'alice-primary', 'alice_manager', 'owner', 'scope-alice', 'etag-alice-primary'),
('acl-alice-projects', 'alice-projects', 'alice_manager', 'owner', 'scope-alice', 'etag-alice-projects'),
('acl-alice-team', 'alice-team', 'alice_manager', 'owner', 'scope-alice', 'etag-alice-team'),
('acl-bob-primary', 'bob-primary', 'bob_developer', 'owner', 'scope-bob', 'etag-bob-primary'),
('acl-bob-development', 'bob-development', 'bob_developer', 'owner', 'scope-bob', 'etag-bob-development'),
('acl-bob-personal', 'bob-personal', 'bob_developer', 'owner', 'scope-bob', 'etag-bob-personal'),
('acl-carol-primary', 'carol-primary', 'carol_designer', 'owner', 'scope-carol', 'etag-carol-primary'),
('acl-carol-design', 'carol-design', 'carol_designer', 'owner', 'scope-carol', 'etag-carol-design'),
('acl-dave-primary', 'dave-primary', 'dave_sales', 'owner', 'scope-dave', 'etag-dave-primary'),
('acl-dave-sales', 'dave-sales', 'dave_sales', 'owner', 'scope-dave', 'etag-dave-sales'),
('acl-shared-1', 'alice-projects', 'alice_manager', 'writer', 'scope-bob', 'etag-shared-1'),
('acl-shared-2', 'alice-projects', 'alice_manager', 'reader', 'scope-carol', 'etag-shared-2');


-- Generated on: 2025-11-05T15:45:03.135187
-- Contains sample watch channel data for ACL notifications

-- Watch Channels for ACL Notifications
INSERT INTO watch_channels (
    id, resource_id, resource_uri, resource_type, calendar_id, user_id,
    webhook_address, webhook_token, webhook_type, params,
    created_at, expires_at, last_notification_at, is_active, notification_count
) VALUES
('watch-alice-projects-001', 'acl-alice-projects', '/calendars/alice-projects/acl', 'acl', 'alice-projects', 'alice_manager', 'https://techcorp.com/webhooks/alice/acl-notifications', 'alice_token_abc123', 'web_hook', '{"project": "sprint_planning", "team": "development"}', '2025-10-31T15:45:03.135114', '2025-11-30T15:45:03.135114', '2025-11-05T13:45:03.135114', 'true', 12),
('watch-alice-team-002', 'acl-alice-team', '/calendars/alice-team/acl', 'acl', 'alice-team', 'alice_manager', 'https://api.techcorp.com/calendar/notifications/team-acl', 'team_secure_token_xyz789', 'web_hook', '{"alert_level": "high", "notify_admins": true}', '2025-11-03T15:45:03.135114', '2025-12-03T15:45:03.135114', '2025-11-05T09:45:03.135114', 'true', 5),
('watch-bob-dev-001', 'acl-bob-development', '/calendars/bob-development/acl', 'acl', 'bob-development', 'bob_developer', 'https://hooks.slack.com/services/T123/B456/dev-calendar-notifications', NULL, 'web_hook', '{"channel": "#dev-team", "mention_devs": true}', '2025-10-26T15:45:03.135114', '2025-11-25T15:45:03.135114', '2025-11-04T15:45:03.135114', 'true', 23),
('watch-bob-personal-002', 'acl-bob-personal', '/calendars/bob-personal/acl', 'acl', 'bob-personal', 'bob_developer', 'https://api.example.com/personal/calendar/webhook', 'personal_webhook_token_def456', 'web_hook', '{"privacy_mode": true, "minimal_data": true}', '2025-11-04T15:45:03.135114', '2025-12-04T15:45:03.135114', NULL, 'true', 0),
('watch-carol-design-001', 'acl-carol-design', '/calendars/carol-design/acl', 'acl', 'carol-design', 'carol_designer', 'https://design-tools.techcorp.com/calendar/acl-updates', 'design_team_token_ghi789', 'web_hook', '{"tool": "figma_integration", "auto_update_availability": true}', '2025-10-29T15:45:03.135114', '2025-11-28T15:45:03.135114', '2025-11-05T03:45:03.135114', 'true', 8),
('watch-dave-sales-001', 'acl-dave-sales', '/calendars/dave-sales/acl', 'acl', 'dave-sales', 'dave_sales', 'https://crm.techcorp.com/calendar/sales-acl-sync', 'sales_crm_token_jkl012', 'web_hook', '{"crm_sync": true, "lead_tracking": true, "territory": "west_coast"}', '2025-10-22T15:45:03.135114', '2025-11-21T15:45:03.135114', '2025-11-05T11:45:03.135114', 'true', 31),
('watch-alice-expired-001', 'acl-alice-primary', '/calendars/alice-primary/acl', 'acl', 'alice-primary', 'alice_manager', 'https://old-system.techcorp.com/webhooks/acl', 'expired_token_mno345', 'web_hook', '{"legacy_system": true}', '2025-10-01T15:45:03.135114', '2025-10-31T15:45:03.135114', '2025-10-30T15:45:03.135114', 'true', 47),
('watch-bob-stopped-001', 'acl-bob-primary', '/calendars/bob-primary/acl', 'acl', 'bob-primary', 'bob_developer', 'https://temp-webhook.example.com/test', 'temp_token_pqr678', 'web_hook', '{"test_mode": true}', '2025-10-28T15:45:03.135114', '2025-11-27T15:45:03.135114', '2025-11-02T15:45:03.135114', 'false', 15),
('watch-bob-alice-shared-001', 'acl-alice-projects', '/calendars/alice-projects/acl', 'acl', 'alice-projects', 'bob_developer', 'https://api.example.com/shared-calendar/acl-watch', 'shared_access_token_stu901', 'web_hook', '{"shared_calendar": true, "original_owner": "alice_manager"}', '2025-11-02T15:45:03.135114', '2025-12-02T15:45:03.135114', '2025-11-04T21:45:03.135114', 'true', 3);

INSERT INTO users (user_id, email, name, given_name, family_name, static_token, timezone, is_active, is_verified, created_at, updated_at) VALUES ('cal_priya', 'priya.sharma@techcorp.com', 'Priya Sharma', 'Alice', 'Johnson', 'tok_cal_priya', 'America/New_York', '1', '1', '2026-07-17 06:10:51', '2026-07-17 06:10:51');
INSERT INTO calendars (calendar_id, user_id, summary, description, time_zone, is_primary, color_id, hidden, selected, deleted, created_at, updated_at) VALUES ('cal_priya_primary', 'cal_priya', 'Priya Sharma', 'Primary calendar for Alice Johnson - Project Manager', 'America/New_York', '1', '1', '0', '1', '0', '2026-07-17 06:10:51', '2026-07-17 06:10:51');
