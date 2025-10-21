-- Seed data for ALX Airbnb Database (PostgreSQL)
-- Repo: alx-airbnb-database
-- Dir : database-script-0x02
-- File: seed.sql

-- Use the same schema created in schema.sql
SET search_path = airbnb, public;

-- OPTION: Start clean for repeatable seeds (comment out if you want to keep data)
TRUNCATE TABLE
  wishlist_items,
  wishlists,
  messages,
  reviews,
  payments,
  bookings,
  property_amenities,
  amenities,
  property_images,
  properties,
  users
RESTART IDENTITY CASCADE;

-------------------------
-- 1) Users (hosts/guests)
-------------------------
INSERT INTO users (user_id, email, password_hash, first_name, last_name, phone, user_role, is_verified, created_at) VALUES
  (1, 'host1@example.com',   'hash_host1', 'Amal',  'Haddad',  '+212600000001', 'host',  true,  NOW() - INTERVAL '120 days'),
  (2, 'host2@example.com',   'hash_host2', 'Youssef','Bennani','+212600000002', 'host',  true,  NOW() - INTERVAL '80 days'),
  (3, 'guest1@example.com',  'hash_guest1','Sara',  'El Idrissi','+212600000003','guest', true,  NOW() - INTERVAL '60 days'),
  (4, 'guest2@example.com',  'hash_guest2','Khalid','Faouzi', '+212600000004', 'guest', false, NOW() - INTERVAL '30 days'),
  (5, 'multi@example.com',   'hash_both',  'Nadia', 'Zerouali','+212600000005', 'both',  true,  NOW() - INTERVAL '10 days');

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-------------------------
-- 2) Properties
-------------------------
INSERT INTO properties (
  property_id, host_id, title, description, country, city, address_line,
  latitude, longitude, nightly_price, currency, max_guests, num_bedrooms, num_bathrooms, created_at
) VALUES
  (1, 1, 'Medina Riad Room', 'Traditional riad room near Jemaa el-Fnaa', 'MA', 'Marrakesh', 'Riad Z, Medina', 31.63, -8.00, 55.00, 'USD', 2, 1, 1.0, NOW() - INTERVAL '90 days'),
  (2, 1, 'Gueliz Studio',    'Modern studio with balcony and fast Wi-Fi', 'MA', 'Marrakesh', 'Rue Mohammed V', 31.63, -8.01, 40.00, 'USD', 2, 0, 1.0, NOW() - INTERVAL '75 days'),
  (3, 2, 'Casablanca Corniche Apt', 'Sea view apartment on the Corniche', 'MA', 'Casablanca', 'Bd de la Corniche', 33.61, -7.66, 85.00, 'USD', 4, 2, 1.5, NOW() - INTERVAL '50 days'),
  (4, 2, 'Rabat Center Loft', 'Loft next to the old medina and tram',     'MA', 'Rabat', 'Ave Hassan II', 34.02, -6.84, 70.00, 'USD', 3, 1, 1.0, NOW() - INTERVAL '40 days');

CREATE INDEX IF NOT EXISTS idx_properties_city_country ON properties(city, country);

-------------------------
-- 3) Property Images
-------------------------
INSERT INTO property_images (image_id, property_id, image_url, is_cover, position) VALUES
  (1, 1, 'https://img.example.com/riad1-cover.jpg', true,  1),
  (2, 1, 'https://img.example.com/riad1-2.jpg',     false, 2),
  (3, 2, 'https://img.example.com/studio-cover.jpg',true,  1),
  (4, 3, 'https://img.example.com/casa-sea.jpg',    true,  1),
  (5, 4, 'https://img.example.com/rabat-loft.jpg',  true,  1);

-------------------------
-- 4) Amenities
-------------------------
INSERT INTO amenities (amenity_id, name, category) VALUES
  (1, 'Wi-Fi',            'connectivity'),
  (2, 'Air Conditioning', 'climate'),
  (3, 'Heating',          'climate'),
  (4, 'Kitchen',          'kitchen'),
  (5, 'Washer',           'appliance'),
  (6, 'Free Parking',     'parking'),
  (7, 'TV',               'entertainment'),
  (8, 'Pool',             'recreation');

-------------------------
-- 5) Property ↔ Amenities
-------------------------
INSERT INTO property_amenities (property_id, amenity_id) VALUES
  (1, 1),(1,3),(1,4),(1,7),
  (2, 1),(2,2),(2,4),
  (3, 1),(3,2),(3,4),(3,5),(3,6),(3,7),
  (4, 1),(4,2),(4,4);

-------------------------
-- 6) Bookings
-------------------------
-- choose past and upcoming ranges to mimic real usage
INSERT INTO bookings (
  booking_id, property_id, guest_id, check_in, check_out, guests_count, status, total_amount, currency, created_at
) VALUES
  (1, 1, 3, DATE(NOW()) - INTERVAL '28 days', DATE(NOW()) - INTERVAL '25 days', 2, 'completed', 55.00*3, 'USD', NOW() - INTERVAL '30 days'),
  (2, 3, 3, DATE(NOW()) - INTERVAL '10 days', DATE(NOW()) - INTERVAL '7 days',  2, 'completed', 85.00*3, 'USD', NOW() - INTERVAL '12 days'),
  (3, 2, 4, DATE(NOW()) + INTERVAL '7 days',  DATE(NOW()) + INTERVAL '10 days', 1, 'confirmed', 40.00*3, 'USD', NOW() - INTERVAL '1 day'),
  (4, 4, 5, DATE(NOW()) + INTERVAL '15 days', DATE(NOW()) + INTERVAL '17 days', 2, 'pending',   70.00*2, 'USD', NOW());

-------------------------
-- 7) Payments (1:1 with bookings)
-------------------------
INSERT INTO payments (payment_id, booking_id, amount, currency, method, status, provider_txn_id, paid_at) VALUES
  (1, 1, 165.00, 'USD', 'card',    'succeeded', 'txn_0001', NOW() - INTERVAL '29 days'),
  (2, 2, 255.00, 'USD', 'wallet',  'succeeded', 'txn_0002', NOW() - INTERVAL '11 days'),
  (3, 3, 120.00, 'USD', 'card',    'succeeded', 'txn_0003', NOW() - INTERVAL '1 day');
-- booking 4 is pending -> not paid yet

-------------------------
-- 8) Reviews (one per completed booking)
-------------------------
INSERT INTO reviews (review_id, booking_id, property_id, guest_id, rating, comment, created_at) VALUES
  (1, 1, 1, 3, 5, 'Amazing riad and location.', NOW() - INTERVAL '25 days'),
  (2, 2, 3, 3, 4, 'Great sea view, a bit noisy at night.', NOW() - INTERVAL '7 days');

-------------------------
-- 9) Messages (simple inbox samples)
-------------------------
INSERT INTO messages (message_id, sender_id, recipient_id, booking_id, body, sent_at, is_read) VALUES
  (1, 3, 1, 1, 'Hello, what time is check-in?', NOW() - INTERVAL '31 days', true),
  (2, 1, 3, 1, 'Check-in from 14:00. Welcome!', NOW() - INTERVAL '30 days', true),
  (3, 4, 1, 3, 'Can I arrive late at night?',   NOW() - INTERVAL '2 days',  false);

-------------------------
-- 10) Wishlists
-------------------------
INSERT INTO wishlists (wishlist_id, owner_id, name, created_at) VALUES
  (1, 3, 'Morocco Trip', NOW() - INTERVAL '20 days'),
  (2, 4, 'Weekend Ideas', NOW() - INTERVAL '5 days');

INSERT INTO wishlist_items (wishlist_id, property_id) VALUES
  (1, 3), (1, 4),
  (2, 1), (2, 2);

-------------------------
-- 11) Align sequences with explicit IDs (keep NEXTVAL correct)
-------------------------
-- Only needed because we inserted explicit IDs
SELECT setval(pg_get_serial_sequence('airbnb.users','user_id'),         (SELECT MAX(user_id)        FROM users),         true);
SELECT setval(pg_get_serial_sequence('airbnb.properties','property_id'),(SELECT MAX(property_id)    FROM properties),    true);
SELECT setval(pg_get_serial_sequence('airbnb.property_images','image_id'),(SELECT MAX(image_id)     FROM property_images),true);
SELECT setval(pg_get_serial_sequence('airbnb.amenities','amenity_id'),  (SELECT MAX(amenity_id)     FROM amenities),     true);
SELECT setval(pg_get_serial_sequence('airbnb.bookings','booking_id'),   (SELECT MAX(booking_id)     FROM bookings),      true);
SELECT setval(pg_get_serial_sequence('airbnb.payments','payment_id'),   (SELECT MAX(payment_id)     FROM payments),      true);
SELECT setval(pg_get_serial_sequence('airbnb.reviews','review_id'),     (SELECT MAX(review_id)      FROM reviews),       true);
SELECT setval(pg_get_serial_sequence('airbnb.messages','message_id'),   (SELECT MAX(message_id)     FROM messages),      true);
SELECT setval(pg_get_serial_sequence('airbnb.wishlists','wishlist_id'), (SELECT MAX(wishlist_id)    FROM wishlists),     true);

-- End of seed