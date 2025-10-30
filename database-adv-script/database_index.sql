-- ==========================================================
-- Airbnb Clone — Task 3: Implement Indexes for Optimization
-- ==========================================================

-- Create indexes on frequently used columns
CREATE INDEX idx_booking_user_id ON booking(user_id);
CREATE INDEX idx_booking_property_id ON booking(property_id);
CREATE INDEX idx_review_property_id ON review(property_id);
CREATE INDEX idx_payment_booking_id ON payment(booking_id);
CREATE INDEX idx_property_host_id ON property(host_id);

-- Composite index for date range searches (performance boost)
CREATE INDEX idx_booking_property_dates ON booking(property_id, start_date, end_date);

-- Optional partial index for active listings only
CREATE INDEX idx_property_active_true ON property(property_id)
WHERE is_active = TRUE;

-- Measure query performance before and after adding indexes
EXPLAIN ANALYZE
SELECT u.user_id, COUNT(b.booking_id)
FROM app_user u
LEFT JOIN booking b ON b.user_id = u.user_id
GROUP BY u.user_id;
