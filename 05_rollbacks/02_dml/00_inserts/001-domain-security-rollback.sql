-- =====================================================
-- ROLLBACK
-- =====================================================
DELETE FROM module_view;
DELETE FROM role_permission;
DELETE FROM user_role;
DELETE FROM app_user;
DELETE FROM app_view;
DELETE FROM module;
DELETE FROM permission;
DELETE FROM app_role;
DELETE FROM person;