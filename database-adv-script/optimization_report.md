# Task 4 — Optimize Complex Queries (PostgreSQL)

**Files:** `optimization_report.md`, `perfomance.sql`  
**Directory:** `database-adv-script/`

## 1) Objective
Refactor a complex query that returns **bookings + user + property + payment** details to reduce execution time.

---

## 2) Baseline (Before)
**Query:** see section **A. BASELINE** in `perfomance.sql`.

**Observed with `EXPLAIN ANALYZE`:**
- Row explosion when a booking has multiple payments (1→N join).
- Large scans (no date filter).
- Sort on a big result set.

---

## 3) Indexes considered
```sql
CREATE INDEX IF NOT EXISTS idx_booking_user_id       ON booking(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_property_id   ON booking(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_prop_dates    ON booking(property_id, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_payment_booking_date  ON payment(booking_id, payment_date DESC);
