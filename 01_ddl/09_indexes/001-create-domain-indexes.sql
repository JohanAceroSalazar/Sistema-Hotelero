-- =====================================================
-- INDEXES FOR ALL TABLES
-- =====================================================

-- =====================================================
-- SECURITY DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_person_status_created_at
ON person (status, created_at);

CREATE INDEX IF NOT EXISTS idx_person_last_name_first_name
ON person (last_name, first_name);

CREATE INDEX IF NOT EXISTS idx_app_role_status_name
ON app_role (status, name);

CREATE INDEX IF NOT EXISTS idx_permission_status_action
ON permission (status, action);

CREATE INDEX IF NOT EXISTS idx_module_status_name
ON module (status, name);

CREATE INDEX IF NOT EXISTS idx_app_view_module_id
ON app_view (module_id);

CREATE INDEX IF NOT EXISTS idx_app_view_status_name
ON app_view (status, name);

CREATE INDEX IF NOT EXISTS idx_app_user_status_blocked
ON app_user (status, is_blocked);

CREATE INDEX IF NOT EXISTS idx_app_user_last_access_at
ON app_user (last_access_at);

CREATE INDEX IF NOT EXISTS idx_user_role_user_id
ON user_role (user_id);

CREATE INDEX IF NOT EXISTS idx_user_role_role_id
ON user_role (role_id);

CREATE INDEX IF NOT EXISTS idx_role_permission_role_id
ON role_permission (role_id);

CREATE INDEX IF NOT EXISTS idx_role_permission_permission_id
ON role_permission (permission_id);

CREATE INDEX IF NOT EXISTS idx_module_view_module_id
ON module_view (module_id);

CREATE INDEX IF NOT EXISTS idx_module_view_view_id
ON module_view (view_id);

-- =====================================================
-- PARAMETERIZATION DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_customer_status_last_name
ON customer (status, last_name);

CREATE INDEX IF NOT EXISTS idx_customer_phone
ON customer (phone);

CREATE INDEX IF NOT EXISTS idx_company_status_name
ON company (status, name);

CREATE INDEX IF NOT EXISTS idx_day_type_status_date_value
ON day_type (status, date_value);

CREATE INDEX IF NOT EXISTS idx_payment_method_status_name
ON payment_method (status, name);

CREATE INDEX IF NOT EXISTS idx_legal_information_company_id
ON legal_information (company_id);

CREATE INDEX IF NOT EXISTS idx_legal_information_expiration_date
ON legal_information (expiration_date);

CREATE INDEX IF NOT EXISTS idx_employee_person_id
ON employee (person_id);

CREATE INDEX IF NOT EXISTS idx_employee_status_job_title
ON employee (status, job_title);

-- =====================================================
-- DISTRIBUTION DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_branch_company_id
ON branch (company_id);

CREATE INDEX IF NOT EXISTS idx_branch_city_status
ON branch (city, status);

CREATE INDEX IF NOT EXISTS idx_room_type_status_name
ON room_type (status, name);

CREATE INDEX IF NOT EXISTS idx_room_status_status_name
ON room_status (status, name);

CREATE INDEX IF NOT EXISTS idx_room_branch_status
ON room (branch_id, room_status_id);

CREATE INDEX IF NOT EXISTS idx_room_type_id
ON room (room_type_id);

CREATE INDEX IF NOT EXISTS idx_room_status_id
ON room (room_status_id);

CREATE INDEX IF NOT EXISTS idx_rate_room_type_day_type_dates
ON rate (room_type_id, day_type_id, start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_rate_day_type_id
ON rate (day_type_id);

-- =====================================================
-- INVENTORY DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_supplier_status_name
ON supplier (status, name);

CREATE INDEX IF NOT EXISTS idx_product_supplier_stock
ON product (supplier_id, current_stock);

CREATE INDEX IF NOT EXISTS idx_product_status_name
ON product (status, name);

CREATE INDEX IF NOT EXISTS idx_product_minimum_stock
ON product (minimum_stock, current_stock);

CREATE INDEX IF NOT EXISTS idx_service_status_available
ON service (status, is_available);

CREATE INDEX IF NOT EXISTS idx_service_name
ON service (name);

CREATE INDEX IF NOT EXISTS idx_product_movement_product_moved_at
ON product_movement (product_id, moved_at);

CREATE INDEX IF NOT EXISTS idx_product_movement_type
ON product_movement (movement_type);

CREATE INDEX IF NOT EXISTS idx_inventory_availability_product_id
ON inventory_availability (product_id);

CREATE INDEX IF NOT EXISTS idx_inventory_availability_service_id
ON inventory_availability (service_id);

CREATE INDEX IF NOT EXISTS idx_inventory_availability_available
ON inventory_availability (is_available, available_quantity);

-- =====================================================
-- SERVICE DELIVERY DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_room_reservation_customer_id
ON room_reservation (customer_id);

CREATE INDEX IF NOT EXISTS idx_room_reservation_room_dates
ON room_reservation (room_id, start_at, end_at);

CREATE INDEX IF NOT EXISTS idx_room_reservation_status
ON room_reservation (reservation_status, status);

CREATE INDEX IF NOT EXISTS idx_room_cancellation_reservation_id
ON room_cancellation (room_reservation_id);

CREATE INDEX IF NOT EXISTS idx_room_cancellation_cancelled_at
ON room_cancellation (cancelled_at);

CREATE INDEX IF NOT EXISTS idx_room_availability_room_dates
ON room_availability (room_id, start_at, end_at);

CREATE INDEX IF NOT EXISTS idx_room_availability_available
ON room_availability (is_available);

CREATE INDEX IF NOT EXISTS idx_room_catalog_room_id
ON room_catalog (room_id);

CREATE INDEX IF NOT EXISTS idx_room_catalog_visible
ON room_catalog (is_visible, status);

CREATE INDEX IF NOT EXISTS idx_stay_reservation_id
ON stay (room_reservation_id);

CREATE INDEX IF NOT EXISTS idx_stay_customer_status
ON stay (customer_id, stay_status);

CREATE INDEX IF NOT EXISTS idx_stay_room_dates
ON stay (room_id, start_at, end_at);

CREATE INDEX IF NOT EXISTS idx_check_in_reservation_id
ON check_in (room_reservation_id);

CREATE INDEX IF NOT EXISTS idx_check_in_employee_id
ON check_in (employee_id);

CREATE INDEX IF NOT EXISTS idx_check_in_checked_in_at
ON check_in (checked_in_at);

CREATE INDEX IF NOT EXISTS idx_check_out_stay_id
ON check_out (stay_id);

CREATE INDEX IF NOT EXISTS idx_check_out_employee_id
ON check_out (employee_id);

CREATE INDEX IF NOT EXISTS idx_check_out_checked_out_at
ON check_out (checked_out_at);

CREATE INDEX IF NOT EXISTS idx_product_sale_stay_id
ON product_sale (stay_id);

CREATE INDEX IF NOT EXISTS idx_product_sale_product_id
ON product_sale (product_id);

CREATE INDEX IF NOT EXISTS idx_service_sale_stay_id
ON service_sale (stay_id);

CREATE INDEX IF NOT EXISTS idx_service_sale_service_id
ON service_sale (service_id);

-- =====================================================
-- BILLING DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_proforma_invoice_stay_id
ON proforma_invoice (stay_id);

CREATE INDEX IF NOT EXISTS idx_proforma_invoice_reservation_id
ON proforma_invoice (room_reservation_id);

CREATE INDEX IF NOT EXISTS idx_proforma_invoice_customer_id
ON proforma_invoice (customer_id);

CREATE INDEX IF NOT EXISTS idx_invoice_customer_issued_at
ON invoice (customer_id, issued_at);

CREATE INDEX IF NOT EXISTS idx_invoice_stay_id
ON invoice (stay_id);

CREATE INDEX IF NOT EXISTS idx_invoice_status
ON invoice (invoice_status, status);

CREATE INDEX IF NOT EXISTS idx_partial_payment_reservation_id
ON partial_payment (room_reservation_id);

CREATE INDEX IF NOT EXISTS idx_partial_payment_invoice_paid_at
ON partial_payment (invoice_id, paid_at);

CREATE INDEX IF NOT EXISTS idx_partial_payment_method_id
ON partial_payment (payment_method_id);

CREATE INDEX IF NOT EXISTS idx_invoice_detail_invoice_id
ON invoice_detail (invoice_id);

CREATE INDEX IF NOT EXISTS idx_invoice_detail_product_id
ON invoice_detail (product_id);

CREATE INDEX IF NOT EXISTS idx_invoice_detail_service_id
ON invoice_detail (service_id);

-- =====================================================
-- NOTIFICATION DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_promotion_channel_dates
ON promotion (channel, start_at, end_at);

CREATE INDEX IF NOT EXISTS idx_promotion_active_status
ON promotion (is_active, status);

CREATE INDEX IF NOT EXISTS idx_alert_customer_sent_at
ON alert (customer_id, sent_at);

CREATE INDEX IF NOT EXISTS idx_alert_reservation_id
ON alert (room_reservation_id);

CREATE INDEX IF NOT EXISTS idx_alert_channel_status
ON alert (channel, status);

CREATE INDEX IF NOT EXISTS idx_term_condition_effective_date
ON term_condition (effective_date);

CREATE INDEX IF NOT EXISTS idx_term_condition_required_status
ON term_condition (is_required, status);

CREATE INDEX IF NOT EXISTS idx_customer_loyalty_customer_id
ON customer_loyalty (customer_id);

CREATE INDEX IF NOT EXISTS idx_customer_loyalty_level_points
ON customer_loyalty (level, points);

-- =====================================================
-- MAINTENANCE DOMAIN
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_room_maintenance_room_status
ON room_maintenance (room_id, maintenance_status);

CREATE INDEX IF NOT EXISTS idx_room_maintenance_employee_id
ON room_maintenance (employee_id);

CREATE INDEX IF NOT EXISTS idx_room_maintenance_dates
ON room_maintenance (start_at, end_at);

CREATE INDEX IF NOT EXISTS idx_usage_maintenance_base_id
ON usage_maintenance (room_maintenance_id);

CREATE INDEX IF NOT EXISTS idx_usage_maintenance_status
ON usage_maintenance (status);

CREATE INDEX IF NOT EXISTS idx_remodeling_maintenance_base_id
ON remodeling_maintenance (room_maintenance_id);

CREATE INDEX IF NOT EXISTS idx_remodeling_maintenance_budget
ON remodeling_maintenance (estimated_budget);

CREATE INDEX IF NOT EXISTS idx_maintenance_dashboard_branch_cutoff
ON maintenance_dashboard (branch_id, cutoff_at);

CREATE INDEX IF NOT EXISTS idx_maintenance_dashboard_status
ON maintenance_dashboard (status);