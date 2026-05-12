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