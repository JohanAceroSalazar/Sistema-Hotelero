-- =====================================================
-- DELETE PARAMETERIZATION DOMAIN DATA
-- =====================================================

-- TABLES WITH FK DEPENDENCIES FIRST
DELETE FROM employee;
DELETE FROM legal_information;
-- MAIN TABLES
DELETE FROM customer;
DELETE FROM day_type;
DELETE FROM payment_method;
DELETE FROM company;