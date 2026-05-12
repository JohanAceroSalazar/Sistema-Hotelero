-- Security domain views
CREATE OR REPLACE VIEW vw_security_users_roles AS
SELECT
  u.id AS user_id,
  u.username,
  p.document_type,
  p.document_number,
  p.first_name,
  p.last_name,
  r.name AS role_name,
  u.is_blocked,
  u.status
FROM app_user u
JOIN person p ON p.id = u.person_id
LEFT JOIN user_role ur ON ur.user_id = u.id AND ur.status = 'ACTIVE'
LEFT JOIN app_role r ON r.id = ur.role_id AND r.status = 'ACTIVE'
WHERE u.deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_security_roles_permissions AS
SELECT
  r.id AS role_id,
  r.name AS role_name,
  p.name AS permission_name,
  p.action,
  p.description AS permission_description
FROM app_role r
LEFT JOIN role_permission rp ON rp.role_id = r.id AND rp.status = 'ACTIVE'
LEFT JOIN permission p ON p.id = rp.permission_id AND p.status = 'ACTIVE'
WHERE r.deleted_at IS NULL;

-- Parameterization domain views
CREATE OR REPLACE VIEW vw_parameterization_customers AS
SELECT
  id,
  document_type,
  document_number,
  first_name || ' ' || last_name AS full_name,
  phone,
  email,
  address,
  status
FROM customer
WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_parameterization_companies_legal AS
SELECT
  c.id AS company_id,
  c.name AS company_name,
  c.tax_id,
  li.legal_document_type,
  li.legal_document_number,
  li.issue_date,
  li.expiration_date,
  li.status AS legal_status
FROM company c
LEFT JOIN legal_information li ON li.company_id = c.id AND li.deleted_at IS NULL
WHERE c.deleted_at IS NULL;

-- Distribution domain views
CREATE OR REPLACE VIEW vw_distribution_rooms_detail AS
SELECT
  r.id AS room_id,
  b.name AS branch_name,
  b.city,
  r.room_number,
  r.floor_number,
  rt.name AS room_type,
  rs.name AS room_status,
  rs.allows_reservation,
  rs.allows_check_in,
  r.capacity
FROM room r
JOIN branch b ON b.id = r.branch_id
JOIN room_type rt ON rt.id = r.room_type_id
JOIN room_status rs ON rs.id = r.room_status_id
WHERE r.deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_distribution_active_rates AS
SELECT
  rt.name AS room_type,
  dt.name AS day_type,
  rate.amount,
  rate.start_date,
  rate.end_date,
  rate.condition_note
FROM rate
JOIN room_type rt ON rt.id = rate.room_type_id
JOIN day_type dt ON dt.id = rate.day_type_id
WHERE rate.status = 'ACTIVE'
  AND rate.deleted_at IS NULL
  AND (rate.end_date IS NULL OR rate.end_date >= CURRENT_DATE);

-- Inventory domain views
CREATE OR REPLACE VIEW vw_inventory_products_stock AS
SELECT
  p.id AS product_id,
  p.name AS product_name,
  s.name AS supplier_name,
  p.sale_price,
  p.current_stock,
  p.minimum_stock,
  (p.current_stock <= p.minimum_stock) AS needs_restock,
  p.status
FROM product p
LEFT JOIN supplier s ON s.id = p.supplier_id
WHERE p.deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_inventory_available_items AS
SELECT
  ia.id AS availability_id,
  COALESCE(p.name, sv.name) AS item_name,
  CASE WHEN ia.product_id IS NOT NULL THEN 'PRODUCT' ELSE 'SERVICE' END AS item_type,
  ia.available_quantity,
  ia.is_available,
  ia.note
FROM inventory_availability ia
LEFT JOIN product p ON p.id = ia.product_id
LEFT JOIN service sv ON sv.id = ia.service_id
WHERE ia.deleted_at IS NULL;

-- Service delivery domain views
CREATE OR REPLACE VIEW vw_delivery_reservations_detail AS
SELECT
  rr.id AS reservation_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  r.room_number,
  b.name AS branch_name,
  rr.start_at,
  rr.end_at,
  rr.guest_count,
  rr.reservation_status,
  rr.estimated_amount
FROM room_reservation rr
JOIN customer c ON c.id = rr.customer_id
JOIN room r ON r.id = rr.room_id
JOIN branch b ON b.id = r.branch_id
WHERE rr.deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_delivery_stay_consumption AS
SELECT
  s.id AS stay_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  r.room_number,
  COALESCE(ps.products_total, 0) AS products_total,
  COALESCE(ss.services_total, 0) AS services_total,
  COALESCE(ps.products_total, 0) + COALESCE(ss.services_total, 0) AS consumption_total
FROM stay s
JOIN customer c ON c.id = s.customer_id
JOIN room r ON r.id = s.room_id
LEFT JOIN (
  SELECT stay_id, SUM(total_amount) AS products_total
  FROM product_sale
  WHERE deleted_at IS NULL
  GROUP BY stay_id
) ps ON ps.stay_id = s.id
LEFT JOIN (
  SELECT stay_id, SUM(total_amount) AS services_total
  FROM service_sale
  WHERE deleted_at IS NULL
  GROUP BY stay_id
) ss ON ss.stay_id = s.id
WHERE s.deleted_at IS NULL;

-- Billing domain views
CREATE OR REPLACE VIEW vw_billing_invoices_summary AS
SELECT
  i.id AS invoice_id,
  i.invoice_number,
  c.first_name || ' ' || c.last_name AS customer_name,
  i.issued_at,
  i.subtotal,
  i.tax_amount,
  i.discount_amount,
  i.total_amount,
  COALESCE(SUM(pp.amount), 0) AS paid_amount,
  i.total_amount - COALESCE(SUM(pp.amount), 0) AS balance_amount,
  i.invoice_status
FROM invoice i
JOIN customer c ON c.id = i.customer_id
LEFT JOIN partial_payment pp ON pp.invoice_id = i.id AND pp.deleted_at IS NULL
WHERE i.deleted_at IS NULL
GROUP BY i.id, i.invoice_number, c.first_name, c.last_name, i.issued_at, i.subtotal, i.tax_amount,
  i.discount_amount, i.total_amount, i.invoice_status;

CREATE OR REPLACE VIEW vw_billing_invoice_details AS
SELECT
  i.invoice_number,
  idt.description,
  COALESCE(p.name, sv.name) AS item_name,
  idt.quantity,
  idt.unit_price,
  idt.total_amount
FROM invoice_detail idt
JOIN invoice i ON i.id = idt.invoice_id
LEFT JOIN product p ON p.id = idt.product_id
LEFT JOIN service sv ON sv.id = idt.service_id
WHERE idt.deleted_at IS NULL;

-- Notification domain views
CREATE OR REPLACE VIEW vw_notification_active_promotions AS
SELECT
  id,
  title,
  description,
  channel,
  start_at,
  end_at,
  is_active
FROM promotion
WHERE is_active = TRUE
  AND status = 'ACTIVE'
  AND deleted_at IS NULL
  AND start_at <= CURRENT_TIMESTAMP
  AND (end_at IS NULL OR end_at >= CURRENT_TIMESTAMP);

CREATE OR REPLACE VIEW vw_notification_customer_loyalty AS
SELECT
  c.id AS customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.email,
  cl.level,
  cl.points,
  cl.last_interaction_at
FROM customer_loyalty cl
JOIN customer c ON c.id = cl.customer_id
WHERE cl.deleted_at IS NULL;

-- Maintenance domain views
CREATE OR REPLACE VIEW vw_maintenance_room_tasks AS
SELECT
  rm.id AS maintenance_id,
  r.room_number,
  b.name AS branch_name,
  e.job_title AS employee_job_title,
  rm.maintenance_type,
  rm.start_at,
  rm.end_at,
  rm.maintenance_status,
  rm.note
FROM room_maintenance rm
JOIN room r ON r.id = rm.room_id
JOIN branch b ON b.id = r.branch_id
LEFT JOIN employee e ON e.id = rm.employee_id
WHERE rm.deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_maintenance_dashboard_summary AS
SELECT
  md.id AS dashboard_id,
  b.name AS branch_name,
  md.total_rooms,
  md.available_rooms,
  md.occupied_rooms,
  md.maintenance_rooms,
  md.cutoff_at
FROM maintenance_dashboard md
JOIN branch b ON b.id = md.branch_id
WHERE md.deleted_at IS NULL;