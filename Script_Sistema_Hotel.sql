CREATE SCHEMA IF NOT EXISTS hotel;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
SET search_path TO hotel;

-- Drop security domain
DROP TABLE IF EXISTS module_view CASCADE;
DROP TABLE IF EXISTS role_permission CASCADE;
DROP TABLE IF EXISTS user_role CASCADE;
DROP TABLE IF EXISTS app_user CASCADE;
DROP TABLE IF EXISTS app_view CASCADE;
DROP TABLE IF EXISTS module CASCADE;
DROP TABLE IF EXISTS permission CASCADE;
DROP TABLE IF EXISTS app_role CASCADE;
DROP TABLE IF EXISTS person CASCADE;

-- Drop parameterization domain
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS legal_information CASCADE;
DROP TABLE IF EXISTS payment_method CASCADE;
DROP TABLE IF EXISTS day_type CASCADE;
DROP TABLE IF EXISTS company CASCADE;
DROP TABLE IF EXISTS customer CASCADE;

-- Drop distribution domain
DROP TABLE IF EXISTS rate CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS room_status CASCADE;
DROP TABLE IF EXISTS room_type CASCADE;
DROP TABLE IF EXISTS branch CASCADE;

-- Drop inventory domain
DROP TABLE IF EXISTS inventory_availability CASCADE;
DROP TABLE IF EXISTS product_movement CASCADE;
DROP TABLE IF EXISTS service CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;

-- Drop service delivery domain
DROP TABLE IF EXISTS service_sale CASCADE;
DROP TABLE IF EXISTS product_sale CASCADE;
DROP TABLE IF EXISTS check_out CASCADE;
DROP TABLE IF EXISTS check_in CASCADE;
DROP TABLE IF EXISTS stay CASCADE;
DROP TABLE IF EXISTS room_catalog CASCADE;
DROP TABLE IF EXISTS room_availability CASCADE;
DROP TABLE IF EXISTS room_cancellation CASCADE;
DROP TABLE IF EXISTS room_reservation CASCADE;

-- Drop billing domain
DROP TABLE IF EXISTS invoice_detail CASCADE;
DROP TABLE IF EXISTS partial_payment CASCADE;
DROP TABLE IF EXISTS invoice CASCADE;
DROP TABLE IF EXISTS proforma_invoice CASCADE;

-- Drop notification domain
DROP TABLE IF EXISTS customer_loyalty CASCADE;
DROP TABLE IF EXISTS term_condition CASCADE;
DROP TABLE IF EXISTS alert CASCADE;
DROP TABLE IF EXISTS promotion CASCADE;

-- Drop maintenance domain
DROP TABLE IF EXISTS maintenance_dashboard CASCADE;
DROP TABLE IF EXISTS remodeling_maintenance CASCADE;
DROP TABLE IF EXISTS usage_maintenance CASCADE;
DROP TABLE IF EXISTS room_maintenance CASCADE;

-- Security domain
CREATE TABLE person (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_type VARCHAR(30) NOT NULL,
  document_number VARCHAR(40) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(40),
  email VARCHAR(160),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_person_document UNIQUE (document_type, document_number),
  CONSTRAINT uk_person_email UNIQUE (email)
);

CREATE TABLE app_role (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) NOT NULL,
  description VARCHAR(255),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_app_role_name UNIQUE (name)
);

CREATE TABLE permission (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  description VARCHAR(255),
  action VARCHAR(80) NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_permission_name_action UNIQUE (name, action)
);

CREATE TABLE module (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  base_path VARCHAR(160) NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_module_name UNIQUE (name),
  CONSTRAINT uk_module_base_path UNIQUE (base_path)
);

CREATE TABLE app_view (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL,
  name VARCHAR(120) NOT NULL,
  description VARCHAR(255),
  path VARCHAR(180) NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_app_view_module_path UNIQUE (module_id, path),
  CONSTRAINT fk_app_view_module FOREIGN KEY (module_id) REFERENCES module (id)
);

CREATE TABLE app_user (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL,
  username VARCHAR(80) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  last_access_at TIMESTAMP,
  is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_app_user_person UNIQUE (person_id),
  CONSTRAINT uk_app_user_username UNIQUE (username),
  CONSTRAINT fk_app_user_person FOREIGN KEY (person_id) REFERENCES person (id)
);

CREATE TABLE user_role (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  role_id UUID NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_user_role UNIQUE (user_id, role_id),
  CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES app_user (id),
  CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES app_role (id)
);

CREATE TABLE role_permission (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id UUID NOT NULL,
  permission_id UUID NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_role_permission UNIQUE (role_id, permission_id),
  CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES app_role (id),
  CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id) REFERENCES permission (id)
);

CREATE TABLE module_view (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL,
  view_id UUID NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_module_view UNIQUE (module_id, view_id),
  CONSTRAINT fk_module_view_module FOREIGN KEY (module_id) REFERENCES module (id),
  CONSTRAINT fk_module_view_view FOREIGN KEY (view_id) REFERENCES app_view (id)
);


-- Parameterization domain
CREATE TABLE customer (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_type VARCHAR(30) NOT NULL,
  document_number VARCHAR(40) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(40),
  email VARCHAR(160),
  address VARCHAR(255),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_customer_document UNIQUE (document_type, document_number),
  CONSTRAINT uk_customer_email UNIQUE (email)
);

CREATE TABLE company (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(160) NOT NULL,
  tax_id VARCHAR(40) NOT NULL,
  legal_name VARCHAR(180) NOT NULL,
  phone VARCHAR(40),
  email VARCHAR(160),
  address VARCHAR(255),
  website VARCHAR(180),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_company_tax_id UNIQUE (tax_id)
);

CREATE TABLE day_type (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) NOT NULL,
  description VARCHAR(255),
  date_value DATE,
  applies_season BOOLEAN NOT NULL DEFAULT FALSE,
  applies_holiday BOOLEAN NOT NULL DEFAULT FALSE,
  applies_special BOOLEAN NOT NULL DEFAULT FALSE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_day_type_name_date UNIQUE (name, date_value)
);

CREATE TABLE payment_method (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) NOT NULL,
  description VARCHAR(255),
  requires_reference BOOLEAN NOT NULL DEFAULT FALSE,
  allows_partial_payment BOOLEAN NOT NULL DEFAULT TRUE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_payment_method_name UNIQUE (name)
);

CREATE TABLE legal_information (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  legal_document_type VARCHAR(80) NOT NULL,
  legal_document_number VARCHAR(80) NOT NULL,
  description TEXT,
  issue_date DATE,
  expiration_date DATE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_legal_information_company FOREIGN KEY (company_id) REFERENCES company (id)
);

CREATE TABLE employee (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL,
  job_title VARCHAR(100) NOT NULL,
  hire_date DATE NOT NULL,
  work_phone VARCHAR(40),
  work_email VARCHAR(160),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_employee_person UNIQUE (person_id),
  CONSTRAINT uk_employee_work_email UNIQUE (work_email),
  CONSTRAINT fk_employee_person FOREIGN KEY (person_id) REFERENCES person (id)
);


-- Distribution domain
CREATE TABLE branch (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  name VARCHAR(160) NOT NULL,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(120) NOT NULL,
  phone VARCHAR(40),
  email VARCHAR(160),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_branch_company_name UNIQUE (company_id, name),
  CONSTRAINT fk_branch_company FOREIGN KEY (company_id) REFERENCES company (id)
);

CREATE TABLE room_type (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) NOT NULL,
  description VARCHAR(255),
  base_capacity SMALLINT NOT NULL,
  max_capacity SMALLINT NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_room_type_name UNIQUE (name),
  CONSTRAINT ck_room_type_capacity CHECK (max_capacity >= base_capacity)
);

CREATE TABLE room_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) NOT NULL,
  description VARCHAR(255),
  allows_reservation BOOLEAN NOT NULL DEFAULT FALSE,
  allows_check_in BOOLEAN NOT NULL DEFAULT FALSE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_room_status_name UNIQUE (name)
);

CREATE TABLE room (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID NOT NULL,
  room_type_id UUID NOT NULL,
  room_status_id UUID NOT NULL,
  room_number VARCHAR(20) NOT NULL,
  floor_number SMALLINT,
  capacity SMALLINT NOT NULL,
  description VARCHAR(255),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_room_branch_number UNIQUE (branch_id, room_number),
  CONSTRAINT fk_room_branch FOREIGN KEY (branch_id) REFERENCES branch (id),
  CONSTRAINT fk_room_type FOREIGN KEY (room_type_id) REFERENCES room_type (id),
  CONSTRAINT fk_room_status FOREIGN KEY (room_status_id) REFERENCES room_status (id)
);

CREATE TABLE rate (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_type_id UUID NOT NULL,
  day_type_id UUID NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  condition_note VARCHAR(255),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_rate_room_day_start UNIQUE (room_type_id, day_type_id, start_date),
  CONSTRAINT fk_rate_room_type FOREIGN KEY (room_type_id) REFERENCES room_type (id),
  CONSTRAINT fk_rate_day_type FOREIGN KEY (day_type_id) REFERENCES day_type (id),
  CONSTRAINT ck_rate_amount CHECK (amount >= 0)
);


-- Inventory domain
CREATE TABLE supplier (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(160) NOT NULL,
  tax_id VARCHAR(40),
  phone VARCHAR(40),
  email VARCHAR(160),
  address VARCHAR(255),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_supplier_tax_id UNIQUE (tax_id)
);

CREATE TABLE product (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id UUID,
  name VARCHAR(160) NOT NULL,
  description VARCHAR(255),
  sale_price NUMERIC(12,2) NOT NULL DEFAULT 0,
  current_stock INTEGER NOT NULL DEFAULT 0,
  minimum_stock INTEGER NOT NULL DEFAULT 0,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_product_name UNIQUE (name),
  CONSTRAINT fk_product_supplier FOREIGN KEY (supplier_id) REFERENCES supplier (id),
  CONSTRAINT ck_product_values CHECK (sale_price >= 0 AND current_stock >= 0 AND minimum_stock >= 0)
);

CREATE TABLE service (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(160) NOT NULL,
  description VARCHAR(255),
  sale_price NUMERIC(12,2) NOT NULL DEFAULT 0,
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_service_name UNIQUE (name),
  CONSTRAINT ck_service_sale_price CHECK (sale_price >= 0)
);

CREATE TABLE product_movement (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL,
  movement_type VARCHAR(40) NOT NULL,
  quantity INTEGER NOT NULL,
  moved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note TEXT,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_product_movement_product FOREIGN KEY (product_id) REFERENCES product (id),
  CONSTRAINT ck_product_movement_quantity CHECK (quantity > 0)
);

CREATE TABLE inventory_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID,
  service_id UUID,
  available_quantity INTEGER NOT NULL DEFAULT 0,
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  note VARCHAR(255),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_inventory_availability_product FOREIGN KEY (product_id) REFERENCES product (id),
  CONSTRAINT fk_inventory_availability_service FOREIGN KEY (service_id) REFERENCES service (id),
  CONSTRAINT ck_inventory_availability_item CHECK (product_id IS NOT NULL OR service_id IS NOT NULL),
  CONSTRAINT ck_inventory_availability_quantity CHECK (available_quantity >= 0)
);


-- Service delivery domain
CREATE TABLE room_reservation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  room_id UUID NOT NULL,
  start_at TIMESTAMP NOT NULL,
  end_at TIMESTAMP NOT NULL,
  guest_count SMALLINT NOT NULL,
  reservation_status VARCHAR(40) NOT NULL DEFAULT 'PENDING',
  estimated_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_room_reservation_customer FOREIGN KEY (customer_id) REFERENCES customer (id),
  CONSTRAINT fk_room_reservation_room FOREIGN KEY (room_id) REFERENCES room (id),
  CONSTRAINT ck_room_reservation_dates CHECK (end_at > start_at),
  CONSTRAINT ck_room_reservation_values CHECK (guest_count > 0 AND estimated_amount >= 0)
);

CREATE TABLE room_cancellation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_reservation_id UUID NOT NULL,
  reason VARCHAR(255) NOT NULL,
  cancelled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  applies_penalty BOOLEAN NOT NULL DEFAULT FALSE,
  penalty_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_room_cancellation_reservation UNIQUE (room_reservation_id),
  CONSTRAINT fk_room_cancellation_reservation FOREIGN KEY (room_reservation_id) REFERENCES room_reservation (id),
  CONSTRAINT ck_room_cancellation_penalty CHECK (penalty_amount >= 0)
);

CREATE TABLE room_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL,
  start_at TIMESTAMP NOT NULL,
  end_at TIMESTAMP NOT NULL,
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  unavailable_reason VARCHAR(255),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_room_availability_room FOREIGN KEY (room_id) REFERENCES room (id),
  CONSTRAINT ck_room_availability_dates CHECK (end_at > start_at)
);

CREATE TABLE room_catalog (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT,
  base_price NUMERIC(12,2) NOT NULL DEFAULT 0,
  is_visible BOOLEAN NOT NULL DEFAULT TRUE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_room_catalog_room UNIQUE (room_id),
  CONSTRAINT fk_room_catalog_room FOREIGN KEY (room_id) REFERENCES room (id),
  CONSTRAINT ck_room_catalog_base_price CHECK (base_price >= 0)
);

CREATE TABLE stay (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_reservation_id UUID NOT NULL,
  customer_id UUID NOT NULL,
  room_id UUID NOT NULL,
  start_at TIMESTAMP NOT NULL,
  end_at TIMESTAMP,
  stay_status VARCHAR(40) NOT NULL DEFAULT 'ACTIVE',
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_stay_reservation UNIQUE (room_reservation_id),
  CONSTRAINT fk_stay_reservation FOREIGN KEY (room_reservation_id) REFERENCES room_reservation (id),
  CONSTRAINT fk_stay_customer FOREIGN KEY (customer_id) REFERENCES customer (id),
  CONSTRAINT fk_stay_room FOREIGN KEY (room_id) REFERENCES room (id)
);

CREATE TABLE check_in (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_reservation_id UUID NOT NULL,
  employee_id UUID NOT NULL,
  checked_in_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note TEXT,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_check_in_reservation UNIQUE (room_reservation_id),
  CONSTRAINT fk_check_in_reservation FOREIGN KEY (room_reservation_id) REFERENCES room_reservation (id),
  CONSTRAINT fk_check_in_employee FOREIGN KEY (employee_id) REFERENCES employee (id)
);

CREATE TABLE check_out (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stay_id UUID NOT NULL,
  employee_id UUID NOT NULL,
  checked_out_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note TEXT,
  total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_check_out_stay UNIQUE (stay_id),
  CONSTRAINT fk_check_out_stay FOREIGN KEY (stay_id) REFERENCES stay (id),
  CONSTRAINT fk_check_out_employee FOREIGN KEY (employee_id) REFERENCES employee (id),
  CONSTRAINT ck_check_out_total_amount CHECK (total_amount >= 0)
);

CREATE TABLE product_sale (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stay_id UUID NOT NULL,
  product_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC(12,2) NOT NULL,
  total_amount NUMERIC(12,2) NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_product_sale_stay FOREIGN KEY (stay_id) REFERENCES stay (id),
  CONSTRAINT fk_product_sale_product FOREIGN KEY (product_id) REFERENCES product (id),
  CONSTRAINT ck_product_sale_values CHECK (quantity > 0 AND unit_price >= 0 AND total_amount >= 0)
);

CREATE TABLE service_sale (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stay_id UUID NOT NULL,
  service_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC(12,2) NOT NULL,
  total_amount NUMERIC(12,2) NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_service_sale_stay FOREIGN KEY (stay_id) REFERENCES stay (id),
  CONSTRAINT fk_service_sale_service FOREIGN KEY (service_id) REFERENCES service (id),
  CONSTRAINT ck_service_sale_values CHECK (quantity > 0 AND unit_price >= 0 AND total_amount >= 0)
);


-- Billing domain
CREATE TABLE proforma_invoice (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stay_id UUID NOT NULL,
  room_reservation_id UUID NOT NULL,
  customer_id UUID NOT NULL,
  subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
  tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_proforma_invoice_stay UNIQUE (stay_id),
  CONSTRAINT fk_proforma_invoice_stay FOREIGN KEY (stay_id) REFERENCES stay (id),
  CONSTRAINT fk_proforma_invoice_reservation FOREIGN KEY (room_reservation_id) REFERENCES room_reservation (id),
  CONSTRAINT fk_proforma_invoice_customer FOREIGN KEY (customer_id) REFERENCES customer (id),
  CONSTRAINT ck_proforma_invoice_values CHECK (subtotal >= 0 AND tax_amount >= 0 AND discount_amount >= 0 AND total_amount >= 0)
);

CREATE TABLE invoice (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  stay_id UUID NOT NULL,
  invoice_number VARCHAR(60) NOT NULL,
  issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
  tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  invoice_status VARCHAR(40) NOT NULL DEFAULT 'ISSUED',
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_invoice_number UNIQUE (invoice_number),
  CONSTRAINT uk_invoice_stay UNIQUE (stay_id),
  CONSTRAINT fk_invoice_customer FOREIGN KEY (customer_id) REFERENCES customer (id),
  CONSTRAINT fk_invoice_stay FOREIGN KEY (stay_id) REFERENCES stay (id),
  CONSTRAINT ck_invoice_values CHECK (subtotal >= 0 AND tax_amount >= 0 AND discount_amount >= 0 AND total_amount >= 0)
);

CREATE TABLE partial_payment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_reservation_id UUID,
  invoice_id UUID,
  payment_method_id UUID NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  payment_reference VARCHAR(120),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_partial_payment_reservation FOREIGN KEY (room_reservation_id) REFERENCES room_reservation (id),
  CONSTRAINT fk_partial_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoice (id),
  CONSTRAINT fk_partial_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_method (id),
  CONSTRAINT ck_partial_payment_amount CHECK (amount > 0),
  CONSTRAINT ck_partial_payment_source CHECK (room_reservation_id IS NOT NULL OR invoice_id IS NOT NULL)
);

CREATE TABLE invoice_detail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID NOT NULL,
  product_id UUID,
  service_id UUID,
  description VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC(12,2) NOT NULL,
  total_amount NUMERIC(12,2) NOT NULL,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_invoice_detail_invoice FOREIGN KEY (invoice_id) REFERENCES invoice (id),
  CONSTRAINT fk_invoice_detail_product FOREIGN KEY (product_id) REFERENCES product (id),
  CONSTRAINT fk_invoice_detail_service FOREIGN KEY (service_id) REFERENCES service (id),
  CONSTRAINT ck_invoice_detail_values CHECK (quantity > 0 AND unit_price >= 0 AND total_amount >= 0),
  CONSTRAINT ck_invoice_detail_item CHECK (product_id IS NOT NULL OR service_id IS NOT NULL)
);


-- Notification domain
CREATE TABLE promotion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(160) NOT NULL,
  description TEXT,
  start_at TIMESTAMP NOT NULL,
  end_at TIMESTAMP,
  channel VARCHAR(60) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE alert (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID,
  room_reservation_id UUID,
  title VARCHAR(160) NOT NULL,
  message TEXT NOT NULL,
  channel VARCHAR(60) NOT NULL,
  sent_at TIMESTAMP,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_alert_customer FOREIGN KEY (customer_id) REFERENCES customer (id),
  CONSTRAINT fk_alert_reservation FOREIGN KEY (room_reservation_id) REFERENCES room_reservation (id)
);

CREATE TABLE term_condition (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(160) NOT NULL,
  content TEXT NOT NULL,
  version VARCHAR(40) NOT NULL,
  effective_date DATE NOT NULL,
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_term_condition_version UNIQUE (version)
);

CREATE TABLE customer_loyalty (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  level VARCHAR(60) NOT NULL DEFAULT 'BASIC',
  points INTEGER NOT NULL DEFAULT 0,
  last_interaction_at TIMESTAMP,
  note TEXT,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_customer_loyalty_customer UNIQUE (customer_id),
  CONSTRAINT fk_customer_loyalty_customer FOREIGN KEY (customer_id) REFERENCES customer (id),
  CONSTRAINT ck_customer_loyalty_points CHECK (points >= 0)
);


-- Maintenance domain
CREATE TABLE room_maintenance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL,
  employee_id UUID,
  maintenance_type VARCHAR(60) NOT NULL,
  start_at TIMESTAMP NOT NULL,
  end_at TIMESTAMP,
  maintenance_status VARCHAR(40) NOT NULL DEFAULT 'PENDING',
  note TEXT,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_room_maintenance_room FOREIGN KEY (room_id) REFERENCES room (id),
  CONSTRAINT fk_room_maintenance_employee FOREIGN KEY (employee_id) REFERENCES employee (id)
);

CREATE TABLE usage_maintenance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_maintenance_id UUID NOT NULL,
  usage_reason VARCHAR(160) NOT NULL,
  activity_detail TEXT,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_usage_maintenance_base UNIQUE (room_maintenance_id),
  CONSTRAINT fk_usage_maintenance_base FOREIGN KEY (room_maintenance_id) REFERENCES room_maintenance (id)
);

CREATE TABLE remodeling_maintenance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_maintenance_id UUID NOT NULL,
  remodeling_description TEXT NOT NULL,
  estimated_budget NUMERIC(12,2),
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT uk_remodeling_maintenance_base UNIQUE (room_maintenance_id),
  CONSTRAINT fk_remodeling_maintenance_base FOREIGN KEY (room_maintenance_id) REFERENCES room_maintenance (id),
  CONSTRAINT ck_remodeling_maintenance_budget CHECK (estimated_budget IS NULL OR estimated_budget >= 0)
);

CREATE TABLE maintenance_dashboard (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID NOT NULL,
  total_rooms INTEGER NOT NULL DEFAULT 0,
  available_rooms INTEGER NOT NULL DEFAULT 0,
  occupied_rooms INTEGER NOT NULL DEFAULT 0,
  maintenance_rooms INTEGER NOT NULL DEFAULT 0,
  cutoff_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID,
  updated_at TIMESTAMP,
  deleted_by UUID,
  deleted_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_maintenance_dashboard_branch FOREIGN KEY (branch_id) REFERENCES branch (id),
  CONSTRAINT ck_maintenance_dashboard_totals CHECK (
    total_rooms >= 0
    AND available_rooms >= 0
    AND occupied_rooms >= 0
    AND maintenance_rooms >= 0
  )
);

-- Parameterization domain indexes
CREATE INDEX ix_legal_information_company ON legal_information (company_id);

-- Distribution domain indexes
CREATE INDEX ix_room_type ON room (room_type_id);
CREATE INDEX ix_room_status ON room (room_status_id);
CREATE INDEX ix_rate_room_type ON rate (room_type_id);
CREATE INDEX ix_rate_day_type ON rate (day_type_id);

-- Service delivery domain indexes
CREATE INDEX ix_room_reservation_customer ON room_reservation (customer_id);
CREATE INDEX ix_room_reservation_room_dates ON room_reservation (room_id, start_at, end_at);
CREATE INDEX ix_room_availability_room_dates ON room_availability (room_id, start_at, end_at);
CREATE INDEX ix_stay_customer ON stay (customer_id);
CREATE INDEX ix_stay_room ON stay (room_id);
CREATE INDEX ix_check_in_employee ON check_in (employee_id);
CREATE INDEX ix_check_out_employee ON check_out (employee_id);
CREATE INDEX ix_product_sale_stay ON product_sale (stay_id);
CREATE INDEX ix_product_sale_product ON product_sale (product_id);
CREATE INDEX ix_service_sale_stay ON service_sale (stay_id);
CREATE INDEX ix_service_sale_service ON service_sale (service_id);

-- Inventory domain indexes
CREATE INDEX ix_product_supplier ON product (supplier_id);
CREATE INDEX ix_product_movement_product_date ON product_movement (product_id, moved_at);
CREATE INDEX ix_inventory_availability_product ON inventory_availability (product_id);
CREATE INDEX ix_inventory_availability_service ON inventory_availability (service_id);

-- Billing domain indexes
CREATE INDEX ix_proforma_invoice_reservation ON proforma_invoice (room_reservation_id);
CREATE INDEX ix_proforma_invoice_customer ON proforma_invoice (customer_id);
CREATE INDEX ix_invoice_customer ON invoice (customer_id);
CREATE INDEX ix_partial_payment_reservation ON partial_payment (room_reservation_id);
CREATE INDEX ix_partial_payment_invoice ON partial_payment (invoice_id);
CREATE INDEX ix_partial_payment_method ON partial_payment (payment_method_id);
CREATE INDEX ix_invoice_detail_invoice ON invoice_detail (invoice_id);
CREATE INDEX ix_invoice_detail_product ON invoice_detail (product_id);
CREATE INDEX ix_invoice_detail_service ON invoice_detail (service_id);

-- Notification domain indexes
CREATE INDEX ix_promotion_dates ON promotion (start_at, end_at);
CREATE INDEX ix_alert_customer ON alert (customer_id);
CREATE INDEX ix_alert_reservation ON alert (room_reservation_id);

-- Maintenance domain indexes
CREATE INDEX ix_room_maintenance_room_dates ON room_maintenance (room_id, start_at, end_at);
CREATE INDEX ix_room_maintenance_employee ON room_maintenance (employee_id);
CREATE INDEX ix_maintenance_dashboard_branch_cutoff ON maintenance_dashboard (branch_id, cutoff_at);

