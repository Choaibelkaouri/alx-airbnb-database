
```sql
-- ==========================================================
-- Airbnb Clone — Task 0: Complex Queries with Joins
-- ==========================================================

-- INNER JOIN:
-- Retrieve all bookings and the respective users who made those bookings.
SELECT
    b.booking_id,
    b.property_id,
    b.user_id,
    u.first_name,
    u.last_name,
    b.start_date,
    b.end_date,
    b.status
FROM booking AS b
INNER JOIN app_user AS u
    ON b.user_id = u.user_id
ORDER BY b.start_date DESC;

-- ==========================================================
-- LEFT JOIN:
-- Retrieve all properties and their reviews, including properties with no reviews.
SELECT
    p.property_id,
    p.name AS property_name,
    r.review_id,
    r.rating,
    r.comment
FROM property AS p
LEFT JOIN review AS r
    ON p.property_id = r.property_id
ORDER BY p.property_id;

-- ==========================================================
-- FULL OUTER JOIN:
-- Retrieve all users and all bookings,
-- even if the user has no booking or a booking has no linked user.
SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.property_id,
    b.status,
    b.start_date,
    b.end_date
FROM app_user AS u
FULL OUTER JOIN booking AS b
    ON u.user_id = b.user_id
ORDER BY COALESCE(u.user_id, b.user_id);
