CREATE OR REPLACE FUNCTION fn_trg_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

-- Security domain triggers
DROP TRIGGER IF EXISTS trg_person_set_updated_at ON person;
CREATE TRIGGER trg_person_set_updated_at
BEFORE UPDATE ON person
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_app_user_set_updated_at ON app_user;
CREATE TRIGGER trg_app_user_set_updated_at
BEFORE UPDATE ON app_user
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

-- Parameterization domain triggers
DROP TRIGGER IF EXISTS trg_customer_set_updated_at ON customer;
CREATE TRIGGER trg_customer_set_updated_at
BEFORE UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_company_set_updated_at ON company;
CREATE TRIGGER trg_company_set_updated_at
BEFORE UPDATE ON company
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

-- Distribution domain triggers
DROP TRIGGER IF EXISTS trg_room_set_updated_at ON room;
CREATE TRIGGER trg_room_set_updated_at
BEFORE UPDATE ON room
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_rate_set_updated_at ON rate;
CREATE TRIGGER trg_rate_set_updated_at
BEFORE UPDATE ON rate
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

-- Inventory domain triggers
DROP TRIGGER IF EXISTS trg_product_set_updated_at ON product;
CREATE TRIGGER trg_product_set_updated_at
BEFORE UPDATE ON product
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_service_set_updated_at ON service;
CREATE TRIGGER trg_service_set_updated_at
BEFORE UPDATE ON service
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

-- Service delivery domain triggers
DROP TRIGGER IF EXISTS trg_room_reservation_set_updated_at ON room_reservation;
CREATE TRIGGER trg_room_reservation_set_updated_at
BEFORE UPDATE ON room_reservation
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_stay_set_updated_at ON stay;
CREATE TRIGGER trg_stay_set_updated_at
BEFORE UPDATE ON stay
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

-- Billing domain triggers
DROP TRIGGER IF EXISTS trg_invoice_set_updated_at ON invoice;
CREATE TRIGGER trg_invoice_set_updated_at
BEFORE UPDATE ON invoice
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_partial_payment_set_updated_at ON partial_payment;
CREATE TRIGGER trg_partial_payment_set_updated_at
BEFORE UPDATE ON partial_payment
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

-- Notification domain triggers
DROP TRIGGER IF EXISTS trg_promotion_set_updated_at ON promotion;
CREATE TRIGGER trg_promotion_set_updated_at
BEFORE UPDATE ON promotion
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_customer_loyalty_set_updated_at ON customer_loyalty;
CREATE TRIGGER trg_customer_loyalty_set_updated_at
BEFORE UPDATE ON customer_loyalty
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

-- Maintenance domain triggers
DROP TRIGGER IF EXISTS trg_room_maintenance_set_updated_at ON room_maintenance;
CREATE TRIGGER trg_room_maintenance_set_updated_at
BEFORE UPDATE ON room_maintenance
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();

DROP TRIGGER IF EXISTS trg_maintenance_dashboard_set_updated_at ON maintenance_dashboard;
CREATE TRIGGER trg_maintenance_dashboard_set_updated_at
BEFORE UPDATE ON maintenance_dashboard
FOR EACH ROW
EXECUTE FUNCTION fn_trg_set_updated_at();