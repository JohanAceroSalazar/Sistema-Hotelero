-- =====================================================
-- BRANCH
-- Depends on COMPANY
-- =====================================================

INSERT INTO branch (
    company_id,
    name,
    address,
    city,
    phone,
    email
)
SELECT
    c.id,
    x.name,
    x.address,
    x.city,
    x.phone,
    x.email
FROM (
    VALUES
    ('901456789-1', 'Aurora Bogota Centro', 'Carrera 15 #93-21', 'Bogota', '6014567890', 'bogota@hotelaurora.com'),
    ('900874563-2', 'Andino Medellin', 'Calle 10 #43A-30', 'Medellin', '6048745632', 'medellin@turismoandino.com'),
    ('901998741-5', 'Caribe Cartagena', 'Avenida San Martin #8-20', 'Cartagena', '6059987412', 'cartagena@cariberesort.com')
) AS x (
    tax_id,
    name,
    address,
    city,
    phone,
    email
)
JOIN company c
    ON c.tax_id = x.tax_id
ON CONFLICT (company_id, name) DO UPDATE
SET
    address = EXCLUDED.address,
    city = EXCLUDED.city,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email;

-- =====================================================
-- ROOM TYPE
-- =====================================================

INSERT INTO room_type (
    name,
    description,
    base_capacity,
    max_capacity
)
VALUES
('STANDARD', 'Standard room with queen bed', 1, 2),
('DOUBLE', 'Double room for families or groups', 2, 4),
('SUITE', 'Suite with premium amenities', 2, 5)
ON CONFLICT (name) DO UPDATE
SET
    description = EXCLUDED.description,
    base_capacity = EXCLUDED.base_capacity,
    max_capacity = EXCLUDED.max_capacity;

-- =====================================================
-- ROOM STATUS
-- =====================================================

INSERT INTO room_status (
    name,
    description,
    allows_reservation,
    allows_check_in
)
VALUES
('AVAILABLE', 'Room available for reservation and check-in', TRUE, TRUE),
('OCCUPIED', 'Room currently occupied', FALSE, FALSE),
('MAINTENANCE', 'Room unavailable due to maintenance', FALSE, FALSE)
ON CONFLICT (name) DO UPDATE
SET
    description = EXCLUDED.description,
    allows_reservation = EXCLUDED.allows_reservation,
    allows_check_in = EXCLUDED.allows_check_in;

-- =====================================================
-- ROOM
-- Depends on BRANCH, ROOM TYPE and ROOM STATUS
-- =====================================================

INSERT INTO room (
    branch_id,
    room_type_id,
    room_status_id,
    room_number,
    floor_number,
    capacity,
    description
)
SELECT
    b.id,
    rt.id,
    rs.id,
    x.room_number,
    x.floor_number,
    x.capacity,
    x.description
FROM (
    VALUES
    ('Aurora Bogota Centro', 'STANDARD', 'AVAILABLE', '101', 1, 2, 'Standard room near the lobby'),
    ('Aurora Bogota Centro', 'DOUBLE', 'AVAILABLE', '202', 2, 4, 'Double room with city view'),
    ('Andino Medellin', 'SUITE', 'AVAILABLE', '501', 5, 5, 'Suite with balcony')
) AS x (
    branch_name,
    room_type_name,
    room_status_name,
    room_number,
    floor_number,
    capacity,
    description
)
JOIN branch b
    ON b.name = x.branch_name
JOIN room_type rt
    ON rt.name = x.room_type_name
JOIN room_status rs
    ON rs.name = x.room_status_name
ON CONFLICT (branch_id, room_number) DO UPDATE
SET
    room_type_id = EXCLUDED.room_type_id,
    room_status_id = EXCLUDED.room_status_id,
    floor_number = EXCLUDED.floor_number,
    capacity = EXCLUDED.capacity,
    description = EXCLUDED.description;

-- =====================================================
-- RATE
-- Depends on ROOM TYPE and DAY TYPE
-- =====================================================

INSERT INTO rate (
    room_type_id,
    day_type_id,
    amount,
    start_date,
    end_date,
    condition_note
)
SELECT
    rt.id,
    dt.id,
    x.amount,
    x.start_date,
    x.end_date,
    x.condition_note
FROM (
    VALUES
    ('STANDARD', 'HIGH_SEASON', NUMERIC '220000.00', DATE '2026-01-01', DATE '2026-01-31', 'High season standard rate'),
    ('DOUBLE', 'HOLIDAY', NUMERIC '320000.00', DATE '2026-07-18', DATE '2026-07-21', 'Holiday double room rate'),
    ('SUITE', 'SPECIAL_EVENT', NUMERIC '580000.00', DATE '2026-09-10', DATE '2026-09-14', 'Special event suite rate')
) AS x (
    room_type_name,
    day_type_name,
    amount,
    start_date,
    end_date,
    condition_note
)
JOIN room_type rt
    ON rt.name = x.room_type_name
JOIN day_type dt
    ON dt.name = x.day_type_name
ON CONFLICT (room_type_id, day_type_id, start_date) DO UPDATE
SET
    amount = EXCLUDED.amount,
    end_date = EXCLUDED.end_date,
    condition_note = EXCLUDED.condition_note;
