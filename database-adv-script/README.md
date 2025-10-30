# Task 0 — Complex Queries with Joins

**Repository:** `alx-airbnb-database`  
**Directory:** `database-adv-script/`  
**Files:** `joins_queries.sql`, `README.md`  
**Weight:** 1  
**Status:** Mandatory  

---

## 🎯 Objective
Master SQL joins by writing complex queries using different types of joins (INNER, LEFT, and FULL OUTER JOIN).

---

## 🧠 Instructions
1. Write a query using an **INNER JOIN** to retrieve all bookings and the respective users who made those bookings.  
2. Write a query using a **LEFT JOIN** to retrieve all properties and their reviews, including properties that have no reviews.  
3. Write a query using a **FULL OUTER JOIN** to retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.

---

## 🗂️ Database Tables (for reference)
- **app_user(user_id, first_name, last_name, email, role)**
- **property(property_id, host_id, name, location)**
- **booking(booking_id, property_id, user_id, start_date, end_date, status)**
- **review(review_id, property_id, user_id, rating, comment)**

---

## ▶️ How to Run
Make sure your PostgreSQL database is active and contains the Airbnb schema.  
Run the queries from terminal or pgAdmin:

```bash
psql -U postgres -d airbnb_db -f database-adv-script/joins_queries.sql
