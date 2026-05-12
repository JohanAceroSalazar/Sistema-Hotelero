-- =====================================================
-- SUPPLIER
-- =====================================================

INSERT INTO supplier (
    name,
    tax_id,
    phone,
    email,
    address
)
VALUES
('Distribuidora Hotelera SAS', '900111222-3', '6012223344', 'ventas@disthotelera.com', 'Zona Industrial Bogota'),
('Aseo Total LTDA', '901222333-4', '6043334455', 'contacto@aseototal.com', 'Centro Medellin'),
('Bebidas Caribe SAS', '902333444-5', '6054445566', 'pedidos@bebidascaribe.com', 'Mamonal Cartagena')
ON CONFLICT (tax_id) DO UPDATE
SET
    name = EXCLUDED.name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    address = EXCLUDED.address;

-- =====================================================
-- PRODUCT
-- Depends on SUPPLIER
-- =====================================================

INSERT INTO product (
    supplier_id,
    name,
    description,
    sale_price,
    current_stock,
    minimum_stock
)
SELECT
    s.id,
    x.name,
    x.description,
    x.sale_price,
    x.current_stock,
    x.minimum_stock
FROM (
    VALUES
    ('900111222-3', 'BOTTLED_WATER', 'Bottled water 600 ml', NUMERIC '4500.00', 120, 30),
    ('901222333-4', 'ROOM_CLEANING_KIT', 'Cleaning kit for housekeeping', NUMERIC '18000.00', 45, 10),
    ('902333444-5', 'MINIBAR_SNACK_PACK', 'Snack pack for minibar', NUMERIC '15000.00', 80, 20)
) AS x (
    supplier_tax_id,
    name,
    description,
    sale_price,
    current_stock,
    minimum_stock
)
JOIN supplier s
    ON s.tax_id = x.supplier_tax_id
ON CONFLICT (name) DO UPDATE
SET
    supplier_id = EXCLUDED.supplier_id,
    description = EXCLUDED.description,
    sale_price = EXCLUDED.sale_price,
    current_stock = EXCLUDED.current_stock,
    minimum_stock = EXCLUDED.minimum_stock;

-- =====================================================
-- SERVICE
-- =====================================================

INSERT INTO service (
    name,
    description,
    sale_price,
    is_available
)
VALUES
('LAUNDRY', 'Laundry service per guest', NUMERIC '25000.00', TRUE),
('AIRPORT_TRANSFER', 'Airport transfer service', NUMERIC '90000.00', TRUE),
('SPA_ACCESS', 'One-day spa access', NUMERIC '70000.00', TRUE)
ON CONFLICT (name) DO UPDATE
SET
    description = EXCLUDED.description,
    sale_price = EXCLUDED.sale_price,
    is_available = EXCLUDED.is_available;

-- =====================================================
-- PRODUCT MOVEMENT
-- Depends on PRODUCT
-- =====================================================

INSERT INTO product_movement (
    product_id,
    movement_type,
    quantity,
    moved_at,
    note
)
SELECT
    p.id,
    x.movement_type,
    x.quantity,
    x.moved_at,
    x.note
FROM (
    VALUES
    ('BOTTLED_WATER', 'IN', 120, TIMESTAMP '2026-01-05 08:00:00', 'Initial bottled water stock'),
    ('ROOM_CLEANING_KIT', 'IN', 45, TIMESTAMP '2026-01-05 08:15:00', 'Initial cleaning kit stock'),
    ('MINIBAR_SNACK_PACK', 'IN', 80, TIMESTAMP '2026-01-05 08:30:00', 'Initial minibar stock')
) AS x (
    product_name,
    movement_type,
    quantity,
    moved_at,
    note
)
JOIN product p
    ON p.name = x.product_name
WHERE NOT EXISTS (
    SELECT 1
    FROM product_movement pm
    WHERE pm.product_id = p.id
      AND pm.movement_type = x.movement_type
      AND pm.moved_at = x.moved_at
);

-- =====================================================
-- INVENTORY AVAILABILITY
-- Depends on PRODUCT and SERVICE
-- =====================================================

INSERT INTO inventory_availability (
    product_id,
    available_quantity,
    is_available,
    note
)
SELECT
    p.id,
    x.available_quantity,
    x.is_available,
    x.note
FROM (
    VALUES
    ('BOTTLED_WATER', 120, TRUE, 'Available for room sales'),
    ('ROOM_CLEANING_KIT', 45, TRUE, 'Available for operations'),
    ('MINIBAR_SNACK_PACK', 80, TRUE, 'Available for minibar sales')
) AS x (
    product_name,
    available_quantity,
    is_available,
    note
)
JOIN product p
    ON p.name = x.product_name
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory_availability ia
    WHERE ia.product_id = p.id
      AND ia.service_id IS NULL
);

INSERT INTO inventory_availability (
    service_id,
    available_quantity,
    is_available,
    note
)
SELECT
    s.id,
    x.available_quantity,
    x.is_available,
    x.note
FROM (
    VALUES
    ('LAUNDRY', 999, TRUE, 'Service available on demand'),
    ('AIRPORT_TRANSFER', 12, TRUE, 'Daily transfer capacity'),
    ('SPA_ACCESS', 25, TRUE, 'Daily spa capacity')
) AS x (
    service_name,
    available_quantity,
    is_available,
    note
)
JOIN service s
    ON s.name = x.service_name
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory_availability ia
    WHERE ia.service_id = s.id
      AND ia.product_id IS NULL
);
