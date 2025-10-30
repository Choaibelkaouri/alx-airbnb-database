-- ==========================================================
-- Airbnb Clone — Task 1: Practice Subqueries
-- Author: Your Name
-- Date: October 2025
-- ==========================================================

/*
🎯 Objective:
  1. Write a non-correlated subquery to find all properties
     where the average rating is greater than 4.0.
  2. Write a correlated subquery to find users who have
     made more than 3 bookings.
*/

-- ==========================================================
-- 1️⃣ Non-Correlated Subquery
--    Find properties where the average rating > 4.0
-- ==========================================================

SELECT
    p.property_id,
    p.name AS property_name,
    ROUND((
        SELECT AVG(r.rating)
        FROM review r
        WHERE r.property_id = p.property_id
    ), 2) AS average_rating
FROM property p
WHERE (
    SELECT AVG(r.rating)
    FROM review r
    WHERE r.property_id = p.property_id
) > 4.0
ORDER BY average_rating DESC NULLS LAST;

-- Explanation:
-- - The inner query calculates the average rating per property.
-- - The outer query filters only those with avg > 4.0.
-- - Works even if some properties have no reviews (NULL excluded).

-- ==========================================================
-- 2️⃣ Correlated Subquery
--    Find users who have made more than 3 bookings
-- ==========================================================

SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    (
        SELECT COUNT(*)
        FROM booking b
        WHERE b.user_id = u.user_id
    ) AS total_bookings
FROM app_user u
WHERE (
    SELECT COUNT(*)
    FROM booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY total_bookings DESC, u.last_name;

-- Explanation:
-- - The subquery depends on each user row (correlated).
-- - Counts bookings for each user.
-- - Filters users with total_bookings > 3.
-- ==========================================================
-- ✅ Verification:
-- Run each query individually and inspect results.
-- Optionally use:
-- EXPLAIN ANALYZE <query>;
-- to check performance and confirm correct joins/indexes.
-- ==========================================================
