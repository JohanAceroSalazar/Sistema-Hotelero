-- =====================================================
-- PERSON
-- =====================================================

INSERT INTO person (
    document_type,
    document_number,
    first_name,
    last_name,
    phone,
    email
)
VALUES
(
    'CC',
    '52530001',
    'Ariel',
    'Ramirez',
    '3004567890',
    'ariel@mail.com'
),
(
    'CC',
    '1025478963',
    'Maria',
    'Gonzalez',
    '3116547890',
    'maria@mail.com'
),
(
    'CC',
    '1036987452',
    'Carlos',
    'Lopez',
    '3207894561',
    'carlos@mail.com'
)
ON CONFLICT (document_type, document_number) DO UPDATE
SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email;

-- =====================================================
-- APP ROLE
-- =====================================================

INSERT INTO app_role (
    name,
    description
)
VALUES
(
    'ADMINISTRATOR',
    'General administrative access'
),
(
    'FRONT_DESK',
    'Reservation, check-in and check-out management'
),
(
    'MAINTENANCE',
    'Operational maintenance management'
)
ON CONFLICT (name) DO UPDATE
SET
    description = EXCLUDED.description;

-- =====================================================
-- PERMISSION
-- =====================================================

INSERT INTO permission (
    name,
    description,
    action
)
VALUES
(
    'MANAGE_RESERVATION',
    'Create, update and view reservations',
    'WRITE'
),
(
    'MANAGE_INVOICE',
    'Issue and view invoices',
    'WRITE'
),
(
    'VIEW_DASHBOARD',
    'View operational dashboard',
    'READ'
)
ON CONFLICT (name, action) DO UPDATE
SET
    description = EXCLUDED.description;

-- =====================================================
-- MODULE
-- =====================================================

INSERT INTO module (
    name,
    description,
    base_path
)
VALUES
(
    'CONFIGURATION',
    'Hotel configuration module',
    '/configuration'
),
(
    'BILLING',
    'Billing and payments module',
    '/billing'
),
(
    'INVENTORY',
    'Inventory module',
    '/inventory'
)
ON CONFLICT (name) DO UPDATE
SET
    description = EXCLUDED.description,
    base_path = EXCLUDED.base_path;

-- =====================================================
-- APP VIEW
-- =====================================================

INSERT INTO app_view (
    module_id,
    name,
    description,
    path
)
VALUES
(
    (SELECT id FROM module WHERE name = 'CONFIGURATION'),
    'Configuration',
    'Hotel configuration view',
    '/configuration/general'
),
(
    (SELECT id FROM module WHERE name = 'BILLING'),
    'Invoices',
    'Invoice administration view',
    '/billing/invoices'
),
(
    (SELECT id FROM module WHERE name = 'INVENTORY'),
    'Products',
    'Inventory product view',
    '/inventory/products'
)
ON CONFLICT (module_id, path) DO UPDATE
SET
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- =====================================================
-- APP USER
-- =====================================================

INSERT INTO app_user (
    person_id,
    username,
    password_hash
)
SELECT
    p.id,
    'ariel5253',
    crypt('ariel5253', gen_salt('bf'))
FROM person p
WHERE p.document_number = '52530001'
ON CONFLICT (username) DO UPDATE
SET
    password_hash = EXCLUDED.password_hash,
    is_blocked = false,
    status = 'ACTIVE';

INSERT INTO app_user (
    person_id,
    username,
    password_hash
)
SELECT
    p.id,
    'mariag',
    crypt('mariag123', gen_salt('bf'))
FROM person p
WHERE p.document_number = '1025478963'
ON CONFLICT (username) DO UPDATE
SET
    password_hash = EXCLUDED.password_hash,
    is_blocked = false,
    status = 'ACTIVE';

INSERT INTO app_user (
    person_id,
    username,
    password_hash
)
SELECT
    p.id,
    'carlosl',
    crypt('carlos123', gen_salt('bf'))
FROM person p
WHERE p.document_number = '1036987452'
ON CONFLICT (username) DO UPDATE
SET
    password_hash = EXCLUDED.password_hash,
    is_blocked = false,
    status = 'ACTIVE';

-- =====================================================
-- USER ROLE
-- =====================================================

INSERT INTO user_role (
    user_id,
    role_id
)
SELECT
    u.id,
    r.id
FROM app_user u
JOIN app_role r
    ON r.name = 'ADMINISTRATOR'
WHERE u.username = 'ariel5253'
ON CONFLICT (user_id, role_id) DO NOTHING;

INSERT INTO user_role (
    user_id,
    role_id
)
SELECT
    u.id,
    r.id
FROM app_user u
JOIN app_role r
    ON r.name = 'FRONT_DESK'
WHERE u.username = 'mariag'
ON CONFLICT (user_id, role_id) DO NOTHING;

INSERT INTO user_role (
    user_id,
    role_id
)
SELECT
    u.id,
    r.id
FROM app_user u
JOIN app_role r
    ON r.name = 'MAINTENANCE'
WHERE u.username = 'carlosl'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- =====================================================
-- ROLE PERMISSION
-- =====================================================

INSERT INTO role_permission (
    role_id,
    permission_id
)
SELECT
    r.id,
    p.id
FROM app_role r
JOIN permission p
    ON p.name = 'MANAGE_RESERVATION'
WHERE r.name = 'ADMINISTRATOR'
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permission (
    role_id,
    permission_id
)
SELECT
    r.id,
    p.id
FROM app_role r
JOIN permission p
    ON p.name = 'MANAGE_INVOICE'
WHERE r.name = 'FRONT_DESK'
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permission (
    role_id,
    permission_id
)
SELECT
    r.id,
    p.id
FROM app_role r
JOIN permission p
    ON p.name = 'VIEW_DASHBOARD'
WHERE r.name = 'MAINTENANCE'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- =====================================================
-- MODULE VIEW
-- =====================================================

INSERT INTO module_view (
    module_id,
    view_id
)
SELECT
    m.id,
    v.id
FROM module m
JOIN app_view v
    ON v.module_id = m.id
WHERE m.name = 'CONFIGURATION'
ON CONFLICT (module_id, view_id) DO NOTHING;

INSERT INTO module_view (
    module_id,
    view_id
)
SELECT
    m.id,
    v.id
FROM module m
JOIN app_view v
    ON v.module_id = m.id
WHERE m.name = 'BILLING'
ON CONFLICT (module_id, view_id) DO NOTHING;

INSERT INTO module_view (
    module_id,
    view_id
)
SELECT
    m.id,
    v.id
FROM module m
JOIN app_view v
    ON v.module_id = m.id
WHERE m.name = 'INVENTORY'
ON CONFLICT (module_id, view_id) DO NOTHING;