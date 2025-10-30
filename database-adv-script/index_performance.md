
-- ==========================================================
-- Airbnb Clone — Task 3: Indexes for Optimization (PostgreSQL)
-- ==========================================================

-- 0) Safety: create schema-only if exists (optional)
-- SET search_path TO public;

-- 1) Joins / lookups
CREATE INDEX IF NOT EXISTS idx_booking_user_id
  ON booking(user_id);

CREATE INDEX IF NOT EXISTS idx_booking_property_id
  ON booking(property_id);

CREATE INDEX IF NOT EXISTS idx_review_property_id
  ON review(property_id);

CREATE INDEX IF NOT EXISTS idx_payment_booking_id
  ON payment(booking_id);

CREATE INDEX IF NOT EXISTS idx_property_host_id
  ON property(host_id);

-- 2) Search / filtering
-- Composite for calendar queries (range by dates within a property)
CREATE INDEX IF NOT EXISTS idx_booking_prop_dates
  ON booking(property_id, start_date, end_date);

-- Partial index for active listings only (speeds up typical search)
CREATE INDEX IF NOT EXISTS idx_property_active_true
  ON property(property_id)
  WHERE is_active = TRUE;

-- 3) Geo (optional; requires PostGIS)
-- CREATE EXTENSION IF NOT EXISTS postgis;
-- CREATE INDEX IF NOT EXISTS idx_property_geo_gist
--   ON property USING GIST (geo);

-- 4) Case-insensitive email lookup (if you DON'T use CITEXT)
-- CREATE INDEX IF NOT EXISTS idx_user_lower_email
--   ON app_user (LOWER(email));

-- Notes:
-- - تجنب الإفراط في الإندكسات (تكلفة الكتابة ترتفع).
-- - راقب الاستعمال الفعلي عبر pg_stat_statements (إن توفر).
-- - أعد بناء الإندكسات إذا تغير نمط الاستعلامات.
