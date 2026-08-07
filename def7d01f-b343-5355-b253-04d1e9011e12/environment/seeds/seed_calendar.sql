-- MCP Server: calendar_internal

-- Users
INSERT INTO users (user_id, email, name, given_name, family_name, timezone, is_active, is_verified, static_token, created_at, updated_at) VALUES ('priya-sharma', 'priya.sharma@globex.com', 'Priya Sharma', 'Priya', 'Sharma', 'America/Los_Angeles', 1, 1, 'tok_priya-sharma', datetime('now'), datetime('now'));

-- Calendars (target primary + decoys)
INSERT INTO calendars (calendar_id, user_id, summary, description, time_zone, is_primary, hidden, selected, deleted, created_at, updated_at) VALUES ('cal_priya_primary_9f2a', 'priya-sharma', 'Priya Sharma', 'Personal primary calendar', 'America/Los_Angeles', 1, 0, 1, 0, datetime('now'), datetime('now'));
INSERT INTO calendars (calendar_id, user_id, summary, description, time_zone, is_primary, hidden, selected, deleted, created_at, updated_at) VALUES ('cal_priya_reviews_7d3b', 'priya-sharma', 'Team Reviews', 'Recurring team review sessions', 'America/Los_Angeles', 0, 0, 1, 0, datetime('now'), datetime('now'));
INSERT INTO calendars (calendar_id, user_id, summary, description, time_zone, is_primary, hidden, selected, deleted, created_at, updated_at) VALUES ('cal_priya_shared_5e2f', 'priya-sharma', 'Shared Escalation Cal', 'Shared escalation channel calendar', 'America/Los_Angeles', 0, 0, 1, 0, datetime('now'), datetime('now'));
