-- =====================================================
-- DELETE BILLING DOMAIN DATA
-- =====================================================

-- TABLES WITH FK DEPENDENCIES FIRST
DELETE FROM invoice_detail;
DELETE FROM partial_payment;
DELETE FROM invoice;

-- MAIN TABLES
DELETE FROM proforma_invoice;