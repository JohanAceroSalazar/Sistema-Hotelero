-- ============================================
-- CONEXIÓN
-- ============================================

GRANT CONNECT ON DATABASE sistema_hotelero TO instructor_role;

GRANT USAGE ON SCHEMA public TO instructor_role;


-- ============================================
-- DML
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO instructor_role;


-- ============================================
-- SECUENCIAS
-- ============================================

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA public
TO instructor_role;


-- ============================================
-- DDL CONTROLADO
-- ============================================

GRANT CREATE
ON SCHEMA public
TO instructor_role;


-- ============================================
-- FUTUROS OBJETOS
-- ============================================

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO instructor_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT
ON SEQUENCES TO instructor_role;