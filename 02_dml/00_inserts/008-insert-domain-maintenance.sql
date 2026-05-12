-- =====================================================
-- ROOM MAINTENANCE
-- Depends on ROOM and EMPLOYEE
-- =====================================================

INSERT INTO room_maintenance (
    room_id,
    employee_id,
    maintenance_type,
    start_at,
    end_at,
    maintenance_status,
    note
)
SELECT
    r.id,
    e.id,
    x.maintenance_type,
    x.start_at,
    x.end_at,
    x.maintenance_status,
    x.note
FROM (
    VALUES
    ('Aurora Bogota Centro', '101', '1036987452', 'USAGE', TIMESTAMP '2026-02-13 08:00:00', TIMESTAMP '2026-02-13 12:00:00', 'COMPLETED', 'Post stay room inspection'),
    ('Aurora Bogota Centro', '202', '1036987452', 'REMODELING', TIMESTAMP '2026-08-01 08:00:00', NULL, 'PENDING', 'Bathroom remodeling scheduled'),
    ('Andino Medellin', '501', '1036987452', 'USAGE', TIMESTAMP '2026-09-14 09:00:00', TIMESTAMP '2026-09-14 11:00:00', 'COMPLETED', 'Suite preventive maintenance')
) AS x (
    branch_name,
    room_number,
    employee_document_number,
    maintenance_type,
    start_at,
    end_at,
    maintenance_status,
    note
)
JOIN branch b
    ON b.name = x.branch_name
JOIN room r
    ON r.branch_id = b.id
   AND r.room_number = x.room_number
JOIN person p
    ON p.document_number = x.employee_document_number
JOIN employee e
    ON e.person_id = p.id
WHERE NOT EXISTS (
    SELECT 1
    FROM room_maintenance rm
    WHERE rm.room_id = r.id
      AND rm.maintenance_type = x.maintenance_type
      AND rm.start_at = x.start_at
);

-- =====================================================
-- USAGE MAINTENANCE
-- Depends on ROOM MAINTENANCE
-- =====================================================

INSERT INTO usage_maintenance (
    room_maintenance_id,
    usage_reason,
    activity_detail
)
SELECT
    rm.id,
    x.usage_reason,
    x.activity_detail
FROM (
    VALUES
    ('Aurora Bogota Centro', '101', TIMESTAMP '2026-02-13 08:00:00', 'Post stay inspection', 'Checked air conditioning and bathroom fixtures'),
    ('Andino Medellin', '501', TIMESTAMP '2026-09-14 09:00:00', 'Preventive suite inspection', 'Checked balcony doors and minibar equipment')
) AS x (
    branch_name,
    room_number,
    maintenance_start_at,
    usage_reason,
    activity_detail
)
JOIN branch b
    ON b.name = x.branch_name
JOIN room r
    ON r.branch_id = b.id
   AND r.room_number = x.room_number
JOIN room_maintenance rm
    ON rm.room_id = r.id
   AND rm.start_at = x.maintenance_start_at
ON CONFLICT (room_maintenance_id) DO UPDATE
SET
    usage_reason = EXCLUDED.usage_reason,
    activity_detail = EXCLUDED.activity_detail;

-- =====================================================
-- REMODELING MAINTENANCE
-- Depends on ROOM MAINTENANCE
-- =====================================================

INSERT INTO remodeling_maintenance (
    room_maintenance_id,
    remodeling_description,
    estimated_budget
)
SELECT
    rm.id,
    'Bathroom remodeling and fixture replacement',
    NUMERIC '3500000.00'
FROM branch b
JOIN room r
    ON r.branch_id = b.id
JOIN room_maintenance rm
    ON rm.room_id = r.id
WHERE b.name = 'Aurora Bogota Centro'
  AND r.room_number = '202'
  AND rm.start_at = TIMESTAMP '2026-08-01 08:00:00'
ON CONFLICT (room_maintenance_id) DO UPDATE
SET
    remodeling_description = EXCLUDED.remodeling_description,
    estimated_budget = EXCLUDED.estimated_budget;

-- =====================================================
-- MAINTENANCE DASHBOARD
-- Depends on BRANCH
-- =====================================================

INSERT INTO maintenance_dashboard (
    branch_id,
    total_rooms,
    available_rooms,
    occupied_rooms,
    maintenance_rooms,
    cutoff_at
)
SELECT
    b.id,
    x.total_rooms,
    x.available_rooms,
    x.occupied_rooms,
    x.maintenance_rooms,
    x.cutoff_at
FROM (
    VALUES
    ('Aurora Bogota Centro', 2, 1, 1, 1, TIMESTAMP '2026-08-01 12:00:00'),
    ('Andino Medellin', 1, 1, 0, 0, TIMESTAMP '2026-09-14 12:00:00'),
    ('Caribe Cartagena', 0, 0, 0, 0, TIMESTAMP '2026-01-01 00:00:00')
) AS x (
    branch_name,
    total_rooms,
    available_rooms,
    occupied_rooms,
    maintenance_rooms,
    cutoff_at
)
JOIN branch b
    ON b.name = x.branch_name
WHERE NOT EXISTS (
    SELECT 1
    FROM maintenance_dashboard md
    WHERE md.branch_id = b.id
      AND md.cutoff_at = x.cutoff_at
);
