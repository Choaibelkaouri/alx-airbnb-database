# Seed the Database with Sample Data — ALX Airbnb Database

This folder contains SQL to populate the database with realistic sample data.

## Files
- `seed.sql` — Inserts users, properties, images, amenities, property_amenities, bookings, payments, reviews, messages, wishlists, and wishlist_items.

## Prerequisites
- PostgreSQL 13+
- The schema from `database-script-0x01/schema.sql` is already applied.
- Uses the `airbnb` schema via `SET search_path`.

## How to Run
```bash
# assuming the database exists and schema is loaded
psql -d alx_airbnb -f database-script-0x02/seed.sql