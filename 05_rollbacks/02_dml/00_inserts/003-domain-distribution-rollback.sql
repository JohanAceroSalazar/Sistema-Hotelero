-- =====================================================
-- DELETE DISTRIBUTION DOMAIN DATA
-- =====================================================

-- TABLES WITH FK DEPENDENCIES FIRST
DELETE FROM rate;
DELETE FROM room;

-- MAIN TABLES
DELETE FROM room_status;
DELETE FROM room_type;
DELETE FROM branch;