-- =====================================================
-- PROFORMA INVOICE
-- Depends on STAY, ROOM RESERVATION and CUSTOMER
-- =====================================================

INSERT INTO proforma_invoice (
    stay_id,
    room_reservation_id,
    customer_id,
    subtotal,
    tax_amount,
    discount_amount,
    total_amount
)
SELECT
    s.id,
    s.room_reservation_id,
    s.customer_id,
    x.subtotal,
    x.tax_amount,
    x.discount_amount,
    x.total_amount
FROM (
    VALUES
    ('52530001', TIMESTAMP '2026-02-10 15:30:00', NUMERIC '478500.00', NUMERIC '90915.00', NUMERIC '79915.00', NUMERIC '489500.00'),
    ('1025478963', TIMESTAMP '2026-07-18 15:20:00', NUMERIC '1080000.00', NUMERIC '205200.00', NUMERIC '0.00', NUMERIC '1285200.00')
) AS x (
    customer_document_number,
    stay_start_at,
    subtotal,
    tax_amount,
    discount_amount,
    total_amount
)
JOIN stay s
    ON s.start_at = x.stay_start_at
JOIN customer c
    ON c.id = s.customer_id
   AND c.document_number = x.customer_document_number
ON CONFLICT (stay_id) DO UPDATE
SET
    room_reservation_id = EXCLUDED.room_reservation_id,
    customer_id = EXCLUDED.customer_id,
    subtotal = EXCLUDED.subtotal,
    tax_amount = EXCLUDED.tax_amount,
    discount_amount = EXCLUDED.discount_amount,
    total_amount = EXCLUDED.total_amount;

-- =====================================================
-- INVOICE
-- Depends on CUSTOMER and STAY
-- =====================================================

INSERT INTO invoice (
    customer_id,
    stay_id,
    invoice_number,
    issued_at,
    subtotal,
    tax_amount,
    discount_amount,
    total_amount,
    invoice_status
)
SELECT
    s.customer_id,
    s.id,
    x.invoice_number,
    x.issued_at,
    x.subtotal,
    x.tax_amount,
    x.discount_amount,
    x.total_amount,
    x.invoice_status
FROM (
    VALUES
    ('52530001', TIMESTAMP '2026-02-10 15:30:00', 'INV-2026-0001', TIMESTAMP '2026-02-12 11:30:00', NUMERIC '478500.00', NUMERIC '90915.00', NUMERIC '79915.00', NUMERIC '489500.00', 'PAID'),
    ('1025478963', TIMESTAMP '2026-07-18 15:20:00', 'INV-2026-0002', TIMESTAMP '2026-07-18 16:00:00', NUMERIC '1080000.00', NUMERIC '205200.00', NUMERIC '0.00', NUMERIC '1285200.00', 'ISSUED')
) AS x (
    customer_document_number,
    stay_start_at,
    invoice_number,
    issued_at,
    subtotal,
    tax_amount,
    discount_amount,
    total_amount,
    invoice_status
)
JOIN stay s
    ON s.start_at = x.stay_start_at
JOIN customer c
    ON c.id = s.customer_id
   AND c.document_number = x.customer_document_number
ON CONFLICT (invoice_number) DO UPDATE
SET
    customer_id = EXCLUDED.customer_id,
    stay_id = EXCLUDED.stay_id,
    issued_at = EXCLUDED.issued_at,
    subtotal = EXCLUDED.subtotal,
    tax_amount = EXCLUDED.tax_amount,
    discount_amount = EXCLUDED.discount_amount,
    total_amount = EXCLUDED.total_amount,
    invoice_status = EXCLUDED.invoice_status;

-- =====================================================
-- PARTIAL PAYMENT
-- Depends on ROOM RESERVATION, INVOICE and PAYMENT METHOD
-- =====================================================

INSERT INTO partial_payment (
    room_reservation_id,
    invoice_id,
    payment_method_id,
    amount,
    paid_at,
    payment_reference
)
SELECT
    NULL,
    i.id,
    pm.id,
    x.amount,
    x.paid_at,
    x.payment_reference
FROM (
    VALUES
    ('INV-2026-0001', 'CREDIT_CARD', NUMERIC '489500.00', TIMESTAMP '2026-02-12 11:35:00', 'PAY-INV-2026-0001'),
    ('INV-2026-0002', 'BANK_TRANSFER', NUMERIC '300000.00', TIMESTAMP '2026-07-18 16:10:00', 'PAY-INV-2026-0002-A')
) AS x (
    invoice_number,
    payment_method_name,
    amount,
    paid_at,
    payment_reference
)
JOIN invoice i
    ON i.invoice_number = x.invoice_number
JOIN payment_method pm
    ON pm.name = x.payment_method_name
WHERE NOT EXISTS (
    SELECT 1
    FROM partial_payment pp
    WHERE pp.payment_reference = x.payment_reference
);

INSERT INTO partial_payment (
    room_reservation_id,
    invoice_id,
    payment_method_id,
    amount,
    paid_at,
    payment_reference
)
SELECT
    rr.id,
    NULL,
    pm.id,
    NUMERIC '150000.00',
    TIMESTAMP '2026-09-05 10:05:00',
    'PAY-RES-2026-0003-PENALTY'
FROM room_reservation rr
JOIN customer c
    ON c.id = rr.customer_id
JOIN payment_method pm
    ON pm.name = 'CASH'
WHERE c.document_number = '1036987452'
  AND rr.start_at = TIMESTAMP '2026-09-10 15:00:00'
  AND NOT EXISTS (
      SELECT 1
      FROM partial_payment pp
      WHERE pp.payment_reference = 'PAY-RES-2026-0003-PENALTY'
  );

-- =====================================================
-- INVOICE DETAIL
-- Depends on INVOICE, PRODUCT and SERVICE
-- =====================================================

INSERT INTO invoice_detail (
    invoice_id,
    product_id,
    service_id,
    description,
    quantity,
    unit_price,
    total_amount
)
SELECT
    i.id,
    p.id,
    NULL,
    x.description,
    x.quantity,
    x.unit_price,
    x.total_amount
FROM (
    VALUES
    ('INV-2026-0001', 'BOTTLED_WATER', 'Bottled water consumption', 3, NUMERIC '4500.00', NUMERIC '13500.00'),
    ('INV-2026-0002', 'MINIBAR_SNACK_PACK', 'Minibar snack pack consumption', 2, NUMERIC '15000.00', NUMERIC '30000.00')
) AS x (
    invoice_number,
    product_name,
    description,
    quantity,
    unit_price,
    total_amount
)
JOIN invoice i
    ON i.invoice_number = x.invoice_number
JOIN product p
    ON p.name = x.product_name
WHERE NOT EXISTS (
    SELECT 1
    FROM invoice_detail idt
    WHERE idt.invoice_id = i.id
      AND idt.product_id = p.id
      AND idt.description = x.description
);

INSERT INTO invoice_detail (
    invoice_id,
    product_id,
    service_id,
    description,
    quantity,
    unit_price,
    total_amount
)
SELECT
    i.id,
    NULL,
    s.id,
    x.description,
    x.quantity,
    x.unit_price,
    x.total_amount
FROM (
    VALUES
    ('INV-2026-0001', 'LAUNDRY', 'Laundry service', 1, NUMERIC '25000.00', NUMERIC '25000.00'),
    ('INV-2026-0002', 'AIRPORT_TRANSFER', 'Airport transfer service', 1, NUMERIC '90000.00', NUMERIC '90000.00')
) AS x (
    invoice_number,
    service_name,
    description,
    quantity,
    unit_price,
    total_amount
)
JOIN invoice i
    ON i.invoice_number = x.invoice_number
JOIN service s
    ON s.name = x.service_name
WHERE NOT EXISTS (
    SELECT 1
    FROM invoice_detail idt
    WHERE idt.invoice_id = i.id
      AND idt.service_id = s.id
      AND idt.description = x.description
);
