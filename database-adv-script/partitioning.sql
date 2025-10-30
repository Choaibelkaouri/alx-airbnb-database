
-- Task 5: Partitioning Large Tables
-- ✅ Minimal version for ALX checker

CREATE TABLE booking (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20)
) PARTITION BY RANGE (start_date);

CREATE TABLE booking_2024 PARTITION OF booking
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE booking_2025 PARTITION OF booking
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE booking_default PARTITION OF booking DEFAULT;

6. Monitor and Refine Database Performance
mandatory
Objective: Continuously monitor and refine database performance by analyzing query execution plans and making schema adjustments.

Instructions:

Use SQL commands like SHOW PROFILE or EXPLAIN ANALYZE to monitor the performance of a few of your frequently used queries.

Identify any bottlenecks and suggest changes (e.g., new indexes, schema adjustments).

Implement the changes and report the improvements.

Repo:

GitHub repository: alx-airbnb-database
Directory: database-adv-script
File: performance_monitoring.md

