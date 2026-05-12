-- =====================================================
-- DELETE INVENTORY DOMAIN DATA
-- =====================================================

-- TABLES WITH FK DEPENDENCIES FIRST
DELETE FROM inventory_availability;
DELETE FROM product_movement;
DELETE FROM product;
DELETE FROM service;

-- MAIN TABLES
DELETE FROM supplier;