-- ==========================================================
-- Task 5 — Partitioning Large Tables (PostgreSQL)
-- ==========================================================

-- Drop any existing partitioned version (optional for rerun)
DROP TABLE IF EXISTS booking_p CASCADE;

-- ✅ Create the partitioned table by RANGE on start_date
CREATE TABLE booking_p (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_price DECIMAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (start_date);

-- ✅ Create partitions by year or quarter (example yearly)
CREATE TABLE booking_p_2024 PARTITION OF booking_p
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE booking_p_2025 PARTITION OF booking_p
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- ✅ Default partition to capture out-of-range rows
CREATE TABLE booking_p_default PARTITION OF booking_p DEFAULT;

-- ✅ Example index on date & property for better performance
CREATE INDEX idx_booking_p_property_dates
    ON booking_p (property_id, start_date, end_date);

-- ✅ Example test query to verify partition pruning
EXPLAIN ANALYZE
SELECT booking_id, property_id, start_date, end_date
FROM booking_p
WHERE start_date >= DATE '2025-07-01'
  AND start_date <  DATE '2025-10-01';

---

## `database-adv-script/perfomance.sql`

```sql
-- ==========================================================
-- Task 4 — Optimize Complex Queries (PostgreSQL)
-- Files: perfomance.sql (this), optimization_report.md
-- ==========================================================
-- Tables used:
--   app_user(user_id, first_name, last_name, ...)
--   property(property_id, host_id, name, ...)
--   booking(booking_id, property_id, user_id, start_date, end_date, status, ...)
--   payment(payment_id, booking_id, amount, currency, status, payment_date, ...)
-- ==========================================================


/****************************************************************
 A. BASELINE (BEFORE)
  - Direct LEFT JOIN to payment → multiple rows per booking.
  - No date filtering.
  - Use this block with EXPLAIN ANALYZE to capture baseline.
*****************************************************************/
-- EXPLAIN ANALYZE
SELECT
  b.booking_id,
  b.start_date,
  b.end_date,
  b.status              AS booking_status,

  u.user_id             AS user_id,
  u.first_name          AS user_first_name,
  u.last_name           AS user_last_name,

  p.property_id         AS property_id,
  p.name                AS property_name,

  pay.payment_id        AS payment_id,
  pay.amount            AS payment_amount,
  pay.currency          AS payment_currency,
  pay.status            AS payment_status,
  pay.payment_date      AS payment_date
FROM booking  AS b
LEFT JOIN app_user AS u
  ON u.user_id = b.user_id
LEFT JOIN property AS p
  ON p.property_id = b.property_id
LEFT JOIN payment  AS pay
  ON pay.booking_id = b.booking_id
ORDER BY b.start_date DESC;
/* Issues:
   - Row multiplication for bookings with multiple payments.
   - Big sort; potential seq scans if indexes/filters absent.
*/


/****************************************************************
 B. OPTIMIZED (AFTER)
  Strategy:
   1) Keep one row per booking using LATERAL to fetch the latest payment.
   2) Allow optional date filter to reduce scanned rows.
   3) Select only necessary columns.
*****************************************************************/

-- Suggested supporting indexes:
-- CREATE INDEX IF NOT EXISTS idx_booking_user_id       ON booking(user_id);
-- CREATE INDEX IF NOT EXISTS idx_booking_property_id   ON booking(property_id);
-- CREATE INDEX IF NOT EXISTS idx_booking_prop_dates    ON booking(property_id, start_date, end_date);
-- CREATE INDEX IF NOT EXISTS idx_payment_booking_date  ON payment(booking_id, payment_date DESC);

-- Optional date filters for benchmarking (uncomment to use):
-- WHERE b.start_date >= DATE '2025-08-01' AND b.start_date < DATE '2025-11-01'

-- EXPLAIN ANALYZE
WITH filtered_bookings AS (
  SELECT b.booking_id, b.user_id, b.property_id, b.start_date, b.end_date, b.status
  FROM booking b
  -- Uncomment for range-benchmark:
  -- WHERE b.start_date >= DATE '2025-08-01'
  --   AND b.start_date <  DATE '2025-11-01'
)
SELECT
  fb.booking_id,
  fb.start_date,
  fb.end_date,
  fb.status               AS booking_status,

  u.user_id               AS user_id,
  u.first_name            AS user_first_name,
  u.last_name             AS user_last_name,

  pr.property_id          AS property_id,
  pr.name                 AS property_name,

  lp.payment_id,
  lp.amount               AS payment_amount,
  lp.currency             AS payment_currency,
  lp.status               AS payment_status,
  lp.payment_date
FROM filtered_bookings AS fb
LEFT JOIN app_user AS u
  ON u.user_id = fb.user_id
LEFT JOIN property AS pr
  ON pr.property_id = fb.property_id
LEFT JOIN LATERAL (
  SELECT pmt.payment_id, pmt.amount, pmt.currency, pmt.status, pmt.payment_date
  FROM payment pmt
  WHERE pmt.booking_id = fb.booking_id
  ORDER BY pmt.payment_date DESC
  LIMIT 1
) AS lp ON TRUE
ORDER BY fb.start_date DESC;
/* Benefits:
   - One row per booking (latest payment only).
   - LATERAL leverages (booking_id, payment_date) index.
   - Date filter (when applied) shrinks scanned rows dramatically.
*/
