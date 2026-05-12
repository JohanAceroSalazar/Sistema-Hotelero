-- Security domain functions
CREATE OR REPLACE FUNCTION fn_security_user_role_count(p_username VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM app_user u
  JOIN user_role ur ON ur.user_id = u.id
  WHERE u.username = p_username
    AND ur.status = 'ACTIVE'
    AND ur.deleted_at IS NULL;

  RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION fn_security_role_permission_count(p_role_name VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM app_role r
  JOIN role_permission rp ON rp.role_id = r.id
  WHERE r.name = p_role_name
    AND rp.status = 'ACTIVE'
    AND rp.deleted_at IS NULL;

  RETURN v_total;
END;
$$;

-- Parameterization domain functions
CREATE OR REPLACE FUNCTION fn_parameterization_customer_full_name(p_document_number VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
  v_full_name VARCHAR;
BEGIN
  SELECT first_name || ' ' || last_name
  INTO v_full_name
  FROM customer
  WHERE document_number = p_document_number
    AND deleted_at IS NULL
  LIMIT 1;

  RETURN v_full_name;
END;
$$;

CREATE OR REPLACE FUNCTION fn_parameterization_company_legal_document_count(p_tax_id VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM company c
  JOIN legal_information li ON li.company_id = c.id
  WHERE c.tax_id = p_tax_id
    AND li.deleted_at IS NULL;

  RETURN v_total;
END;
$$;

-- Distribution domain functions
CREATE OR REPLACE FUNCTION fn_distribution_available_room_count(p_branch_name VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM room r
  JOIN branch b ON b.id = r.branch_id
  JOIN room_status rs ON rs.id = r.room_status_id
  WHERE b.name = p_branch_name
    AND rs.allows_reservation = TRUE
    AND r.status = 'ACTIVE'
    AND r.deleted_at IS NULL;

  RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION fn_distribution_current_rate(
  p_room_type_name VARCHAR,
  p_day_type_name VARCHAR,
  p_rate_date DATE DEFAULT CURRENT_DATE
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  v_amount NUMERIC(12,2);
BEGIN
  SELECT rate.amount
  INTO v_amount
  FROM rate
  JOIN room_type rt ON rt.id = rate.room_type_id
  JOIN day_type dt ON dt.id = rate.day_type_id
  WHERE rt.name = p_room_type_name
    AND dt.name = p_day_type_name
    AND rate.start_date <= p_rate_date
    AND (rate.end_date IS NULL OR rate.end_date >= p_rate_date)
    AND rate.status = 'ACTIVE'
    AND rate.deleted_at IS NULL
  ORDER BY rate.start_date DESC
  LIMIT 1;

  RETURN COALESCE(v_amount, 0);
END;
$$;

-- Inventory domain functions
CREATE OR REPLACE FUNCTION fn_inventory_stock_gap(p_product_name VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_gap INTEGER;
BEGIN
  SELECT GREATEST(minimum_stock - current_stock, 0)
  INTO v_gap
  FROM product
  WHERE name = p_product_name
    AND deleted_at IS NULL
  LIMIT 1;

  RETURN COALESCE(v_gap, 0);
END;
$$;

CREATE OR REPLACE FUNCTION fn_inventory_available_service_count()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM service
  WHERE is_available = TRUE
    AND status = 'ACTIVE'
    AND deleted_at IS NULL;

  RETURN v_total;
END;
$$;

-- Service delivery domain functions
CREATE OR REPLACE FUNCTION fn_delivery_reservation_nights(p_reservation_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_nights INTEGER;
BEGIN
  SELECT GREATEST(CEIL(EXTRACT(EPOCH FROM (end_at - start_at)) / 86400)::INTEGER, 1)
  INTO v_nights
  FROM room_reservation
  WHERE id = p_reservation_id
    AND deleted_at IS NULL;

  RETURN COALESCE(v_nights, 0);
END;
$$;

CREATE OR REPLACE FUNCTION fn_delivery_stay_consumption_total(p_stay_id UUID)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  v_total NUMERIC(12,2);
BEGIN
  SELECT
    COALESCE((SELECT SUM(total_amount) FROM product_sale WHERE stay_id = p_stay_id AND deleted_at IS NULL), 0)
    + COALESCE((SELECT SUM(total_amount) FROM service_sale WHERE stay_id = p_stay_id AND deleted_at IS NULL), 0)
  INTO v_total;

  RETURN COALESCE(v_total, 0);
END;
$$;

-- Billing domain functions
CREATE OR REPLACE FUNCTION fn_billing_invoice_paid_amount(p_invoice_number VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  v_paid NUMERIC(12,2);
BEGIN
  SELECT COALESCE(SUM(pp.amount), 0)
  INTO v_paid
  FROM invoice i
  LEFT JOIN partial_payment pp ON pp.invoice_id = i.id AND pp.deleted_at IS NULL
  WHERE i.invoice_number = p_invoice_number
    AND i.deleted_at IS NULL;

  RETURN COALESCE(v_paid, 0);
END;
$$;

CREATE OR REPLACE FUNCTION fn_billing_invoice_balance(p_invoice_number VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  v_balance NUMERIC(12,2);
BEGIN
  SELECT i.total_amount - COALESCE(SUM(pp.amount), 0)
  INTO v_balance
  FROM invoice i
  LEFT JOIN partial_payment pp ON pp.invoice_id = i.id AND pp.deleted_at IS NULL
  WHERE i.invoice_number = p_invoice_number
    AND i.deleted_at IS NULL
  GROUP BY i.total_amount;

  RETURN COALESCE(v_balance, 0);
END;
$$;

-- Notification domain functions
CREATE OR REPLACE FUNCTION fn_notification_customer_points(p_document_number VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_points INTEGER;
BEGIN
  SELECT cl.points
  INTO v_points
  FROM customer c
  JOIN customer_loyalty cl ON cl.customer_id = c.id
  WHERE c.document_number = p_document_number
    AND cl.deleted_at IS NULL
  LIMIT 1;

  RETURN COALESCE(v_points, 0);
END;
$$;

CREATE OR REPLACE FUNCTION fn_notification_active_promotion_count(p_channel VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM promotion
  WHERE channel = p_channel
    AND is_active = TRUE
    AND status = 'ACTIVE'
    AND deleted_at IS NULL
    AND start_at <= CURRENT_TIMESTAMP
    AND (end_at IS NULL OR end_at >= CURRENT_TIMESTAMP);

  RETURN v_total;
END;
$$;

-- Maintenance domain functions
CREATE OR REPLACE FUNCTION fn_maintenance_open_room_tasks(p_room_number VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_total
  FROM room_maintenance rm
  JOIN room r ON r.id = rm.room_id
  WHERE r.room_number = p_room_number
    AND rm.maintenance_status IN ('PENDING', 'IN_PROGRESS')
    AND rm.deleted_at IS NULL;

  RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION fn_maintenance_branch_rooms_in_maintenance(p_branch_name VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(DISTINCT rm.room_id)
  INTO v_total
  FROM room_maintenance rm
  JOIN room r ON r.id = rm.room_id
  JOIN branch b ON b.id = r.branch_id
  WHERE b.name = p_branch_name
    AND rm.maintenance_status IN ('PENDING', 'IN_PROGRESS')
    AND rm.deleted_at IS NULL;

  RETURN v_total;
END;
$$;