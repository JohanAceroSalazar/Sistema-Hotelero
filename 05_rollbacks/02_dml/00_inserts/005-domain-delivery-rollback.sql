-- =====================================================
-- DELETE SERVICE DELIVERY DOMAIN DATA
-- =====================================================

-- TABLES WITH FK DEPENDENCIES FIRST
DELETE FROM service_sale;
DELETE FROM product_sale;
DELETE FROM check_out;
DELETE FROM check_in;
DELETE FROM stay;
DELETE FROM room_catalog;
DELETE FROM room_availability;
DELETE FROM room_cancellation;

-- MAIN TABLES
DELETE FROM room_reservation;