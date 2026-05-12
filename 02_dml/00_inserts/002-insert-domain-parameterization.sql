-- =====================================================
-- CUSTOMER
-- Compatible with existing PERSON records
-- =====================================================

INSERT INTO customer (
    document_type,
    document_number,
    first_name,
    last_name,
    phone,
    email,
    address
)
VALUES
(
    'CC',
    '52530001',
    'Ariel',
    'Ramirez',
    '3004567890',
    'ariel@mail.com',
    'Cra 15 #93-21 Bogotá'
),
(
    'CC',
    '1025478963',
    'Maria',
    'Gonzalez',
    '3116547890',
    'maria@mail.com',
    'Calle 72 #10-55 Bogotá'
),
(
    'CC',
    '1036987452',
    'Carlos',
    'Lopez',
    '3207894561',
    'carlos@mail.com',
    'Av El Poblado #45-18 Medellín'
)
ON CONFLICT (document_type, document_number) DO UPDATE
SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    address = EXCLUDED.address;

-- =====================================================
-- COMPANY
-- =====================================================

INSERT INTO company (
    name,
    tax_id,
    legal_name,
    phone,
    email,
    address,
    website
)
VALUES
(
    'Hotel Aurora',
    '901456789-1',
    'Hotel Aurora SAS',
    '6014567890',
    'contacto@hotelaurora.com',
    'Zona T Bogotá',
    'https://www.hotelaurora.com'
),
(
    'Turismo Andino',
    '900874563-2',
    'Turismo Andino LTDA',
    '6048745632',
    'ventas@turismoandino.com',
    'El Poblado Medellín',
    'https://www.turismoandino.com'
),
(
    'Caribe Resort',
    '901998741-5',
    'Caribe Resort SAS',
    '6059987412',
    'info@cariberesort.com',
    'Bocagrande Cartagena',
    'https://www.cariberesort.com'
)
ON CONFLICT (tax_id) DO UPDATE
SET
    name = EXCLUDED.name,
    legal_name = EXCLUDED.legal_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    address = EXCLUDED.address,
    website = EXCLUDED.website;

-- =====================================================
-- DAY TYPE
-- =====================================================

INSERT INTO day_type (
    name,
    description,
    date_value,
    applies_season,
    applies_holiday,
    applies_special
)
VALUES
(
    'HIGH_SEASON',
    'High tourist season',
    '2026-01-15',
    TRUE,
    FALSE,
    FALSE
),
(
    'HOLIDAY',
    'National holiday',
    '2026-07-20',
    FALSE,
    TRUE,
    FALSE
),
(
    'SPECIAL_EVENT',
    'Special tourism event',
    '2026-09-12',
    FALSE,
    FALSE,
    TRUE
)
ON CONFLICT (name, date_value) DO UPDATE
SET
    description = EXCLUDED.description,
    applies_season = EXCLUDED.applies_season,
    applies_holiday = EXCLUDED.applies_holiday,
    applies_special = EXCLUDED.applies_special;

-- =====================================================
-- PAYMENT METHOD
-- =====================================================

INSERT INTO payment_method (
    name,
    description,
    requires_reference,
    allows_partial_payment
)
VALUES
(
    'CREDIT_CARD',
    'Visa and MasterCard payments',
    TRUE,
    TRUE
),
(
    'BANK_TRANSFER',
    'Payment by bank transfer',
    TRUE,
    FALSE
),
(
    'CASH',
    'Cash payment at front desk',
    FALSE,
    TRUE
)
ON CONFLICT (name) DO UPDATE
SET
    description = EXCLUDED.description,
    requires_reference = EXCLUDED.requires_reference,
    allows_partial_payment = EXCLUDED.allows_partial_payment;

-- =====================================================
-- LEGAL INFORMATION
-- Depends on COMPANY
-- =====================================================

INSERT INTO legal_information (
    company_id,
    legal_document_type,
    legal_document_number,
    description,
    issue_date,
    expiration_date
)
SELECT
    c.id,
    x.legal_document_type,
    x.legal_document_number,
    x.description,
    x.issue_date,
    x.expiration_date
FROM (
    VALUES
    (
        '901456789-1',
        'RNT',
        'RNT-458741',
        'National tourism registry',
        DATE '2025-01-10',
        DATE '2027-01-10'
    ),
    (
        '900874563-2',
        'CHAMBER_OF_COMMERCE',
        'CCM-874563',
        'Commercial registration',
        DATE '2025-02-15',
        DATE '2026-02-15'
    ),
    (
        '901998741-5',
        'HOTEL_LICENSE',
        'LIC-998741',
        'Hotel operation license',
        DATE '2025-03-01',
        DATE '2028-03-01'
    )
) AS x (
    tax_id,
    legal_document_type,
    legal_document_number,
    description,
    issue_date,
    expiration_date
)
JOIN company c
    ON c.tax_id = x.tax_id;

-- =====================================================
-- EMPLOYEE
-- Depends on PERSON
-- =====================================================

INSERT INTO employee (
    person_id,
    job_title,
    hire_date,
    work_phone,
    work_email
)
SELECT
    p.id,
    x.job_title,
    x.hire_date,
    x.work_phone,
    x.work_email
FROM (
    VALUES
    (
        '52530001',
        'General Manager',
        DATE '2023-01-15',
        '3004567001',
        'ariel.ramirez@hotel.com'
    ),
    (
        '1025478963',
        'Front Desk Supervisor',
        DATE '2024-03-10',
        '3116547002',
        'maria.gonzalez@hotel.com'
    ),
    (
        '1036987452',
        'Maintenance Technician',
        DATE '2024-06-01',
        '3207897003',
        'carlos.lopez@hotel.com'
    )
) AS x (
    document_number,
    job_title,
    hire_date,
    work_phone,
    work_email
)
JOIN person p
    ON p.document_number = x.document_number
ON CONFLICT (person_id) DO UPDATE
SET
    job_title = EXCLUDED.job_title,
    hire_date = EXCLUDED.hire_date,
    work_phone = EXCLUDED.work_phone,
    work_email = EXCLUDED.work_email;