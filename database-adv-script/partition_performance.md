# Task 5 — Partitioning Large Tables (PostgreSQL)

**Directory:** `database-adv-script/`  
**Files:** `partitioning.sql`, `partition_performance.md`  
**Status:** Mandatory

## 🎯 Objective
Partition the `booking` table by `start_date` to improve performance of date-range queries and property calendars.

---

## 🛠️ What I Implemented
- **RANGE partitioning** by `start_date`, with **quarterly partitions** for 2024–2025 plus a **DEFAULT** partition.
- Global indexes on the partitioned parent:
  - `(property_id, start_date, end_date)` — property calendar
  - `(user_id)` — user history
  - `(start_date)` — partition pruning + range scans
- **Safe migration**: created `booking_p`, copied data, then renamed to `booking`.

See `partitioning.sql` for the exact DDL.

---

## 🔎 Queries Used for Measurement
I measured before/after with `EXPLAIN ANALYZE` using:

```sql
-- 1) Date-range scan (typical availability/reporting)
EXPLAIN ANALYZE
SELECT booking_id, property_id, user_id, start_date, end_date, status
FROM booking
WHERE start_date >= DATE '2025-07-01'
  AND start_date <  DATE '2025-10-01'
ORDER BY start_date;

-- 2) Property calendar
EXPLAIN ANALYZE
SELECT booking_id, start_date, end_date
FROM booking
WHERE property_id = $1
  AND start_date <  $to
  AND end_date   >  $from
ORDER BY start_date;

-- 3) User history
EXPLAIN ANALYZE
SELECT booking_id, start_date, end_date, status
FROM booking
WHERE user_id = $user
ORDER BY start_date DESC;

