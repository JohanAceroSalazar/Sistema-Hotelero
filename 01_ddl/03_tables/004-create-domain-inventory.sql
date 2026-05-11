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