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