-- Database Seed Data for: email-db-siddharthkaushik
-- Database ID: db_1763188937209_paq12p3yu
-- MCP Server: EMAIL_INTERNAL_PROD
-- Created: 2025-11-15 06:42:18.832783+00:00
-- Description: No description provided
-- NOTE: This is seed data fallback (export-sql API was unavailable)

-- ============================================
-- SEED DATA (SQL Statements)
-- ============================================

-- Email MCP Server Sample Data
-- Comprehensive Email API-compliant test data
-- Note: Tables are created dynamically by SQLAlchemy models, this file contains only sample data

-- Users (Email accounts)
INSERT INTO users (id, token, primary_email, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES
('user_001', 'tok_alice_2025_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6', 'alice@example.com', 150, 45, '12345678901', '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('user_002', 'tok_bob_2025_q1w2e3r4t5y6u7i8o9p0a1s2d3f4g5h6', 'bob@company.com', 89, 23, '12345678902', '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('user_003', 'tok_carol_2025_z1x2c3v4b5n6m7l8k9j0h1g2f3d4s5a6', 'carol@university.edu', 234, 67, '12345678903', '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('user_004', 'tok_david_2025_m1n2b3v4c5x6z7l8k9j0h1g2f3d4s5a6', 'david@startup.io', 45, 12, '12345678904', '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('user_005', 'tok_eve_2025_p1o2i3u4y5t6r7e8w9q0a1s2d3f4g5h6', 'eve@freelancer.net', 178, 56, '12345678905', '2024-01-12 11:45:00', '2024-01-23 15:33:00');

-- Labels (Email API v1 compliant labels including system and user-created with proper color format)
INSERT INTO labels (id, user_id, name, type, messages_total, messages_unread, threads_total, threads_unread, message_list_visibility, label_list_visibility, color_json, created_at, updated_at) VALUES
-- System labels (no colors for system labels)
('label_001', 'user_001', 'INBOX', 'system', 45, 12, 23, 8, 'show', 'labelShow', NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('label_002', 'user_001', 'SENT', 'system', 67, 0, 34, 0, 'show', 'labelShow', NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('label_003', 'user_001', 'DRAFT', 'system', 3, 3, 2, 2, 'show', 'labelShow', NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('label_004', 'user_001', 'SPAM', 'system', 5, 5, 3, 3, 'hide', 'labelHide', NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('label_005', 'user_001', 'TRASH', 'system', 8, 0, 5, 0, 'hide', 'labelHide', NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),

-- User labels with Email API color format
('label_006', 'user_001', 'Projects', 'user', 12, 4, 8, 3, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#4285f4"}', '2024-01-16 14:20:00', '2024-01-20 14:22:00'),
('label_007', 'user_001', 'Important', 'user', 15, 8, 10, 6, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#ea4335"}', '2024-01-17 09:30:00', '2024-01-20 14:22:00'),
('label_008', 'user_001', 'Personal', 'user', 22, 5, 14, 3, 'show', 'labelShowIfUnread', '{"textColor": "#000000", "backgroundColor": "#fad165"}', '2024-01-18 11:15:00', '2024-01-20 14:22:00'),

-- User 2 labels
('label_009', 'user_002', 'INBOX', 'system', 23, 7, 15, 5, 'show', 'labelShow', NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('label_010', 'user_002', 'SENT', 'system', 31, 0, 19, 0, 'show', 'labelShow', NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('label_025', 'user_002', 'DRAFT', 'system', 2, 2, 1, 1, 'show', 'labelShow', NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('label_026', 'user_002', 'SPAM', 'system', 1, 1, 1, 1, 'hide', 'labelHide', NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('label_027', 'user_002', 'TRASH', 'system', 0, 0, 0, 0, 'hide', 'labelHide', NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('label_011', 'user_002', 'Work', 'user', 45, 12, 18, 7, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#16a766"}', '2024-01-17 11:30:00', '2024-01-19 16:45:00'),
('label_012', 'user_002', 'Urgent', 'user', 8, 8, 6, 6, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#cc3a21"}', '2024-01-18 14:45:00', '2024-01-19 16:45:00'),

-- User 3 labels
('label_013', 'user_003', 'INBOX', 'system', 78, 23, 35, 15, 'show', 'labelShow', NULL, '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('label_014', 'user_003', 'SENT', 'system', 89, 0, 42, 0, 'show', 'labelShow', NULL, '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('label_015', 'user_003', 'Research', 'user', 34, 8, 12, 4, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#a479e2"}', '2024-01-11 13:45:00', '2024-01-22 11:30:00'),
('label_016', 'user_003', 'Teaching', 'user', 28, 12, 18, 8, 'show', 'labelShow', '{"textColor": "#000000", "backgroundColor": "#43d692"}', '2024-01-12 10:20:00', '2024-01-22 11:30:00'),
('label_017', 'user_003', 'Archive', 'user', 67, 0, 25, 0, 'hide', 'labelHide', '{"textColor": "#666666", "backgroundColor": "#efefef"}', '2024-01-13 16:30:00', '2024-01-22 11:30:00'),

-- User 4 labels
('label_018', 'user_004', 'INBOX', 'system', 12, 5, 8, 3, 'show', 'labelShow', NULL, '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('label_019', 'user_004', 'Investors', 'user', 15, 6, 10, 4, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#285bac"}', '2024-01-19 11:10:00', '2024-01-21 09:10:00'),
('label_020', 'user_004', 'Product', 'user', 8, 3, 5, 2, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#f691b3"}', '2024-01-20 15:25:00', '2024-01-21 09:10:00'),

-- User 5 labels
('label_021', 'user_005', 'INBOX', 'system', 42, 18, 28, 12, 'show', 'labelShow', NULL, '2024-01-12 11:45:00', '2024-01-23 15:33:00'),
('label_022', 'user_005', 'Clients', 'user', 67, 15, 35, 8, 'show', 'labelShow', '{"textColor": "#ffffff", "backgroundColor": "#149e60"}', '2024-01-13 09:30:00', '2024-01-23 15:33:00'),
('label_023', 'user_005', 'Proposals', 'user', 23, 9, 14, 6, 'show', 'labelShow', '{"textColor": "#000000", "backgroundColor": "#ffad47"}', '2024-01-14 14:20:00', '2024-01-23 15:33:00'),
('label_024', 'user_005', 'Completed', 'user', 88, 0, 45, 0, 'show', 'labelHide', '{"textColor": "#ffffff", "backgroundColor": "#0b804b"}', '2024-01-15 16:15:00', '2024-01-23 15:33:00');

-- Threads (Email conversation threads)
INSERT INTO threads (id, user_id, history_id_last, snippet, created_at, updated_at) VALUES
('thread_001', 'user_001', '12345678901', 'Meeting tomorrow at 3pm - Please confirm your attendance for the quarterly review meeting...', '2024-01-20 09:15:00', '2024-01-20 14:22:00'),
('thread_002', 'user_001', '12345678901', 'Project update required - The latest project milestone needs your review and approval...', '2024-01-19 16:30:00', '2024-01-20 08:45:00'),
('thread_003', 'user_002', '12345678902', 'Budget proposal - Attached is the Q2 budget proposal for your department...', '2024-01-18 11:20:00', '2024-01-19 16:45:00'),
('thread_004', 'user_003', '12345678903', 'Research paper collaboration - Would you be interested in collaborating on the machine learning paper...', '2024-01-17 14:10:00', '2024-01-22 11:30:00'),
('thread_005', 'user_004', '12345678904', 'Startup pitch deck - Here is the updated pitch deck for next weeks investor meeting...', '2024-01-21 10:30:00', '2024-01-21 15:20:00'),

-- Additional threads for messages that reference them
('thread_new_006', 'user_005', '12345678905', 'Web development project proposal - Thank you for your interest...', '2024-01-16 11:00:00', '2024-01-16 12:15:00'),
('thread_new_007', 'user_005', '12345678905', 'Monthly invoice - Please find attached invoice for services...', '2024-01-20 08:20:00', '2024-01-20 08:20:00'),
('thread_new_008', 'user_001', '12345678901', 'Promotional offer - Get 50% off on all products...', '2024-01-19 12:00:00', '2024-01-19 12:00:00'),
('thread_new_009', 'user_002', '12345678902', 'Urgent: Verify your account - Click here to verify...', '2024-01-18 15:30:00', '2024-01-18 15:30:00'),
('thread_new_010', 'user_003', '12345678903', 'Conference paper accepted - Congratulations! Your paper has been accepted...', '2024-01-23 09:20:00', '2024-01-23 09:20:00'),
('thread_new_011', 'user_004', '12345678904', 'Product roadmap Q2 2024 - Here is our updated product roadmap...', '2024-01-22 10:00:00', '2024-01-22 10:00:00'),
('thread_new_012', 'user_005', '12345678905', 'Project completed - I am pleased to inform you that the website project...', '2024-01-23 16:45:00', '2024-01-23 16:45:00');

-- Messages (Email messages - fully normalized structure)
INSERT INTO messages (id, user_id, thread_id, snippet, history_id_last, internal_date_ms, size_estimate, created_at, updated_at) VALUES
('msg_001', 'user_001', 'thread_001', 'Meeting tomorrow at 3pm - Please confirm your attendance...', 'hist_001', '1705742100000', 1245, '2024-01-20 09:15:00', '2024-01-20 14:22:00'),
('msg_002', 'user_001', 'thread_002', 'Project update required - The latest project milestone...', 'hist_002', '1705655400000', 1156, '2024-01-19 16:30:00', '2024-01-20 08:45:00'),
('msg_003', 'user_001', 'thread_001', 'Re: Meeting tomorrow at 3pm - Confirmed, I will attend the meeting...', 'hist_003', '1705746600000', 850, '2024-01-20 14:22:00', '2024-01-20 14:22:00'),
('msg_004', 'user_002', 'thread_003', 'Budget proposal - Attached is the Q2 budget proposal...', 'hist_004', '1705568400000', 1200, '2024-01-18 11:20:00', '2024-01-19 16:45:00'),
('msg_005', 'user_002', 'thread_003', 'Re: Budget proposal - Thank you for the proposal, I have reviewed...', 'hist_005', '1705654800000', 980, '2024-01-19 16:40:00', '2024-01-19 16:45:00');

-- Message Parts (Normalized message structure)
INSERT INTO message_parts (id, message_id, parent_part_id, part_id, mime_type, filename, created_at, updated_at) VALUES
-- msg_001 parts
('mp_001', 'msg_001', NULL, '0', 'text/plain', NULL, '2024-01-20 09:15:00', '2024-01-20 09:15:00'),

-- msg_002 parts  
('mp_002', 'msg_002', NULL, '0', 'text/plain', NULL, '2024-01-19 16:30:00', '2024-01-19 16:30:00'),

-- msg_003 parts
('mp_003', 'msg_003', NULL, '0', 'text/plain', NULL, '2024-01-20 14:22:00', '2024-01-20 14:22:00'),

-- msg_004 parts
('mp_004', 'msg_004', NULL, '0', 'text/plain', NULL, '2024-01-18 11:20:00', '2024-01-18 11:20:00'),

-- msg_005 parts
('mp_005', 'msg_005', NULL, '0', 'text/plain', NULL, '2024-01-19 16:40:00', '2024-01-19 16:40:00');

-- Message Headers (Normalized headers)
INSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES
-- msg_001 headers
('mh_001', 'mp_001', 'Subject', 'Quarterly Review Meeting', '2024-01-20 09:15:00', '2024-01-20 09:15:00'),
('mh_002', 'mp_001', 'From', 'manager@company.com', '2024-01-20 09:15:00', '2024-01-20 09:15:00'),
('mh_003', 'mp_001', 'To', 'alice@example.com', '2024-01-20 09:15:00', '2024-01-20 09:15:00'),
('mh_004', 'mp_001', 'Date', 'Sat, 20 Jan 2024 09:15:00 +0000', '2024-01-20 09:15:00', '2024-01-20 09:15:00'),
('mh_005', 'mp_001', 'Message-ID', '<20240120091500.A1B2C3@company.com>', '2024-01-20 09:15:00', '2024-01-20 09:15:00'),

-- msg_002 headers
('mh_006', 'mp_002', 'Subject', 'Project Milestone Review', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),
('mh_007', 'mp_002', 'From', 'team@company.com', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),
('mh_008', 'mp_002', 'To', 'alice@example.com', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),
('mh_009', 'mp_002', 'Cc', 'project-team@company.com', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),
('mh_010', 'mp_002', 'Date', 'Fri, 19 Jan 2024 16:30:00 +0000', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),
('mh_011', 'mp_002', 'Message-ID', '<20240119163000.D4E5F6@company.com>', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),

-- msg_003 headers
('mh_012', 'mp_003', 'Subject', 'Re: Quarterly Review Meeting', '2024-01-20 14:22:00', '2024-01-20 14:22:00'),
('mh_013', 'mp_003', 'From', 'alice@example.com', '2024-01-20 14:22:00', '2024-01-20 14:22:00'),
('mh_014', 'mp_003', 'To', 'manager@company.com', '2024-01-20 14:22:00', '2024-01-20 14:22:00'),
('mh_015', 'mp_003', 'Date', 'Sat, 20 Jan 2024 14:22:00 +0000', '2024-01-20 14:22:00', '2024-01-20 14:22:00'),
('mh_016', 'mp_003', 'Message-ID', '<20240120142200.G7H8I9@example.com>', '2024-01-20 14:22:00', '2024-01-20 14:22:00'),

-- msg_004 headers
('mh_017', 'mp_004', 'Subject', 'Q2 Budget Proposal', '2024-01-18 11:20:00', '2024-01-18 11:20:00'),
('mh_018', 'mp_004', 'From', 'finance@company.com', '2024-01-18 11:20:00', '2024-01-18 11:20:00'),
('mh_019', 'mp_004', 'To', 'bob@company.com', '2024-01-18 11:20:00', '2024-01-18 11:20:00'),
('mh_020', 'mp_004', 'Date', 'Thu, 18 Jan 2024 11:20:00 +0000', '2024-01-18 11:20:00', '2024-01-18 11:20:00'),
('mh_021', 'mp_004', 'Message-ID', '<20240118112000.J1K2L3@company.com>', '2024-01-18 11:20:00', '2024-01-18 11:20:00'),

-- msg_005 headers
('mh_022', 'mp_005', 'Subject', 'Re: Q2 Budget Proposal', '2024-01-19 16:40:00', '2024-01-19 16:40:00'),
('mh_023', 'mp_005', 'From', 'bob@company.com', '2024-01-19 16:40:00', '2024-01-19 16:40:00'),
('mh_024', 'mp_005', 'To', 'finance@company.com', '2024-01-19 16:40:00', '2024-01-19 16:40:00'),
('mh_025', 'mp_005', 'Date', 'Fri, 19 Jan 2024 16:40:00 +0000', '2024-01-19 16:40:00', '2024-01-19 16:40:00'),
('mh_026', 'mp_005', 'Message-ID', '<20240119164000.M4N5O6@company.com>', '2024-01-19 16:40:00', '2024-01-19 16:40:00');

-- Message Part Bodies (Normalized body content)
INSERT INTO message_part_bodies (id, message_part_id, size, data, attachment_id, created_at, updated_at) VALUES
-- msg_001 body
('mpb_001', 'mp_001', 612, 'SGkgQWxpY2UsCgpQbGVhc2UgY29uZmlybSB5b3VyIGF0dGVuZGFuY2UgZm9yIHRoZSBxdWFydGVybHkgcmV2aWV3IG1lZXRpbmcgdG9tb3Jyb3cgYXQgM3BtIGluIENvbmZlcmVuY2UgUm9vbSBBLgoKV2Ugd2lsbCBiZSBkaXNjdXNzaW5nOgotIFE0IHBlcmZvcm1hbmNlIG1ldHJpY3MKLSAyMDI0IGdvYWxzIGFuZCBvYmplY3RpdmVzCi0gQnVkZ2V0IGFsbG9jYXRpb25zCi0gVGVhbSByZXN0cnVjdHVyaW5nIHBsYW5zCgpQbGVhc2UgYnJpbmcgeW91ciBxdWFydGVybHkgcmVwb3J0IGFuZCBhbnkgc3VwcG9ydGluZyBkb2N1bWVudHMuCgpCZXN0IHJlZ2FyZHMsCk1hbmFnZXI=', NULL, '2024-01-20 09:15:00', '2024-01-20 09:15:00'),

-- msg_002 body
('mpb_002', 'mp_002', 1156, 'SGVsbG8gQWxpY2UsCgpUaGUgbGF0ZXN0IHByb2plY3QgbWlsZXN0b25lIG5lZWRzIHlvdXIgcmV2aWV3IGFuZCBhcHByb3ZhbCBiZWZvcmUgd2UgY2FuIHByb2NlZWQgdG8gdGhlIG5leHQgcGhhc2UuCgpQbGVhc2UgcmV2aWV3IHRoZSBhdHRhY2hlZCBwcm9qZWN0IG1pbGVzdG9uZSBkb2N1bWVudCBhbmQgcHJvdmlkZSB5b3VyIGZlZWRiYWNrIGJ5IGVuZCBvZiB3ZWVrLgoKS2V5IGl0ZW1zIGZvciByZXZpZXc6Ci0gVGVjaG5pY2FsIHNwZWNpZmljYXRpb25zCi0gVGltZWxpbmUgYWRqdXN0bWVudHMKLSBSZXNvdXJjZSBhbGxvY2F0aW9uCi0gUmlzayBhc3Nlc3NtZW50CgpMZXQgbWUga25vdyBpZiB5b3UgaGF2ZSBhbnkgcXVlc3Rpb25zLgoKQmVzdCwKUHJvamVjdCBUZWFt', 'att_001', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),

-- msg_003 body
('mpb_003', 'mp_003', 850, 'SGkgTWFuYWdlciwKCkNvbmZpcm1lZCwgaSB3aWxsIGF0dGVuZCB0aGUgbWVldGluZyB0b21vcnJvdyBhdCAzcG0gaW4gQ29uZmVyZW5jZSBSb29tIEEuCgpJIGhhdmUgcHJlcGFyZWQgbXkgcXVhcnRlcmx5IHJlcG9ydCBhbmQgd2lsbCBicmluZyBhbGwgc3VwcG9ydGluZyBkb2N1bWVudHMgYXMgcmVxdWVzdGVkLgoKTG9va2luZyBmb3J3YXJkIHRvIGRpc2N1c3NpbmcgdGhlIHF1YXJ0ZXJseSByZXN1bHRzIGFuZCBwbGFubmluZyBmb3IgMjAyNC4KCkJlc3QgcmVnYXJkcywKQWxpY2U=', NULL, '2024-01-20 14:22:00', '2024-01-20 14:22:00'),

-- msg_004 body
('mpb_004', 'mp_004', 1200, 'RGVhciBCb2IsCgpBdHRhY2hlZCBpcyB0aGUgUTIgYnVkZ2V0IHByb3Bvc2FsIGZvciB5b3VyIGRlcGFydG1lbnQgcmV2aWV3LgoKUGxlYXNlIHJldmlldyB0aGUgZm9sbG93aW5nIHNlY3Rpb25zOgotIFBlcnNvbm5lbCBjb3N0cwotIEVxdWlwbWVudCBhbmQgc3VwcGxpZXMKLSBUcmFpbmluZyBhbmQgZGV2ZWxvcG1lbnQKLSBPcGVyYXRpb25hbCBleHBlbnNlcwoKV2UgbmVlZCB5b3VyIGFwcHJvdmFsIGJ5IEphbnVhcnkgMjV0aCB0byBmaW5hbGl6ZSB0aGUgYnVkZ2V0LgoKSWYgeW91IGhhdmUgYW55IHF1ZXN0aW9ucyBvciBuZWVkIGNsYXJpZmljYXRpb24gb24gYW55IGxpbmUgaXRlbXMsIHBsZWFzZSBsZXQgbWUga25vdy4KCkJlc3QgcmVnYXJkcywKRmluYW5jZSBUZWFt', 'att_002', '2024-01-18 11:20:00', '2024-01-18 11:20:00'),

-- msg_005 body
('mpb_005', 'mp_005', 980, 'SGkgRmluYW5jZSBUZWFtLAoKVGhhbmsgeW91IGZvciB0aGUgcHJvcG9zYWwuIEkgaGF2ZSByZXZpZXdlZCB0aGUgUTIgYnVkZ2V0IGFuZCBoYXZlIGEgZmV3IGNvbW1lbnRzOgoKMS4gUGVyc29ubmVsIGNvc3RzIGxvb2sgcmVhc29uYWJsZQoyLiBFcXVpcG1lbnQgYnVkZ2V0IHNlZW1zIGhpZ2ggLSBjYW4gd2UgcmVkdWNlIGJ5IDE1JT8KMy4gVHJhaW5pbmcgYnVkZ2V0IGlzIGFwcHJvdmVkIGFzIHJlcXVlc3RlZAo0LiBPcGVyYXRpb25hbCBleHBlbnNlcyBuZWVkIGNsYXJpZmljYXRpb24gb24gdHJhdmVsIGNvc3RzCgpPdmVyYWxsLCB0aGUgcHJvcG9zYWwgaXMgd2VsbCBzdHJ1Y3R1cmVkLiBQbGVhc2Ugc2VuZCBhIHJldmlzZWQgdmVyc2lvbiBhZGRyZXNzaW5nIHRoZSBlcXVpcG1lbnQgYW5kIHRyYXZlbCBjb3N0IHF1ZXN0aW9ucy4KCkkgY2FuIGFwcHJvdmUgb25jZSB0aGVzZSBpdGVtcyBhcmUgY2xhcmlmaWVkLgoKQmVzdCwKQm9i', NULL, '2024-01-19 16:40:00', '2024-01-19 16:40:00');
-- Currently testing with 5 Gmail API compliant messages (msg_001 to msg_005)

-- Attachments (Email attachments)
INSERT INTO attachments (id, message_id, user_id, filename, mime_type, size, part_id, created_at) VALUES
('att_001', 'msg_002', 'user_001', 'project_milestone.pdf', 'application/pdf', 245760, 'ANGjdJ8w1XYZ...', '2024-01-19 16:30:00'),
('att_002', 'msg_004', 'user_002', 'Q2_Budget_Proposal.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 87552, 'ANGjdJ8w2ABC...', '2024-01-18 11:20:00');

-- Message-Label Junction Table (replaces label_ids JSON in messages)
INSERT INTO message_labels (message_id, label_id) VALUES
-- msg_001 labels: INBOX, Projects
('msg_001', 'label_001'),
('msg_001', 'label_006'),
-- msg_002 labels: INBOX, Important  
('msg_002', 'label_001'),
('msg_002', 'label_007'),
-- msg_003 labels: SENT
('msg_003', 'label_002'),
-- msg_004 labels: INBOX, Work
('msg_004', 'label_009'),
('msg_004', 'label_011'),
-- msg_005 labels: SENT, Urgent
('msg_005', 'label_010'),
('msg_005', 'label_012'),
-- msg_006 labels: INBOX, Research
('msg_006', 'label_013'),
('msg_006', 'label_015'),
-- msg_007 labels: SENT, Teaching
('msg_007', 'label_014'),
('msg_007', 'label_016'),
-- msg_008 labels: INBOX, Investors
('msg_008', 'label_018'),
('msg_008', 'label_019'),
-- msg_009 labels: INBOX, Clients
('msg_009', 'label_021'),
('msg_009', 'label_022'),
-- msg_010 labels: INBOX, Proposals
('msg_010', 'label_021'),
('msg_010', 'label_023'),
-- msg_011 labels: TRASH (spam message)
('msg_011', 'label_005'),
-- msg_012 labels: SPAM
('msg_012', 'label_026'),
-- msg_013 labels: INBOX, Archive
('msg_013', 'label_013'),
('msg_013', 'label_017'),
-- msg_014 labels: INBOX, Product
('msg_014', 'label_018'),
('msg_014', 'label_020'),
-- msg_015 labels: INBOX, Completed
('msg_015', 'label_021'),
('msg_015', 'label_024'),

-- Draft message labels (DRAFT system label)
('draft_msg_001', 'label_003'),
('draft_msg_002', 'label_003'),
('draft_msg_003', 'label_003'),
('draft_msg_004', 'label_003'),
('draft_msg_005', 'label_003');

-- Additional Messages for Drafts (Gmail API compliant)
INSERT INTO messages (id, user_id, thread_id, snippet, history_id_last, internal_date_ms, size_estimate, created_at, updated_at) VALUES
('draft_msg_001', 'user_001', 'thread_draft_001', 'Thank you for your email, I will review the meeting agenda...', 'hist_draft_001', '1705742100000', 245, '2024-01-20 15:30:00', '2024-01-20 15:45:00'),
('draft_msg_002', 'user_003', 'thread_draft_002', 'I would be happy to collaborate on the machine learning paper...', 'hist_draft_002', '1705655400000', 312, '2024-01-22 12:00:00', '2024-01-22 12:15:00'),
('draft_msg_003', 'user_002', 'thread_draft_003', 'Please find attached the budget analysis report...', 'hist_draft_003', '1705568400000', 428, '2024-01-18 16:20:00', '2024-01-19 09:30:00'),
('draft_msg_004', 'user_004', 'thread_draft_004', 'Following up on our investor meeting discussion...', 'hist_draft_004', '1705481400000', 356, '2024-01-21 14:10:00', '2024-01-21 14:25:00'),
('draft_msg_005', 'user_005', 'thread_draft_005', 'Thank you for considering my proposal for the web development project...', 'hist_draft_005', '1705394400000', 295, '2024-01-16 11:40:00', '2024-01-16 12:15:00');

-- Additional Threads for Drafts
INSERT INTO threads (id, user_id, history_id_last, snippet, created_at, updated_at) VALUES
('thread_draft_001', 'user_001', 'hist_draft_001', 'Thank you for your email, I will review the meeting agenda...', '2024-01-20 15:30:00', '2024-01-20 15:45:00'),
('thread_draft_002', 'user_003', 'hist_draft_002', 'I would be happy to collaborate on the machine learning paper...', '2024-01-22 12:00:00', '2024-01-22 12:15:00'),
('thread_draft_003', 'user_002', 'hist_draft_003', 'Please find attached the budget analysis report...', '2024-01-18 16:20:00', '2024-01-19 09:30:00'),
('thread_draft_004', 'user_004', 'hist_draft_004', 'Following up on our investor meeting discussion...', '2024-01-21 14:10:00', '2024-01-21 14:25:00'),
('thread_draft_005', 'user_005', 'hist_draft_005', 'Thank you for considering my proposal for the web development project...', '2024-01-16 11:40:00', '2024-01-16 12:15:00');

-- Message Parts for Draft Messages
INSERT INTO message_parts (id, message_id, parent_part_id, part_id, mime_type, filename, created_at, updated_at) VALUES
('mp_draft_001', 'draft_msg_001', NULL, '0', 'text/plain', NULL, '2024-01-20 15:30:00', '2024-01-20 15:30:00'),
('mp_draft_002', 'draft_msg_002', NULL, '0', 'text/plain', NULL, '2024-01-22 12:00:00', '2024-01-22 12:00:00'),
('mp_draft_003', 'draft_msg_003', NULL, '0', 'text/plain', NULL, '2024-01-18 16:20:00', '2024-01-18 16:20:00'),
('mp_draft_004', 'draft_msg_004', NULL, '0', 'text/plain', NULL, '2024-01-21 14:10:00', '2024-01-21 14:10:00'),
('mp_draft_005', 'draft_msg_005', NULL, '0', 'text/plain', NULL, '2024-01-16 11:40:00', '2024-01-16 11:40:00');

-- Message Headers for Draft Messages
INSERT INTO message_headers (id, message_part_id, name, value, created_at, updated_at) VALUES
-- draft_msg_001 headers
('mh_draft_001', 'mp_draft_001', 'Subject', 'Re: Quarterly Review Meeting', '2024-01-20 15:30:00', '2024-01-20 15:30:00'),
('mh_draft_002', 'mp_draft_001', 'From', 'alice@example.com', '2024-01-20 15:30:00', '2024-01-20 15:30:00'),
('mh_draft_003', 'mp_draft_001', 'To', 'manager@company.com', '2024-01-20 15:30:00', '2024-01-20 15:30:00'),
('mh_draft_004', 'mp_draft_001', 'Date', 'Sat, 20 Jan 2024 15:30:00 +0000', '2024-01-20 15:30:00', '2024-01-20 15:30:00'),

-- draft_msg_002 headers
('mh_draft_005', 'mp_draft_002', 'Subject', 'Re: ML Research Collaboration', '2024-01-22 12:00:00', '2024-01-22 12:00:00'),
('mh_draft_006', 'mp_draft_002', 'From', 'carol@university.edu', '2024-01-22 12:00:00', '2024-01-22 12:00:00'),
('mh_draft_007', 'mp_draft_002', 'To', 'colleague@university.edu', '2024-01-22 12:00:00', '2024-01-22 12:00:00'),
('mh_draft_008', 'mp_draft_002', 'Date', 'Mon, 22 Jan 2024 12:00:00 +0000', '2024-01-22 12:00:00', '2024-01-22 12:00:00'),

-- draft_msg_003 headers
('mh_draft_009', 'mp_draft_003', 'Subject', 'Budget Analysis Q1 2024', '2024-01-18 16:20:00', '2024-01-18 16:20:00'),
('mh_draft_010', 'mp_draft_003', 'From', 'bob@company.com', '2024-01-18 16:20:00', '2024-01-18 16:20:00'),
('mh_draft_011', 'mp_draft_003', 'To', 'finance@company.com', '2024-01-18 16:20:00', '2024-01-18 16:20:00'),
('mh_draft_012', 'mp_draft_003', 'Date', 'Thu, 18 Jan 2024 16:20:00 +0000', '2024-01-18 16:20:00', '2024-01-18 16:20:00'),

-- draft_msg_004 headers
('mh_draft_013', 'mp_draft_004', 'Subject', 'Follow-up: Investment Discussion', '2024-01-21 14:10:00', '2024-01-21 14:10:00'),
('mh_draft_014', 'mp_draft_004', 'From', 'david@startup.io', '2024-01-21 14:10:00', '2024-01-21 14:10:00'),
('mh_draft_015', 'mp_draft_004', 'To', 'investor@vc.com', '2024-01-21 14:10:00', '2024-01-21 14:10:00'),
('mh_draft_016', 'mp_draft_004', 'Date', 'Sun, 21 Jan 2024 14:10:00 +0000', '2024-01-21 14:10:00', '2024-01-21 14:10:00'),

-- draft_msg_005 headers
('mh_draft_017', 'mp_draft_005', 'Subject', 'Web Development Project Proposal', '2024-01-16 11:40:00', '2024-01-16 11:40:00'),
('mh_draft_018', 'mp_draft_005', 'From', 'eve@freelancer.net', '2024-01-16 11:40:00', '2024-01-16 11:40:00'),
('mh_draft_019', 'mp_draft_005', 'To', 'client@smallbiz.com', '2024-01-16 11:40:00', '2024-01-16 11:40:00'),
('mh_draft_020', 'mp_draft_005', 'Date', 'Tue, 16 Jan 2024 11:40:00 +0000', '2024-01-16 11:40:00', '2024-01-16 11:40:00');

-- Message Part Bodies for Draft Messages
INSERT INTO message_part_bodies (id, message_part_id, size, data, attachment_id, created_at, updated_at) VALUES
('mpb_draft_001', 'mp_draft_001', 245, 'VGhhbmsgeW91IGZvciB5b3VyIGVtYWlsLiBJIHdpbGwgcmV2aWV3IHRoZSBtZWV0aW5nIGFnZW5kYSBhbmQgcHJvdmlkZSBmZWVkYmFjayBieSB0b21vcnJvdy4gTG9va2luZyBmb3J3YXJkIHRvIGRpc2N1c3NpbmcgdGhlIHF1YXJ0ZXJseSByZXN1bHRzLg==', NULL, '2024-01-20 15:30:00', '2024-01-20 15:30:00'),
('mpb_draft_002', 'mp_draft_002', 312, 'SSB3b3VsZCBiZSBoYXBweSB0byBjb2xsYWJvcmF0ZSBvbiB0aGUgbWFjaGluZSBsZWFybmluZyBwYXBlci4gTXkgZXhwZXJ0aXNlIGluIG5ldXJhbCBuZXR3b3JrcyB3b3VsZCBjb21wbGVtZW50IHlvdXIgd29yayBvbiBkYXRhIHByZXByb2Nlc3NpbmcuIFdoZW4gY2FuIHdlIHNjaGVkdWxlIGEgbWVldGluZyB0byBkaXNjdXNzIHRoZSBwcm9qZWN0IHRpbWVsaW5lPw==', NULL, '2024-01-22 12:00:00', '2024-01-22 12:00:00'),
('mpb_draft_003', 'mp_draft_003', 428, 'UGxlYXNlIGZpbmQgYXR0YWNoZWQgdGhlIGJ1ZGdldCBhbmFseXNpcyByZXBvcnQgZm9yIFE0IDIwMjQuIFRoZSBkZXBhcnRtZW50IGhhcyBzdGF5ZWQgd2l0aGluIGJ1ZGdldCBjb25zdHJhaW50cyBhbmQgaWRlbnRpZmllZCBwb3RlbnRpYWwgY29zdCBzYXZpbmdzIGluIG9wZXJhdGlvbmFsIGV4cGVuc2VzLg==', NULL, '2024-01-18 16:20:00', '2024-01-18 16:20:00'),
('mpb_draft_004', 'mp_draft_004', 356, 'Rm9sbG93aW5nIHVwIG9uIG91ciBpbnZlc3RvciBtZWV0aW5nIGRpc2N1c3Npb24gbGFzdCB3ZWVrLiBJIGhhdmUgcHJlcGFyZWQgdGhlIGFkZGl0aW9uYWwgZmluYW5jaWFsIHByb2plY3Rpb25zIHlvdSByZXF1ZXN0ZWQgYW5kIHdvdWxkIGxpa2UgdG8gc2NoZWR1bGUgYSBmb2xsb3ctdXAgY2FsbCB0byBhZGRyZXNzIGFueSByZW1haW5pbmcgcXVlc3Rpb25zLg==', NULL, '2024-01-21 14:10:00', '2024-01-21 14:10:00'),
('mpb_draft_005', 'mp_draft_005', 295, 'VGhhbmsgeW91IGZvciBjb25zaWRlcmluZyBteSBwcm9wb3NhbCBmb3IgdGhlIHdlYiBkZXZlbG9wbWVudCBwcm9qZWN0LiBJIGhhdmUgcmV2aWV3ZWQgeW91ciByZXF1aXJlbWVudHMgYW5kIGJlbGlldmUgSSBjYW4gZGVsaXZlciBhIG1vZGVybiwgcmVzcG9uc2l2ZSB3ZWJzaXRlIHRoYXQgbWVldHMgYWxsIHlvdXIgc3BlY2lmaWNhdGlvbnMgd2l0aGluIHRoZSBwcm9wb3NlZCB0aW1lbGluZS4=', NULL, '2024-01-16 11:40:00', '2024-01-16 11:40:00');

-- Drafts (Gmail API compliant - links to Messages)
INSERT INTO drafts (id, message_id, created_at, updated_at) VALUES
('draft_001', 'draft_msg_001', '2024-01-20 15:30:00', '2024-01-20 15:45:00'),
('draft_002', 'draft_msg_002', '2024-01-22 12:00:00', '2024-01-22 12:15:00'),
('draft_003', 'draft_msg_003', '2024-01-18 16:20:00', '2024-01-19 09:30:00'),
('draft_004', 'draft_msg_004', '2024-01-21 14:10:00', '2024-01-21 14:25:00'),
('draft_005', 'draft_msg_005', '2024-01-16 11:40:00', '2024-01-16 12:15:00');

-- History Events (Gmail API v1 compliant history structure)
INSERT INTO history_events (id, user_id, history_id, event_type, event_timestamp, event_data, created_at, updated_at) VALUES
-- Message added events (chronological order by integer history_id)
('hist_001', 'user_001', '1', 'messageAdded', '2024-01-19 12:00:00', '{"message": {"id": "msg_011", "threadId": "thread_new_008"}}', '2024-01-19 12:00:00', '2024-01-19 12:00:00'),
('hist_002', 'user_002', '2', 'messageAdded', '2024-01-18 11:20:00', '{"message": {"id": "msg_004", "threadId": "thread_003"}}', '2024-01-18 11:20:00', '2024-01-18 11:20:00'),
('hist_003', 'user_002', '3', 'messageAdded', '2024-01-18 15:30:00', '{"message": {"id": "msg_012", "threadId": "thread_new_009"}}', '2024-01-18 15:30:00', '2024-01-18 15:30:00'),
('hist_004', 'user_001', '4', 'messageAdded', '2024-01-19 16:30:00', '{"message": {"id": "msg_002", "threadId": "thread_002"}}', '2024-01-19 16:30:00', '2024-01-19 16:30:00'),
('hist_005', 'user_002', '5', 'messageAdded', '2024-01-19 16:40:00', '{"message": {"id": "msg_005", "threadId": "thread_003"}}', '2024-01-19 16:40:00', '2024-01-19 16:40:00'),

-- Label events
('hist_006', 'user_001', '6', 'labelAdded', '2024-01-20 08:30:00', '{"message": {"id": "msg_002", "threadId": "thread_002"}, "labelIds": ["label_007"]}', '2024-01-20 08:30:00', '2024-01-20 08:30:00'),
('hist_007', 'user_005', '7', 'messageAdded', '2024-01-20 08:20:00', '{"message": {"id": "msg_010", "threadId": "thread_new_007"}}', '2024-01-20 08:20:00', '2024-01-20 08:20:00'),
('hist_008', 'user_001', '8', 'messageAdded', '2024-01-20 09:15:00', '{"message": {"id": "msg_001", "threadId": "thread_001"}}', '2024-01-20 09:15:00', '2024-01-20 09:15:00'),
('hist_009', 'user_001', '9', 'messageAdded', '2024-01-20 14:22:00', '{"message": {"id": "msg_003", "threadId": "thread_001"}}', '2024-01-20 14:22:00', '2024-01-20 14:22:00'),
('hist_010', 'user_004', '10', 'messageAdded', '2024-01-21 10:30:00', '{"message": {"id": "msg_008", "threadId": "thread_005"}}', '2024-01-21 10:30:00', '2024-01-21 10:30:00'),

-- More label events
('hist_011', 'user_003', '11', 'labelAdded', '2024-01-21 15:00:00', '{"message": {"id": "msg_006", "threadId": "thread_004"}, "labelIds": ["label_015"]}', '2024-01-21 15:00:00', '2024-01-21 15:00:00'),
('hist_012', 'user_004', '12', 'messageAdded', '2024-01-22 10:00:00', '{"message": {"id": "msg_014", "threadId": "thread_new_011"}}', '2024-01-22 10:00:00', '2024-01-22 10:00:00'),
('hist_013', 'user_003', '13', 'messageAdded', '2024-01-22 11:30:00', '{"message": {"id": "msg_007", "threadId": "thread_004"}}', '2024-01-22 11:30:00', '2024-01-22 11:30:00'),
('hist_014', 'user_002', '14', 'labelRemoved', '2024-01-22 16:20:00', '{"message": {"id": "msg_012", "threadId": "thread_new_009"}, "labelIds": ["label_026"]}', '2024-01-22 16:20:00', '2024-01-22 16:20:00'),
('hist_015', 'user_003', '15', 'messageAdded', '2024-01-23 09:20:00', '{"message": {"id": "msg_013", "threadId": "thread_new_010"}}', '2024-01-23 09:20:00', '2024-01-23 09:20:00'),

-- Message deleted events
('hist_016', 'user_001', '16', 'messageDeleted', '2024-01-23 10:45:00', '{"message": {"id": "msg_spam_001", "threadId": "thread_spam_001"}}', '2024-01-23 10:45:00', '2024-01-23 10:45:00'),
('hist_017', 'user_005', '17', 'messageAdded', '2024-01-23 16:45:00', '{"message": {"id": "msg_015", "threadId": "thread_new_012"}}', '2024-01-23 16:45:00', '2024-01-23 16:45:00'),
('hist_018', 'user_005', '18', 'labelAdded', '2024-01-23 17:00:00', '{"message": {"id": "msg_015", "threadId": "thread_new_012"}, "labelIds": ["label_024"]}', '2024-01-23 17:00:00', '2024-01-23 17:00:00'),
('hist_019', 'user_002', '19', 'labelRemoved', '2024-01-23 18:30:00', '{"message": {"id": "msg_004", "threadId": "thread_003"}, "labelIds": ["label_009"]}', '2024-01-23 18:30:00', '2024-01-23 18:30:00'),
('hist_020', 'user_003', '20', 'messageDeleted', '2024-01-23 19:15:00', '{"message": {"id": "msg_old_001", "threadId": "thread_old_001"}}', '2024-01-23 19:15:00', '2024-01-23 19:15:00');


-- Watch Subscriptions (Gmail API Push notification settings)
INSERT INTO watch_subscriptions (id, user_id, topic_name, label_ids, label_filter_behavior, history_id, expiration, is_active, created_at, updated_at) VALUES
('watch_001', 'user_001', 'projects/email-project/topics/email-push', '["label_001", "label_004"]', 'include', '12345678901', '1640995200000', true, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('watch_002', 'user_002', 'projects/email-project/topics/work-emails', '["label_005", "label_006"]', 'include', '12345678902', '1640995200000', true, '2024-01-16 09:15:00', '2024-01-19 16:45:00');


-- Email Settings Tables Data

-- Auto-forwarding Settings (Email users.settings.autoForwarding)
INSERT INTO auto_forwarding (id, user_id, enabled, email_address, disposition, created_at, updated_at) VALUES
('autofw_001', 'user_001', false, NULL, 'leaveInInbox', '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('autofw_002', 'user_002', true, 'bob.backup@company.com', 'archive', '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('autofw_003', 'user_003', false, NULL, 'leaveInInbox', '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('autofw_004', 'user_004', true, 'backup@startup.io', 'markRead', '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('autofw_005', 'user_005', false, NULL, 'leaveInInbox', '2024-01-12 11:45:00', '2024-01-23 15:33:00');

-- IMAP Settings (Email users.settings.imap)
INSERT INTO imap_settings (id, user_id, enabled, auto_expunge, expunge_behavior, max_folder_size, created_at, updated_at) VALUES
('imap_001', 'user_001', true, true, 'archive', 1000, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('imap_002', 'user_002', true, false, 'trash', 2000, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('imap_003', 'user_003', true, true, 'deleteForever', 0, '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('imap_004', 'user_004', false, true, 'archive', 1000, '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('imap_005', 'user_005', true, true, 'archive', 5000, '2024-01-12 11:45:00', '2024-01-23 15:33:00');

-- Language Settings (Email users.settings.language)
INSERT INTO language_settings (id, user_id, display_language, created_at, updated_at) VALUES
('lang_001', 'user_001', 'en-US', '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('lang_002', 'user_002', 'en-GB', '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('lang_003', 'user_003', 'en-US', '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('lang_004', 'user_004', 'en-US', '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('lang_005', 'user_005', 'fr', '2024-01-12 11:45:00', '2024-01-23 15:33:00');

-- POP Settings (Email users.settings.pop)
INSERT INTO pop_settings (id, user_id, access_window, disposition, created_at, updated_at) VALUES
('pop_001', 'user_001', 'disabled', 'leaveInInbox', '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('pop_002', 'user_002', 'fromNowOn', 'archive', '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('pop_003', 'user_003', 'allMail', 'markRead', '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('pop_004', 'user_004', 'disabled', 'leaveInInbox', '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('pop_005', 'user_005', 'fromNowOn', 'trash', '2024-01-12 11:45:00', '2024-01-23 15:33:00');

-- Vacation Settings (Email users.settings.vacation)
INSERT INTO vacation_settings (id, user_id, enable_auto_reply, response_subject, response_body_plain_text, response_body_html, restrict_to_contacts, restrict_to_domain, start_time, end_time, created_at, updated_at) VALUES
('vac_001', 'user_001', false, NULL, NULL, NULL, false, false, NULL, NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('vac_002', 'user_002', true, 'Out of Office', 'Thank you for your email. I am currently out of office and will return on February 1st. For urgent matters, please contact my manager.', '<p>Thank you for your email.</p><p>I am currently <strong>out of office</strong> and will return on <em>February 1st</em>.</p><p>For urgent matters, please contact my manager.</p>', true, false, '1706745600000', '1707350400000', '2024-01-16 09:15:00', '2024-01-25 10:00:00'),
('vac_003', 'user_003', true, 'Academic Conference - Limited Email Access', 'I am attending an academic conference and will have limited email access until January 30th. I will respond to emails upon my return.', '<div><p>I am attending an <strong>academic conference</strong> and will have limited email access until <em>January 30th</em>.</p><p>I will respond to emails upon my return.</p><p>Best regards,<br>Dr. Carol</p></div>', false, true, '1706572800000', '1706659200000', '2024-01-10 08:00:00', '2024-01-28 14:30:00'),
('vac_004', 'user_004', false, NULL, NULL, NULL, false, false, NULL, NULL, '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('vac_005', 'user_005', true, 'Working Remotely', 'I am currently working remotely but checking emails regularly. Response time may be slightly delayed.', '<p>I am currently <strong>working remotely</strong> but checking emails regularly.</p><p>Response time may be slightly delayed.</p><p>Thank you for your patience!</p>', false, false, '1705881600000', '1708473600000', '2024-01-12 11:45:00', '2024-01-22 09:20:00');

-- CSE Key Pairs (Email API v1 Client-Side Encryption Key Pairs)
INSERT INTO cse_key_pairs (id, user_id, key_pair_id, pkcs7, pem, subject_email_addresses, enablement_state, disable_time, created_at, updated_at) VALUES
-- User 1 (alice@example.com) - Primary key pair enabled for enterprise email
('cse_kp_001', 'user_001', 'kp_alice_abc12345_2024',
'-----BEGIN PKCS7-----MIIGCAYJKoZIhvcNAQcCoIIF+TCCBPUIBAT...truncated_pkcs7_alice...-----END PKCS7-----',
'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZ...truncated...alice_primary_cert-----END CERTIFICATE-----',
'["alice@example.com", "alice.work@example.com"]', 'enabled', NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) - Business key pair with KACLS metadata
('cse_kp_002', 'user_002', 'kp_bob_def67890_2024',
'-----BEGIN PKCS7-----MIIGCAYJKoZIhvcNAQcCoIIF+TCCBPUIBAT...truncated_pkcs7_bob...-----END PKCS7-----',
'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZ...truncated...bob_business_cert-----END CERTIFICATE-----',
'["bob@company.com"]', 'enabled', NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) - Academic key pair for research
('cse_kp_003', 'user_003', 'kp_carol_ghi13579_2024',
'-----BEGIN PKCS7-----MIIGCAYJKoZIhvcNAQcCoIIF+TCCBPUIBAT...truncated_pkcs7_carol...-----END PKCS7-----',
'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZ...truncated...carol_research_cert-----END CERTIFICATE-----',
'["carol@university.edu", "c.researcher@university.edu"]', 'enabled', NULL, '2024-01-10 08:00:00', '2024-01-22 11:30:00'),

-- User 3 (carol@university.edu) - Secondary key pair with hardware key metadata
('cse_kp_004', 'user_003', 'kp_carol_secure_24680_2024',
'-----BEGIN PKCS7-----MIIGCAYJKoZIhvcNAQcCoIIF+TCCBPUIBAT...truncated_pkcs7_carol_secure...-----END PKCS7-----',
'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZ...truncated...carol_secure_cert-----END CERTIFICATE-----',
'["carol@university.edu"]', 'enabled', NULL, '2024-01-11 10:15:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) - Startup business key pair
('cse_kp_005', 'user_004', 'kp_david_jkl97531_2024',
'-----BEGIN PKCS7-----MIIGCAYJKoZIhvcNAQcCoIIF+TCCBPUIBAT...truncated_pkcs7_david...-----END PKCS7-----',
'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZ...truncated...david_business_cert-----END CERTIFICATE-----',
'["david@startup.io", "ceo@startup.io"]', 'enabled', NULL, '2024-01-18 13:20:00', '2024-01-21 09:10:00'),

-- User 2 (bob@company.com) - Disabled legacy key pair for testing disable/enable functionality
('cse_kp_006', 'user_002', 'kp_bob_legacy_86420_2023',
'-----BEGIN PKCS7-----MIIGCAYJKoZIhvcNAQcCoIIF+TCCBPUIBAT...truncated_pkcs7_bob_legacy...-----END PKCS7-----',
'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZ...truncated...bob_legacy_cert-----END CERTIFICATE-----',
'["bob@company.com"]', 'disabled', '2024-01-25 14:30:00', '2024-01-16 09:15:00', '2024-01-25 14:30:00');

-- CSE Private Key Metadata (Email API v1 Private Key Metadata for CSE Key Pairs)
INSERT INTO cse_private_key_metadata (
  id,
  key_pair_id,
  private_key_metadata_id,
  metadata_type,
  kacls_uri,
  kacls_data,
  hardware_description,
  created_at,
  updated_at
) VALUES
-- User 1 (alice@example.com) - KACLS metadata for primary key pair
('meta_alice_kacls_001', 'cse_kp_001', 'pkm_alice_001', 'kacls',
 'https://kacls.example.com/v1/keys',
 'eyJ1c2VySWQiOiJhbGljZUBleGFtcGxlLmNvbSIsImtleUlkIjoia3BfYWxpY2VfYWJjMTIzNDVfMjAyNCIsImFjY2Vzc1BvbGljaWVzIjpbeyJyb2xlIjoib3duZXIiLCJwZXJtaXNzaW9ucyI6WyJkZWNyeXB0Iiwic2lnbiJdfV19',
 'Nitrokey Pro 2', '2024-01-15 10:30:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) - KACLS metadata for business key pair
('meta_bob_kacls_002', 'cse_kp_002', 'pkm_bob_002', 'kacls',
 'https://kacls.company.com/api/v2/keys',
 'eyJ1c2VySWQiOiJib2JAY29tcGFueS5jb20iLCJrZXlJZCI6ImtwX2JvYl9kZWY2Nzg5MF8yMDI0IiwiYWNjZXNzUG9saWNpZXMiOlt7InJvbGUiOiJ1c2VyIiwicGVybWlzc2lvbnMiOlsiZGVjcnlwdCJdfSx7InJvbGUiOiJhZG1pbiIsInBlcm1pc3Npb25zIjpbImRlY3J5cHQiLCJzaWduIiwibWFuYWdlIl19XX0=',
 'Nitrokey Pro 2', '2024-01-16 09:15:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) - Hardware key metadata for secure key pair
('meta_carol_hw_003', 'cse_kp_004', 'pkm_carol_003', 'hardware',
 'kacls', 'https://kacls.example.com/v1/keys',
 'YubiKey 5 NFC Smart Card - University issued hardware security key for high-security research communications. Serial: YK5N-123456789. Stored in secure university key management facility.',
 '2024-01-11 10:15:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) - KACLS metadata for startup key pair
('meta_david_kacls_004', 'cse_kp_005', 'pkm_david_004', 'kacls',
 'https://kacls.startup.io/keys/v1',
 'eyJ1c2VySWQiOiJkYXZpZEBzdGFydHVwLmlvIiwia2V5SWQiOiJrcF9kYXZpZF9qa2w5NzUzMV8yMDI0IiwiYWNjZXNzUG9saWNpZXMiOlt7InJvbGUiOiJjZW8iLCJwZXJtaXNzaW9ucyI6WyJkZWNyeXB0Iiwic2lnbiIsImFkbWluIl19LHsicm9sZSI6InRlYW0iLCJwZXJtaXNzaW9ucyI6WyJkZWNyeXB0Il19XX0=',
 'Nitrokey Pro 2', '2024-01-18 13:20:00', '2024-01-21 09:10:00'),

-- User 3 (carol@university.edu) - Mixed metadata for research key pair (both KACLS and hardware)
('meta_carol_kacls_005', 'cse_kp_003', 'pkm_carol_005', 'kacls',
 'https://kacls.university.edu/research/keys',
 'eyJ1c2VySWQiOiJjYXJvbEB1bml2ZXJzaXR5LmVkdSIsImtleUlkIjoia3BfY2Fyb2xfZ2hpMTM1NzlfMjAyNCIsImFjY2Vzc1BvbGljaWVzIjpbeyJyb2xlIjoicmVzZWFyY2hlciIsInBlcm1pc3Npb25zIjpbImRlY3J5cHQiLCJzaWduIl19LHsicm9sZSI6ImRlcGFydG1lbnQiLCJwZXJtaXNzaW9ucyI6WyJkZWNyeXB0Il19XX0=',
 'Nitrokey Pro 2', '2024-01-10 08:00:00', '2024-01-22 11:30:00'),

('meta_carol_hw_006', 'cse_kp_003', 'pkm_carol_006', 'hardware',
 'kacls', 'https://kacls.example.com/v1/keys',
 'Nitrokey Pro 2 - Personal research hardware key for sensitive academic communications. Serial: NK-PRO2-987654321. Self-managed with university IT security approval.',
 '2024-01-10 08:00:00', '2024-01-22 11:30:00'),

-- User 2 (bob@company.com) - Legacy key pair metadata (for disabled key pair)
('meta_bob_legacy_007', 'cse_kp_006', 'pkm_bob_007', 'kacls',
 'https://kacls.company.com/api/v1/keys',
 'eyJ1c2VySWQiOiJib2JAY29tcGFueS5jb20iLCJrZXlJZCI6ImtwX2JvYl9sZWdhY3lfODY0MjBfMjAyMyIsImFjY2Vzc1BvbGljaWVzIjpbeyJyb2xlIjoidXNlciIsInBlcm1pc3Npb25zIjpbImRlY3J5cHQiXX1dLCJzdGF0dXMiOiJkaXNhYmxlZCJ9',
 'Nitrokey Pro 2', '2024-01-16 09:15:00', '2024-01-25 14:30:00');


-- CSE Identities (Email API v1 Client-Side Encryption Identity Configurations)
INSERT INTO cse_identities (id, user_id, email_address, primary_key_pair_id, signing_key_pair_id, encryption_key_pair_id, created_at, updated_at) VALUES
-- User 1 (alice@example.com) - Using primary key pair for enterprise email encryption
('cse_id_001', 'user_001', 'alice@example.com', 'kp_alice_abc12345_2024', NULL, NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) - Using business key pair for corporate communications
('cse_id_002', 'user_002', 'bob@company.com', 'kp_bob_def67890_2024', NULL, NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) - Using research key pair for academic communications
('cse_id_003', 'user_003', 'carol@university.edu', 'kp_carol_ghi13579_2024', NULL, NULL, '2024-01-10 08:00:00', '2024-01-22 11:30:00'),

-- User 3 (carol@university.edu) - Secondary identity using secure key pair for confidential research
('cse_id_004', 'user_003', 'c.researcher@university.edu', 'kp_carol_secure_24680_2024', NULL, NULL, '2024-01-11 10:15:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) - Using startup key pair for business communications
('cse_id_005', 'user_004', 'david@startup.io', 'kp_david_jkl97531_2024', NULL, NULL, '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('cse_id_006', 'user_004', 'ceo@startup.io', 'kp_david_jkl97531_2024', NULL, NULL, '2024-01-18 13:20:00', '2024-01-21 09:10:00');

-- Note: User 5 (eve@freelancer.net) has no CSE identity configured (for testing scenarios without CSE)

-- Profiles (User profiles for different contexts)
INSERT INTO profiles (id, user_id, name, active, is_default, created_at, updated_at) VALUES
-- User 1 (alice@example.com) profiles
('profile_001', 'user_001', 'Work Profile', true, true, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('profile_002', 'user_001', 'Personal Profile', true, false, '2024-01-16 11:15:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) profiles
('profile_003', 'user_002', 'Finance Manager', true, true, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('profile_004', 'user_002', 'Team Lead', true, false, '2024-01-17 14:30:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) profiles
('profile_005', 'user_003', 'Professor Profile', true, true, '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('profile_006', 'user_003', 'Research Profile', true, false, '2024-01-12 16:20:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) profiles
('profile_007', 'user_004', 'CEO Profile', true, true, '2024-01-18 13:20:00', '2024-01-21 09:10:00'),

-- User 5 (eve@freelancer.net) profiles
('profile_008', 'user_005', 'Freelancer Profile', true, true, '2024-01-12 11:45:00', '2024-01-23 15:33:00'),
('profile_009', 'user_005', 'Business Profile', true, false, '2024-01-14 13:20:00', '2024-01-23 15:33:00');

-- Email Delegates (Email API v1 Delegation Management)
INSERT INTO delegates (id, user_id, delegate_email, verification_status, created_at, updated_at) VALUES
-- User 1 (alice@example.com) has delegates
('delegate_001', 'user_001', 'assistant@example.com', 'accepted', '2024-01-16 09:00:00', '2024-01-20 14:22:00'),
('delegate_002', 'user_001', 'secretary@example.com', 'accepted', '2024-01-17 14:30:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) has business delegates
('delegate_003', 'user_002', 'admin@company.com', 'accepted', '2024-01-16 11:15:00', '2024-01-19 16:45:00'),
('delegate_004', 'user_002', 'backup.manager@company.com', 'accepted', '2024-01-18 10:45:00', '2024-01-19 16:45:00'),
('delegate_005', 'user_002', 'temp.assistant@company.com', 'pending', '2024-01-19 15:20:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) has academic delegates
('delegate_006', 'user_003', 'dept.secretary@university.edu', 'accepted', '2024-01-12 08:30:00', '2024-01-22 11:30:00'),
('delegate_007', 'user_003', 'research.assistant@university.edu', 'accepted', '2024-01-15 16:00:00', '2024-01-22 11:30:00'),
('delegate_008', 'user_003', 'postdoc.fellow@university.edu', 'rejected', '2024-01-20 12:00:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) has startup delegates
('delegate_009', 'user_004', 'co.founder@startup.io', 'accepted', '2024-01-19 09:20:00', '2024-01-21 09:10:00'),
('delegate_010', 'user_004', 'executive.assistant@startup.io', 'accepted', '2024-01-20 13:45:00', '2024-01-21 09:10:00'),
('delegate_011', 'user_004', 'intern.temp@startup.io', 'expired', '2024-01-18 14:00:00', '2024-01-21 09:10:00');

-- Note: User 5 (eve@freelancer.net) has no delegates configured (for testing scenarios without delegation)

-- Email Filters (Email API v1 compliant filters)
INSERT INTO filters (id, user_id, criteria_json, action_json, created_by, created_at, updated_at) VALUES
-- User 1 (alice@example.com) filters
('filter_001', 'user_001',
'{"from": "manager@company.com", "hasAttachment": true}',
'{"addLabelIds": ["label_007"], "removeLabelIds": ["label_001"]}',
'alice@example.com',
'2024-01-15 11:00:00', '2024-01-20 14:22:00'),

('filter_002', 'user_001',
'{"subject": "meeting", "excludeChats": true}',
'{"addLabelIds": ["label_006"]}',
'alice@example.com',
'2024-01-16 09:30:00', '2024-01-20 14:22:00'),

('filter_003', 'user_001',
'{"query": "from:spam@* OR from:promo@*"}',
'{"addLabelIds": ["label_004"]}',
'alice@example.com',
'2024-01-17 14:15:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) filters
('filter_004', 'user_002',
'{"from": "finance@company.com", "to": "bob@company.com"}',
'{"addLabelIds": ["label_011"], "forward": "bob.backup@company.com"}',
'bob@company.com',
'2024-01-16 10:20:00', '2024-01-19 16:45:00'),

('filter_005', 'user_002',
'{"size": 1048576, "sizeComparison": "larger"}',
'{"addLabelIds": ["label_012"]}',
'bob@company.com',
'2024-01-17 15:45:00', '2024-01-19 16:45:00'),

('filter_006', 'user_002',
'{"negatedQuery": "is:important", "hasAttachment": false}',
'{"removeLabelIds": ["label_009"]}',
'bob@company.com',
'2024-01-18 12:00:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) filters
('filter_007', 'user_003',
'{"from": "conference@academic.org", "subject": "paper"}',
'{"addLabelIds": ["label_015"], "removeLabelIds": ["label_013"]}',
'carol@university.edu',
'2024-01-11 09:30:00', '2024-01-22 11:30:00'),

('filter_008', 'user_003',
'{"to": "research-group@university.edu", "excludeChats": true}',
'{"addLabelIds": ["label_015", "label_016"]}',
'carol@university.edu',
'2024-01-12 11:45:00', '2024-01-22 11:30:00'),

('filter_009', 'user_003',
'{"query": "label:inbox is:unread", "size": 10240, "sizeComparison": "smaller"}',
'{"addLabelIds": ["label_017"]}',
'carol@university.edu',
'2024-01-13 16:20:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) filters
('filter_010', 'user_004',
'{"from": "investor@vc.com", "hasAttachment": true}',
'{"addLabelIds": ["label_019"], "forward": "team@startup.io"}',
'david@startup.io',
'2024-01-19 10:15:00', '2024-01-21 09:10:00'),

('filter_011', 'user_004',
'{"subject": "product", "to": "david@startup.io"}',
'{"addLabelIds": ["label_020"]}',
'david@startup.io',
'2024-01-20 14:30:00', '2024-01-21 09:10:00'),

-- User 5 (eve@freelancer.net) filters
('filter_012', 'user_005',
'{"from": "client@smallbiz.com", "subject": "invoice"}',
'{"addLabelIds": ["label_023"], "forward": "accounting@freelancer.net"}',
'eve@freelancer.net',
'2024-01-13 10:00:00', '2024-01-23 15:33:00'),

('filter_013', 'user_005',
'{"query": "has:attachment filename:pdf", "excludeChats": true}',
'{"addLabelIds": ["label_022"]}',
'eve@freelancer.net',
'2024-01-14 15:20:00', '2024-01-23 15:33:00'),

('filter_014', 'user_005',
'{"negatedQuery": "from:me", "size": 5242880, "sizeComparison": "larger"}',
'{"addLabelIds": ["label_024"], "removeLabelIds": ["label_021"]}',
'eve@freelancer.net',
'2024-01-15 17:00:00', '2024-01-23 15:33:00'),

-- Complex filters for testing edge cases
('filter_015', 'user_001',
'{"from": "team@company.com", "to": "alice@example.com", "subject": "urgent", "hasAttachment": true, "excludeChats": true, "size": 2097152, "sizeComparison": "smaller"}',
'{"addLabelIds": ["label_006", "label_007"], "removeLabelIds": ["label_001"], "forward": "assistant@example.com"}',
'alice@example.com',
'2024-01-18 13:45:00', '2024-01-20 14:22:00'),

('filter_016', 'user_003',
'{"query": "from:colleague@university.edu subject:collaboration has:attachment", "negatedQuery": "label:spam"}',
'{"addLabelIds": ["label_015", "label_016"], "removeLabelIds": ["label_017"]}',
'carol@university.edu',
'2024-01-14 12:30:00', '2024-01-22 11:30:00');

-- Email Forwarding Addresses (Email API v1 compliant forwarding addresses)
INSERT INTO forwarding_addresses (id, user_id, forwarding_email, verification_status, created_at, updated_at) VALUES
-- User 1 (alice@example.com) forwarding addresses
('fwd_001', 'user_001', 'alice.backup@example.com', 'accepted', '2024-01-15 10:45:00', '2024-01-20 14:22:00'),
('fwd_002', 'user_001', 'alice.personal@gmail.com', 'pending', '2024-01-18 14:20:00', '2024-01-20 14:22:00'),
('fwd_003', 'user_001', 'assistant@example.com', 'accepted', '2024-01-16 11:30:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) forwarding addresses
('fwd_004', 'user_002', 'bob.backup@company.com', 'accepted', '2024-01-16 09:45:00', '2024-01-19 16:45:00'),
('fwd_005', 'user_002', 'admin@company.com', 'accepted', '2024-01-17 13:15:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) forwarding addresses
('fwd_006', 'user_003', 'carol.research@university.edu', 'accepted', '2024-01-11 08:30:00', '2024-01-22 11:30:00'),
('fwd_007', 'user_003', 'dept.secretary@university.edu', 'accepted', '2024-01-12 16:45:00', '2024-01-22 11:30:00'),
('fwd_008', 'user_003', 'c.backup@gmail.com', 'verificationStatusUnspecified', '2024-01-20 10:15:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) forwarding addresses
('fwd_009', 'user_004', 'team@startup.io', 'accepted', '2024-01-19 09:30:00', '2024-01-21 09:10:00'),
('fwd_010', 'user_004', 'backup@startup.io', 'pending', '2024-01-20 15:00:00', '2024-01-21 09:10:00'),

-- User 5 (eve@freelancer.net) forwarding addresses
('fwd_011', 'user_005', 'accounting@freelancer.net', 'accepted', '2024-01-13 09:15:00', '2024-01-23 15:33:00'),
('fwd_012', 'user_005', 'eve.personal@outlook.com', 'pending', '2024-01-22 14:30:00', '2024-01-23 15:33:00');

-- Email Send-As Aliases (Gmail API v1 compliant send-as aliases)
INSERT INTO send_as_aliases (id, user_id, send_as_email, display_name, reply_to_address, signature, is_primary, is_default, treat_as_alias, smtp_msa, verification_status, verification_token, verification_token_expires, created_at, updated_at) VALUES
-- User 1 (alice@example.com) send-as aliases
('sendas_001', 'user_001', 'alice@example.com', 'Alice Johnson', NULL, '<p>Best regards,<br>Alice Johnson<br>Software Engineer</p>', true, true, false, NULL, 'accepted', NULL, NULL, '2024-01-15 10:30:00', '2024-01-20 14:22:00'),
('sendas_002', 'user_001', 'alice.work@company.com', 'Alice Johnson - Work', 'alice@example.com', '<p>Alice Johnson<br>Senior Developer<br>Company Corp<br>Phone: (555) 123-4567</p>', false, false, true, '{"host": "smtp.company.com", "port": 587, "username": "alice.work", "securityMode": "starttls"}', 'accepted', NULL, NULL, '2024-01-16 11:15:00', '2024-01-20 14:22:00'),
('sendas_003', 'user_001', 'alice.projects@example.com', 'A. Johnson', 'alice@example.com', '<p>Alice Johnson<br>Project Lead</p>', false, false, true, NULL, 'pending', 'sample_token_alice_projects_123', '2024-01-19 09:45:00', '2024-01-18 09:45:00', '2024-01-20 14:22:00'),

-- User 2 (bob@company.com) send-as aliases
('sendas_004', 'user_002', 'bob@company.com', 'Robert Smith', NULL, '<p>Regards,<br>Bob Smith<br>Finance Manager</p>', true, true, false, NULL, 'accepted', NULL, NULL, '2024-01-16 09:15:00', '2024-01-19 16:45:00'),
('sendas_005', 'user_002', 'bob.personal@gmail.com', 'Bob Smith', 'bob@company.com', '<p>Bob Smith<br>Personal Email</p>', false, false, true, '{"host": "smtp.gmail.com", "port": 587, "username": "bob.personal", "securityMode": "starttls"}', 'accepted', NULL, NULL, '2024-01-17 14:30:00', '2024-01-19 16:45:00'),

-- User 3 (carol@university.edu) send-as aliases
('sendas_006', 'user_003', 'carol@university.edu', 'Dr. Carol Davis', NULL, '<p>Best regards,<br>Dr. Carol Davis<br>Associate Professor<br>Computer Science Department<br>University of Excellence</p>', true, true, false, NULL, 'accepted', NULL, NULL, '2024-01-10 08:00:00', '2024-01-22 11:30:00'),
('sendas_007', 'user_003', 'c.davis@research.edu', 'Carol Davis - Research', 'carol@university.edu', '<p>Dr. Carol Davis<br>Research Associate<br>AI & Machine Learning Lab</p>', false, false, true, '{"host": "mail.research.edu", "port": 465, "username": "c.davis", "securityMode": "ssl"}', 'accepted', NULL, NULL, '2024-01-12 16:20:00', '2024-01-22 11:30:00'),
('sendas_008', 'user_003', 'carol.teaching@university.edu', 'Prof. Davis', 'carol@university.edu', '<p>Professor Carol Davis<br>CS Department<br>Office Hours: Mon/Wed 2-4pm</p>', false, false, true, NULL, 'pending', 'sample_token_carol_teaching_456', '2024-01-16 10:00:00', '2024-01-15 10:00:00', '2024-01-22 11:30:00'),

-- User 4 (david@startup.io) send-as aliases
('sendas_009', 'user_004', 'david@startup.io', 'David Chen', NULL, '<p>David Chen<br>CEO & Founder<br>Innovation Startup<br>Changing the world, one line of code at a time</p>', true, true, false, NULL, 'accepted', NULL, NULL, '2024-01-18 13:20:00', '2024-01-21 09:10:00'),
('sendas_010', 'user_004', 'ceo@startup.io', 'David Chen, CEO', 'david@startup.io', '<p>David Chen<br>Chief Executive Officer<br>Innovation Startup Inc.<br>Phone: (555) 987-6543</p>', false, false, true, NULL, 'accepted', NULL, NULL, '2024-01-19 08:30:00', '2024-01-21 09:10:00'),
('sendas_011', 'user_004', 'david.personal@protonmail.com', 'Dave C.', 'david@startup.io', '<p>David<br>Personal matters only</p>', false, false, true, '{"host": "mail.protonmail.ch", "port": 587, "username": "david.personal", "securityMode": "starttls"}', 'pending', 'sample_token_david_personal_789', '2024-01-21 19:15:00', '2024-01-20 19:15:00', '2024-01-21 09:10:00'),

-- User 5 (eve@freelancer.net) send-as aliases
('sendas_012', 'user_005', 'eve@freelancer.net', 'Eve Williams', NULL, '<p>Eve Williams<br>Freelance Web Developer<br>Available for new projects<br>Contact: eve@freelancer.net</p>', true, true, false, NULL, 'accepted', NULL, NULL, '2024-01-12 11:45:00', '2024-01-23 15:33:00'),
('sendas_013', 'user_005', 'eve.business@freelancer.net', 'Eve Williams - Business', 'eve@freelancer.net', '<p>Eve Williams<br>Professional Web Development Services<br>Specializing in React & Node.js<br>www.eve-webdev.com</p>', false, false, true, NULL, 'accepted', NULL, NULL, '2024-01-14 13:20:00', '2024-01-23 15:33:00'),
('sendas_014', 'user_005', 'eve.contracts@legalmail.com', 'E. Williams', 'eve@freelancer.net', '<p>Eve Williams<br>Contract & Legal Communications</p>', false, false, true, '{"host": "secure.legalmail.com", "port": 465, "username": "eve.contracts", "securityMode": "ssl"}', 'verificationStatusUnspecified', NULL, NULL, '2024-01-22 16:45:00', '2024-01-23 15:33:00');

-- Email S/MIME Information (Gmail API v1 compliant S/MIME configurations)
INSERT INTO smime_info (id, send_as_alias_id, user_id, send_as_email, issuer_cn, is_default, expiration, encrypted_key_password, pem, pkcs12, created_at, updated_at) VALUES
('smime_001','sendas_001','user_001','alice@example.com','Company Corp Internal CA',true,'1735689600000',NULL,'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZSomeId...Alice_Primary_Cert...-----END CERTIFICATE-----',NULL,'2024-01-16 10:30:00','2024-01-20 14:22:00'),
('smime_002','sendas_002','user_001','alice.work@company.com','Company Corp Secure CA',true,'1740873600000','encrypted_password_123','-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZWork...Alice_Work_Cert...-----END CERTIFICATE-----',NULL,'2024-01-17 09:15:00','2024-01-20 14:22:00'),
('smime_003','sendas_004','user_002','bob@company.com','Company Corp Finance CA',true,'1743552000000',NULL,'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZBob...Bob_Finance_Cert...-----END CERTIFICATE-----',NULL,'2024-01-17 11:00:00','2024-01-19 16:45:00'),
('smime_004','sendas_005','user_002','bob.personal@gmail.com','Google Trust Services',false,'1738281600000',NULL,'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZBob...Bob_Personal_Cert...-----END CERTIFICATE-----',NULL,'2024-01-18 14:20:00','2024-01-19 16:45:00'),
('smime_005','sendas_006','user_003','carol@university.edu','University of Excellence CA',true,'1746230400000','university_secure_key','-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZCarol...Carol_University_Cert...-----END CERTIFICATE-----',NULL,'2024-01-13 08:45:00','2024-01-22 11:30:00'),
('smime_006','sendas_007','user_003','c.davis@research.edu','Research Institute Advanced CA',true,'1748908800000','research_secure_2024','-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZCarol...Carol_Research_Cert...-----END CERTIFICATE-----',NULL,'2024-01-14 16:30:00','2024-01-22 11:30:00'),
('smime_007','sendas_009','user_004','david@startup.io','Let''s Encrypt Authority X3',true,'1735689600000',NULL,'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZDavid...David_Startup_Cert...-----END CERTIFICATE-----',NULL,'2024-01-19 10:00:00','2024-01-21 09:10:00'),
('smime_008','sendas_010','user_004','ceo@startup.io','DigiCert Business CA',false,'1751587200000','ceo_secure_key_2024','-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZDavid...David_CEO_Cert...-----END CERTIFICATE-----',NULL,'2024-01-20 11:15:00','2024-01-21 09:10:00'),
('smime_009','sendas_012','user_005','eve@freelancer.net','Freelancer Professional CA',true,'1740873600000',NULL,'-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZEve...Eve_Freelancer_Cert...-----END CERTIFICATE-----',NULL,'2024-01-15 12:30:00','2024-01-23 15:33:00'),
('smime_010','sendas_014','user_005','eve.contracts@legalmail.com','Legal Mail Secure CA',true,'1756771200000','legal_secure_2024','-----BEGIN CERTIFICATE-----MIIDXTCCAkWgAwIBAgIJAKZEve...Eve_Legal_Cert...-----END CERTIFICATE-----',NULL,'2024-01-23 09:00:00','2024-01-23 15:33:00');

INSERT INTO users (id, token, primary_email, messages_total, threads_total, history_id_current, created_at, updated_at) VALUES ('EM_DIEGO', 'tok_diego_offboard', 'diego.ramos@techcorp.com', '150', '45', '12345678901', '2024-01-15 10:30:00', '2024-01-20 14:22:00');
