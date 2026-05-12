-- =====================================================
-- ROOM RESERVATION
-- Depends on CUSTOMER and ROOM
-- =====================================================

INSERT INTO room_reservation (
    customer_id,
    room_id,
    start_at,
    end_at,
    guest_count,
    reservation_status,
    estimated_amount
)
SELECT
    c.id,
    r.id,
    x.start_at,
    x.end_at,
    x.guest_count,
    x.reservation_status,
    x.estimated_amount
FROM (
    VALUES
    ('52530001', 'Aurora Bogota Centro', '101', TIMESTAMP '2026-02-10 15:00:00', TIMESTAMP '2026-02-12 12:00:00', 2, 'CONFIRMED', NUMERIC '440000.00'),
    ('1025478963', 'Aurora Bogota Centro', '202', TIMESTAMP '2026-07-18 15:00:00', TIMESTAMP '2026-07-21 12:00:00', 3, 'CONFIRMED', NUMERIC '960000.00'),
    ('1036987452', 'Andino Medellin', '501', TIMESTAMP '2026-09-10 15:00:00', TIMESTAMP '2026-09-13 12:00:00', 2, 'PENDING', NUMERIC '1740000.00')
) AS x (
    customer_document_number,
    branch_name,
    room_number,
    start_at,
    end_at,
    guest_count,
    reservation_status,
    estimated_amount
)
JOIN customer c
    ON c.document_number = x.customer_document_number
JOIN branch b
    ON b.name = x.branch_name
JOIN room r
    ON r.branch_id = b.id
   AND r.room_number = x.room_number
WHERE NOT EXISTS (
    SELECT 1
    FROM room_reservation rr
    WHERE rr.customer_id = c.id
      AND rr.room_id = r.id
      AND rr.start_at = x.start_at
      AND rr.end_at = x.end_at
);

-- =====================================================
-- ROOM CANCELLATION
-- Depends on ROOM RESERVATION
-- =====================================================

INSERT INTO room_cancellation (
    room_reservation_id,
    reason,
    cancelled_at,
    applies_penalty,
    penalty_amount
)
SELECT
    rr.id,
    'Guest requested date change',
    TIMESTAMP '2026-09-05 10:00:00',
    TRUE,
    NUMERIC '150000.00'
FROM room_reservation rr
JOIN customer c
    ON c.id = rr.customer_id
WHERE c.document_number = '1036987452'
  AND rr.start_at = TIMESTAMP '2026-09-10 15:00:00'
ON CONFLICT (room_reservation_id) DO UPDATE
SET
    reason = EXCLUDED.reason,
    cancelled_at = EXCLUDED.cancelled_at,
    applies_penalty = EXCLUDED.applies_penalty,
    penalty_amount = EXCLUDED.penalty_amount;

-- =====================================================
-- ROOM AVAILABILITY
-- Depends on ROOM
-- =====================================================

INSERT INTO room_availability (
    room_id,
    start_at,
    end_at,
    is_available,
    unavailable_reason
)
SELECT
    r.id,
    x.start_at,
    x.end_at,
    x.is_available,
    x.unavailable_reason
FROM (
    VALUES
    ('Aurora Bogota Centro', '101', TIMESTAMP '2026-02-10 15:00:00', TIMESTAMP '2026-02-12 12:00:00', FALSE, 'Reserved'),
    ('Aurora Bogota Centro', '202', TIMESTAMP '2026-07-18 15:00:00', TIMESTAMP '2026-07-21 12:00:00', FALSE, 'Reserved'),
    ('Andino Medellin', '501', TIMESTAMP '2026-09-10 15:00:00', TIMESTAMP '2026-09-13 12:00:00', TRUE, NULL)
) AS x (
    branch_name,
    room_number,
    start_at,
    end_at,
    is_available,
    unavailable_reason
)
JOIN branch b
    ON b.name = x.branch_name
JOIN room r
    ON r.branch_id = b.id
   AND r.room_number = x.room_number
WHERE NOT EXISTS (
    SELECT 1
    FROM room_availability ra
    WHERE ra.room_id = r.id
      AND ra.start_at = x.start_at
      AND ra.end_at = x.end_at
);

-- =====================================================
-- ROOM CATALOG
-- Depends on ROOM
-- =====================================================

INSERT INTO room_catalog (
    room_id,
    title,
    description,
    base_price,
    is_visible
)
SELECT
    r.id,
    x.title,
    x.description,
    x.base_price,
    x.is_visible
FROM (
    VALUES
    ('Aurora Bogota Centro', '101', 'Standard Room 101', 'Comfortable standard room for short stays', NUMERIC '220000.00', TRUE),
    ('Aurora Bogota Centro', '202', 'Double Room 202', 'Spacious double room with city view', NUMERIC '320000.00', TRUE),
    ('Andino Medellin', '501', 'Suite 501', 'Premium suite with balcony', NUMERIC '580000.00', TRUE)
) AS x (
    branch_name,
    room_number,
    title,
    description,
    base_price,
    is_visible
)
JOIN branch b
    ON b.name = x.branch_name
JOIN room r
    ON r.branch_id = b.id
   AND r.room_number = x.room_number
ON CONFLICT (room_id) DO UPDATE
SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    base_price = EXCLUDED.base_price,
    is_visible = EXCLUDED.is_visible;

-- =====================================================
-- STAY
-- Depends on ROOM RESERVATION, CUSTOMER and ROOM
-- =====================================================

INSERT INTO stay (
    room_reservation_id,
    customer_id,
    room_id,
    start_at,
    end_at,
    stay_status
)
SELECT
    rr.id,
    rr.customer_id,
    rr.room_id,
    TIMESTAMP '2026-02-10 15:30:00',
    TIMESTAMP '2026-02-12 11:20:00',
    'COMPLETED'
FROM room_reservation rr
JOIN customer c
    ON c.id = rr.customer_id
WHERE c.document_number = '52530001'
  AND rr.start_at = TIMESTAMP '2026-02-10 15:00:00'
ON CONFLICT (room_reservation_id) DO UPDATE
SET
    customer_id = EXCLUDED.customer_id,
    room_id = EXCLUDED.room_id,
    start_at = EXCLUDED.start_at,
    end_at = EXCLUDED.end_at,
    stay_status = EXCLUDED.stay_status;

INSERT INTO stay (
    room_reservation_id,
    customer_id,
    room_id,
    start_at,
    end_at,
    stay_status
)
SELECT
    rr.id,
    rr.customer_id,
    rr.room_id,
    TIMESTAMP '2026-07-18 15:20:00',
    NULL,
    'ACTIVE'
FROM room_reservation rr
JOIN customer c
    ON c.id = rr.customer_id
WHERE c.document_number = '1025478963'
  AND rr.start_at = TIMESTAMP '2026-07-18 15:00:00'
ON CONFLICT (room_reservation_id) DO UPDATE
SET
    customer_id = EXCLUDED.customer_id,
    room_id = EXCLUDED.room_id,
    start_at = EXCLUDED.start_at,
    end_at = EXCLUDED.end_at,
    stay_status = EXCLUDED.stay_status;

-- =====================================================
-- CHECK IN
-- Depends on ROOM RESERVATION and EMPLOYEE
-- =====================================================

INSERT INTO check_in (
    room_reservation_id,
    employee_id,
    checked_in_at,
    note
)
SELECT
    rr.id,
    e.id,
    x.checked_in_at,
    x.note
FROM (
    VALUES
    ('52530001', '1025478963', TIMESTAMP '2026-02-10 15:30:00', 'Check-in completed at front desk'),
    ('1025478963', '1025478963', TIMESTAMP '2026-07-18 15:20:00', 'Check-in completed with welcome package')
) AS x (
    customer_document_number,
    employee_document_number,
    checked_in_at,
    note
)
JOIN room_reservation rr
    ON rr.start_at IN (TIMESTAMP '2026-02-10 15:00:00', TIMESTAMP '2026-07-18 15:00:00')
JOIN customer c
    ON c.id = rr.customer_id
   AND c.document_number = x.customer_document_number
JOIN person p
    ON p.document_number = x.employee_document_number
JOIN employee e
    ON e.person_id = p.id
ON CONFLICT (room_reservation_id) DO UPDATE
SET
    employee_id = EXCLUDED.employee_id,
    checked_in_at = EXCLUDED.checked_in_at,
    note = EXCLUDED.note;

-- =====================================================
-- CHECK OUT
-- Depends on STAY and EMPLOYEE
-- =====================================================

INSERT INTO check_out (
    stay_id,
    employee_id,
    checked_out_at,
    note,
    total_amount
)
SELECT
    s.id,
    e.id,
    TIMESTAMP '2026-02-12 11:20:00',
    'Check-out completed without pending charges',
    NUMERIC '489500.00'
FROM stay s
JOIN customer c
    ON c.id = s.customer_id
JOIN person p
    ON p.document_number = '1025478963'
JOIN employee e
    ON e.person_id = p.id
WHERE c.document_number = '52530001'
  AND s.start_at = TIMESTAMP '2026-02-10 15:30:00'
ON CONFLICT (stay_id) DO UPDATE
SET
    employee_id = EXCLUDED.employee_id,
    checked_out_at = EXCLUDED.checked_out_at,
    note = EXCLUDED.note,
    total_amount = EXCLUDED.total_amount;

-- =====================================================
-- PRODUCT SALE
-- Depends on STAY and PRODUCT
-- =====================================================

INSERT INTO product_sale (
    stay_id,
    product_id,
    quantity,
    unit_price,
    total_amount
)
SELECT
    s.id,
    p.id,
    x.quantity,
    x.unit_price,
    x.total_amount
FROM (
    VALUES
    ('52530001', 'BOTTLED_WATER', 3, NUMERIC '4500.00', NUMERIC '13500.00'),
    ('1025478963', 'MINIBAR_SNACK_PACK', 2, NUMERIC '15000.00', NUMERIC '30000.00')
) AS x (
    customer_document_number,
    product_name,
    quantity,
    unit_price,
    total_amount
)
JOIN stay s
    ON s.start_at IN (TIMESTAMP '2026-02-10 15:30:00', TIMESTAMP '2026-07-18 15:20:00')
JOIN customer c
    ON c.id = s.customer_id
   AND c.document_number = x.customer_document_number
JOIN product p
    ON p.name = x.product_name
WHERE NOT EXISTS (
    SELECT 1
    FROM product_sale ps
    WHERE ps.stay_id = s.id
      AND ps.product_id = p.id
);

-- =====================================================
-- SERVICE SALE
-- Depends on STAY and SERVICE
-- =====================================================

INSERT INTO service_sale (
    stay_id,
    service_id,
    quantity,
    unit_price,
    total_amount
)
SELECT
    s.id,
    sv.id,
    x.quantity,
    x.unit_price,
    x.total_amount
FROM (
    VALUES
    ('52530001', 'LAUNDRY', 1, NUMERIC '25000.00', NUMERIC '25000.00'),
    ('1025478963', 'AIRPORT_TRANSFER', 1, NUMERIC '90000.00', NUMERIC '90000.00')
) AS x (
    customer_document_number,
    service_name,
    quantity,
    unit_price,
    total_amount
)
JOIN stay s
    ON s.start_at IN (TIMESTAMP '2026-02-10 15:30:00', TIMESTAMP '2026-07-18 15:20:00')
JOIN customer c
    ON c.id = s.customer_id
   AND c.document_number = x.customer_document_number
JOIN service sv
    ON sv.name = x.service_name
WHERE NOT EXISTS (
    SELECT 1
    FROM service_sale ss
    WHERE ss.stay_id = s.id
      AND ss.service_id = sv.id
);
