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