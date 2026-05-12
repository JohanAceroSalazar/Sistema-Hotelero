-- Security domain procedures
CREATE OR REPLACE PROCEDURE prc_security_block_user(p_username VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE app_user
  SET is_blocked = TRUE,
      updated_at = CURRENT_TIMESTAMP
  WHERE username = p_username
    AND deleted_at IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE prc_security_unblock_user(p_username VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE app_user
  SET is_blocked = FALSE,
      status = 'ACTIVE',
      updated_at = CURRENT_TIMESTAMP
  WHERE username = p_username
    AND deleted_at IS NULL;
END;
$$;

-- Parameterization domain procedures
CREATE OR REPLACE PROCEDURE prc_parameterization_deactivate_customer(p_document_number VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE customer
  SET status = 'INACTIVE',
      updated_at = CURRENT_TIMESTAMP
  WHERE document_number = p_document_number
    AND deleted_at IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE prc_parameterization_activate_customer(p_document_number VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE customer
  SET status = 'ACTIVE',
      updated_at = CURRENT_TIMESTAMP
  WHERE document_number = p_document_number
    AND deleted_at IS NULL;
END;
$$;

-- Distribution domain procedures
CREATE OR REPLACE PROCEDURE prc_distribution_set_room_status(
  p_room_number VARCHAR,
  p_status_name VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_status_id UUID;
BEGIN
  SELECT id
  INTO v_status_id
  FROM room_status
  WHERE name = p_status_name
    AND deleted_at IS NULL
  LIMIT 1;

  IF v_status_id IS NULL THEN
    RAISE EXCEPTION 'Room status % does not exist', p_status_name;
  END IF;

  UPDATE room
  SET room_status_id = v_status_id,
      updated_at = CURRENT_TIMESTAMP
  WHERE room_number = p_room_number
    AND deleted_at IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE prc_distribution_close_expired_rates(p_cutoff_date DATE DEFAULT CURRENT_DATE)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE rate
  SET status = 'INACTIVE',
      updated_at = CURRENT_TIMESTAMP
  WHERE end_date IS NOT NULL
    AND end_date < p_cutoff_date
    AND status = 'ACTIVE'
    AND deleted_at IS NULL;
END;
$$;

-- Inventory domain procedures
CREATE OR REPLACE PROCEDURE prc_inventory_register_product_movement(
  p_product_name VARCHAR,
  p_movement_type VARCHAR,
  p_quantity INTEGER,
  p_note TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_product_id UUID;
  v_current_stock INTEGER;
BEGIN
  SELECT id, current_stock
  INTO v_product_id, v_current_stock
  FROM product
  WHERE name = p_product_name
    AND deleted_at IS NULL
  LIMIT 1;

  IF v_product_id IS NULL THEN
    RAISE EXCEPTION 'Product % does not exist', p_product_name;
  END IF;

  IF p_quantity <= 0 THEN
    RAISE EXCEPTION 'Quantity must be greater than zero';
  END IF;

  IF UPPER(p_movement_type) = 'OUT' AND v_current_stock < p_quantity THEN
    RAISE EXCEPTION 'Insufficient stock for product %', p_product_name;
  END IF;

  INSERT INTO product_movement (product_id, movement_type, quantity, note)
  VALUES (v_product_id, UPPER(p_movement_type), p_quantity, p_note);

  UPDATE product
  SET current_stock = CASE
        WHEN UPPER(p_movement_type) = 'IN' THEN current_stock + p_quantity
        WHEN UPPER(p_movement_type) = 'OUT' THEN current_stock - p_quantity
        ELSE current_stock
      END,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = v_product_id;
END;
$$;

CREATE OR REPLACE PROCEDURE prc_inventory_set_service_availability(
  p_service_name VARCHAR,
  p_is_available BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE service
  SET is_available = p_is_available,
      updated_at = CURRENT_TIMESTAMP
  WHERE name = p_service_name
    AND deleted_at IS NULL;
END;
$$;

-- Service delivery domain procedures
CREATE OR REPLACE PROCEDURE prc_delivery_confirm_reservation(p_reservation_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE room_reservation
  SET reservation_status = 'CONFIRMED',
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_reservation_id
    AND deleted_at IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE prc_delivery_cancel_reservation(
  p_reservation_id UUID,
  p_reason VARCHAR,
  p_applies_penalty BOOLEAN DEFAULT FALSE,
  p_penalty_amount NUMERIC DEFAULT 0
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO room_cancellation (
    room_reservation_id,
    reason,
    applies_penalty,
    penalty_amount
  )
  VALUES (
    p_reservation_id,
    p_reason,
    p_applies_penalty,
    p_penalty_amount
  )
  ON CONFLICT (room_reservation_id) DO UPDATE
  SET reason = EXCLUDED.reason,
      applies_penalty = EXCLUDED.applies_penalty,
      penalty_amount = EXCLUDED.penalty_amount,
      updated_at = CURRENT_TIMESTAMP;

  UPDATE room_reservation
  SET reservation_status = 'CANCELLED',
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_reservation_id
    AND deleted_at IS NULL;
END;
$$;

-- Billing domain procedures
CREATE OR REPLACE PROCEDURE prc_billing_register_partial_payment(
  p_invoice_number VARCHAR,
  p_payment_method_name VARCHAR,
  p_amount NUMERIC,
  p_payment_reference VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_invoice_id UUID;
  v_payment_method_id UUID;
BEGIN
  SELECT id
  INTO v_invoice_id
  FROM invoice
  WHERE invoice_number = p_invoice_number
    AND deleted_at IS NULL;

  SELECT id
  INTO v_payment_method_id
  FROM payment_method
  WHERE name = p_payment_method_name
    AND deleted_at IS NULL;

  IF v_invoice_id IS NULL THEN
    RAISE EXCEPTION 'Invoice % does not exist', p_invoice_number;
  END IF;

  IF v_payment_method_id IS NULL THEN
    RAISE EXCEPTION 'Payment method % does not exist', p_payment_method_name;
  END IF;

  INSERT INTO partial_payment (invoice_id, payment_method_id, amount, payment_reference)
  VALUES (v_invoice_id, v_payment_method_id, p_amount, p_payment_reference);
END;
$$;

CREATE OR REPLACE PROCEDURE prc_billing_update_invoice_status(p_invoice_number VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
  v_balance NUMERIC(12,2);
BEGIN
  v_balance := fn_billing_invoice_balance(p_invoice_number);

  UPDATE invoice
  SET invoice_status = CASE WHEN v_balance <= 0 THEN 'PAID' ELSE 'PARTIAL' END,
      updated_at = CURRENT_TIMESTAMP
  WHERE invoice_number = p_invoice_number
    AND deleted_at IS NULL;
END;
$$;

-- Notification domain procedures
CREATE OR REPLACE PROCEDURE prc_notification_mark_alert_sent(p_alert_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE alert
  SET sent_at = CURRENT_TIMESTAMP,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_alert_id
    AND deleted_at IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE prc_notification_add_loyalty_points(
  p_document_number VARCHAR,
  p_points INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  IF p_points <= 0 THEN
    RAISE EXCEPTION 'Points must be greater than zero';
  END IF;

  UPDATE customer_loyalty cl
  SET points = cl.points + p_points,
      last_interaction_at = CURRENT_TIMESTAMP,
      updated_at = CURRENT_TIMESTAMP
  FROM customer c
  WHERE c.id = cl.customer_id
    AND c.document_number = p_document_number
    AND cl.deleted_at IS NULL;
END;
$$;

-- Maintenance domain procedures
CREATE OR REPLACE PROCEDURE prc_maintenance_start_task(p_maintenance_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE room_maintenance
  SET maintenance_status = 'IN_PROGRESS',
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_maintenance_id
    AND deleted_at IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE prc_maintenance_complete_task(p_maintenance_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE room_maintenance
  SET maintenance_status = 'COMPLETED',
      end_at = COALESCE(end_at, CURRENT_TIMESTAMP),
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_maintenance_id
    AND deleted_at IS NULL;
END;
$$;