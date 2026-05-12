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