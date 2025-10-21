# Database Schema (DDL) — ALX Airbnb Database

## Files
- `schema.sql` — PostgreSQL DDL: tables, constraints, and indexes for the Airbnb-like system.

## Requirements Covered
- Proper data types and primary keys per entity.
- Foreign keys with clear ON DELETE behavior.
- Uniqueness and check constraints for data integrity.
- Performance indexes for common query paths.

## Assumptions
- PostgreSQL 13+.
- Schema created under `airbnb` and set via `SET search_path`.

## How to Run
```bash
# 1) create db (if not exists)
createdb alx_airbnb

# 2) apply schema
psql -d alx_airbnb -f database-script-0x01/schema.sql