-- ==========================================================
-- Airbnb Clone — Task 2: Apply Aggregations and Window Functions
-- Author: Your Name
-- Date: October 2025
-- ==========================================================

/*
🎯 Objectives:
  1. Calculate total number of bookings made by each user.
  2. Rank properties based on their total bookings using window functions.
*/

-- ==========================================================
-- 1️⃣ Aggregation Query
-- Find total number of bookings made by each user
-- ==========================================================

SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings
FROM app_user AS u
LEFT JOIN booking AS b
    ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC, u.last_name;

-- Explanation:
-- - LEFT JOIN ensures even users with zero bookings appear.
-- - COUNT() aggregates booking_id occurrences per user.
-- - GROUP BY is applied to all non-aggregated fields.
-- - ORDER BY ranks users by booking volume.


-- ==========================================================
-- 2️⃣ Window Function Query
-- Rank properties based on number of bookings received
-- ==========================================================

SELECT
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM property AS p
LEFT JOIN booking AS b
    ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_rank, property_name;

-- Explanation:
-- - COUNT() groups total bookings per property.
-- - RANK() assigns ranking (ties get same rank).
-- - You can replace RANK() with:
--       ROW_NUMBER()  -> unique ranks
--       DENSE_RANK()  -> no gaps in ranking numbers
-- - Results sorted by booking rank ascending.


-- ==========================================================
-- ✅ Verification Tips
-- Run these commands to inspect performance:
--     EXPLAIN ANALYZE <query>;
--     CREATE INDEX idx_booking_property_id ON booking(property_id);
-- Test ranking updates automatically after inserting new bookings.
-- ==========================================================
