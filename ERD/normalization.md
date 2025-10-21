# Normalization — ALX Airbnb Database

## Objective
Ensure the database design follows Third Normal Form (3NF) to remove redundancy and maintain data integrity.

---

## 1. First Normal Form (1NF)
- Each table has a primary key.
- All columns contain atomic values (no repeating or multi-valued fields).
- Example: property images moved to a separate table `Property_Image`.

1NF achieved.

---

## 2. Second Normal Form (2NF)
- All non-key attributes depend on the whole key, not part of it.
- Applies mainly to bridge tables such as `Property_Amenity` and `Wishlist_Item`.

2NF achieved.

---

## 3. Third Normal Form (3NF)
- No attribute depends on another non-key attribute.
- Every non-key attribute depends only on its primary key.
- Derived data (for example, number of nights) is not stored.

3NF achieved.

---

## Summary

| Table | 1NF | 2NF | 3NF |
|--------|------|------|------|
| User | Yes | Yes | Yes |
| Property | Yes | Yes | Yes |
| Booking | Yes | Yes | Yes |
| Payment | Yes | Yes | Yes |
| Review | Yes | Yes | Yes |
| Amenity | Yes | Yes | Yes |
| Property_Amenity | Yes | Yes | Yes |
| Message | Yes | Yes | Yes |
| Wishlist | Yes | Yes | Yes |
| Wishlist_Item | Yes | Yes | Yes |

---

## Conclusion
All tables in the Airbnb database meet Third Normal Form (3NF).  
There are no repeating groups, no partial dependencies, and no transitive dependencies.  
The design is clean, efficient, and scalable.

