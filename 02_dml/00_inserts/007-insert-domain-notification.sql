-- =====================================================
-- PROMOTION
-- =====================================================

INSERT INTO promotion (
    title,
    description,
    start_at,
    end_at,
    channel,
    is_active
)
SELECT
    x.title,
    x.description,
    x.start_at,
    x.end_at,
    x.channel,
    x.is_active
FROM (
    VALUES
    ('Holiday Stay Discount', 'Discount for holiday reservations', TIMESTAMP '2026-07-01 00:00:00', TIMESTAMP '2026-07-31 23:59:59', 'EMAIL', TRUE),
    ('Suite Weekend Upgrade', 'Upgrade campaign for suite guests', TIMESTAMP '2026-09-01 00:00:00', TIMESTAMP '2026-09-30 23:59:59', 'SMS', TRUE),
    ('Spa Guest Benefit', 'Spa benefit for active guests', TIMESTAMP '2026-02-01 00:00:00', TIMESTAMP '2026-12-31 23:59:59', 'APP', TRUE)
) AS x (
    title,
    description,
    start_at,
    end_at,
    channel,
    is_active
)
WHERE NOT EXISTS (
    SELECT 1
    FROM promotion p
    WHERE p.title = x.title
      AND p.start_at = x.start_at
      AND p.channel = x.channel
);

-- =====================================================
-- ALERT
-- Depends on CUSTOMER and ROOM RESERVATION
-- =====================================================

INSERT INTO alert (
    customer_id,
    room_reservation_id,
    title,
    message,
    channel,
    sent_at
)
SELECT
    rr.customer_id,
    rr.id,
    x.title,
    x.message,
    x.channel,
    x.sent_at
FROM (
    VALUES
    ('52530001', TIMESTAMP '2026-02-10 15:00:00', 'Reservation confirmed', 'Your reservation has been confirmed.', 'EMAIL', TIMESTAMP '2026-02-01 09:00:00'),
    ('1025478963', TIMESTAMP '2026-07-18 15:00:00', 'Check-in reminder', 'Your check-in is scheduled for today.', 'SMS', TIMESTAMP '2026-07-18 08:00:00'),
    ('1036987452', TIMESTAMP '2026-09-10 15:00:00', 'Cancellation registered', 'Your cancellation request was registered.', 'EMAIL', TIMESTAMP '2026-09-05 10:10:00')
) AS x (
    customer_document_number,
    reservation_start_at,
    title,
    message,
    channel,
    sent_at
)
JOIN room_reservation rr
    ON rr.start_at = x.reservation_start_at
JOIN customer c
    ON c.id = rr.customer_id
   AND c.document_number = x.customer_document_number
WHERE NOT EXISTS (
    SELECT 1
    FROM alert a
    WHERE a.customer_id = rr.customer_id
      AND a.room_reservation_id = rr.id
      AND a.title = x.title
      AND a.channel = x.channel
);

-- =====================================================
-- TERM CONDITION
-- =====================================================

INSERT INTO term_condition (
    title,
    content,
    version,
    effective_date,
    is_required
)
VALUES
('General Booking Terms', 'Guests must follow hotel booking and cancellation policies.', 'BOOKING-2026-01', DATE '2026-01-01', TRUE),
('Privacy Policy', 'Customer data is processed according to applicable privacy regulations.', 'PRIVACY-2026-01', DATE '2026-01-01', TRUE),
('Loyalty Program Terms', 'Points are granted for eligible stays and services.', 'LOYALTY-2026-01', DATE '2026-01-01', FALSE)
ON CONFLICT (version) DO UPDATE
SET
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    effective_date = EXCLUDED.effective_date,
    is_required = EXCLUDED.is_required;

-- =====================================================
-- CUSTOMER LOYALTY
-- Depends on CUSTOMER
-- =====================================================

INSERT INTO customer_loyalty (
    customer_id,
    level,
    points,
    last_interaction_at,
    note
)
SELECT
    c.id,
    x.level,
    x.points,
    x.last_interaction_at,
    x.note
FROM (
    VALUES
    ('52530001', 'GOLD', 1500, TIMESTAMP '2026-02-12 11:30:00', 'Completed stay with invoice paid'),
    ('1025478963', 'SILVER', 850, TIMESTAMP '2026-07-18 16:00:00', 'Active stay with pending invoice'),
    ('1036987452', 'BASIC', 120, TIMESTAMP '2026-09-05 10:10:00', 'Reservation cancelled with penalty')
) AS x (
    customer_document_number,
    level,
    points,
    last_interaction_at,
    note
)
JOIN customer c
    ON c.document_number = x.customer_document_number
ON CONFLICT (customer_id) DO UPDATE
SET
    level = EXCLUDED.level,
    points = EXCLUDED.points,
    last_interaction_at = EXCLUDED.last_interaction_at,
    note = EXCLUDED.note;
