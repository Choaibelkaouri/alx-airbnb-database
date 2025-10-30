# Task 6 — Monitor and Refine Database Performance (PostgreSQL)

**Repo:** `alx-airbnb-database`  
**Directory:** `database-adv-script/`  
**File:** `performance_monitoring.md`  
**Status:** Mandatory

## 🎯 Objective
Continuously monitor and refine database performance using `EXPLAIN` / `EXPLAIN ANALYZE`, identify bottlenecks, implement changes (indexes or schema tweaks), and report improvements.

---

## 1) Environment & Tools
- PostgreSQL
- `EXPLAIN` / `EXPLAIN ANALYZE`
- (Optional) `pg_stat_statements` for top query tracking:
  ```sql
  CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
  SELECT query, calls, mean_exec_time, rows
  FROM pg_stat_statements
  ORDER BY mean_exec_time DESC
  LIMIT 10;

