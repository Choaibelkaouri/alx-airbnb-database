
CREATE SCHEMA IF NOT EXISTS airbnb;
SET search_path = airbnb, public;

-- --- Helper domains/types ----------------------------------------------------

-- ISO 4217 currency code
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency_code') THEN
    CREATE DOMAIN currency_code AS CHAR(3)
      CHECK (VALUE ~ '^[A-Z]{3}$');
  END IF;
END $$;

-- Enums
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('guest','host','both');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'booking_status') THEN
    CREATE TYPE booking_status AS ENUM ('pending','confirmed','cancelled','completed');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_method') THEN
    CREATE TYPE payment_method AS ENUM ('card','wallet','transfer');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
    CREATE TYPE payment_status AS ENUM ('initiated','succeeded','failed','refunded');
  END IF;
END $$;

-- --- Tables ------------------------------------------------------------------

-- Users (hosts and guests)
CREATE TABLE IF NOT EXISTS users (
  user_id        BIGSERIAL PRIMARY KEY,
  email          TEXT NOT NULL UNIQUE,
  password_hash  TEXT NOT NULL,
  first_name     TEXT,
  last_name      TEXT,
  phone          TEXT,
  user_role      user_role NOT NULL DEFAULT 'guest',
  is_verified    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_user_role ON users (user_role);

-- Properties listed by hosts
CREATE TABLE IF NOT EXISTS properties (
  property_id    BIGSERIAL PRIMARY KEY,
  host_id        BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
  title          TEXT NOT NULL,
  description    TEXT,
  country        TEXT,
  city           TEXT,
  address_line   TEXT,
  latitude       NUMERIC(9,6),
  longitude      NUMERIC(9,6),
  nightly_price  NUMERIC(10,2) NOT NULL CHECK (nightly_price >= 0),
  currency       currency_code NOT NULL DEFAULT 'USD',
  max_guests     INT NOT NULL CHECK (max_guests > 0),
  num_bedrooms   INT,
  num_bathrooms  NUMERIC(3,1),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties (host_id);
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties (city, country);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties (nightly_price);

-- Property images
CREATE TABLE IF NOT EXISTS property_images (
  image_id     BIGSERIAL PRIMARY KEY,
  property_id  BIGINT NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  image_url    TEXT NOT NULL,
  is_cover     BOOLEAN NOT NULL DEFAULT FALSE,
  position     INT
);

CREATE INDEX IF NOT EXISTS idx_property_images_prop_pos
  ON property_images (property_id, position);

-- Amenities
CREATE TABLE IF NOT EXISTS amenities (
  amenity_id  SERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  category    TEXT
);

-- Property ↔ Amenity (M:N)
CREATE TABLE IF NOT EXISTS property_amenities (
  property_id  BIGINT NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  amenity_id   INT    NOT NULL REFERENCES amenities(amenity_id)  ON DELETE RESTRICT,
  PRIMARY KEY (property_id, amenity_id)
);

-- Bookings made by guests for properties
CREATE TABLE IF NOT EXISTS bookings (
  booking_id    BIGSERIAL PRIMARY KEY,
  property_id   BIGINT NOT NULL REFERENCES properties(property_id) ON DELETE RESTRICT,
  guest_id      BIGINT NOT NULL REFERENCES users(user_id)         ON DELETE RESTRICT,
  check_in      DATE NOT NULL,
  check_out     DATE NOT NULL,
  guests_count  INT  NOT NULL CHECK (guests_count > 0),
  status        booking_status NOT NULL DEFAULT 'pending',
  total_amount  NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
  currency      currency_code NOT NULL DEFAULT 'USD',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (check_in < check_out)
);

CREATE INDEX IF NOT EXISTS idx_bookings_property_dates
  ON bookings (property_id, check_in, check_out);
CREATE INDEX IF NOT EXISTS idx_bookings_guest ON bookings (guest_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings (status);

-- Optional: prevent overlapping bookings per property (PostgreSQL only)
-- Requires btree_gist extension
-- CREATE EXTENSION IF NOT EXISTS btree_gist;
-- ALTER TABLE bookings
--   ADD CONSTRAINT bookings_no_overlap
--   EXCLUDE USING gist (
--     property_id WITH =,
--     daterange(check_in, check_out, '[]') WITH &&
--   )
--   DEFERRABLE INITIALLY IMMEDIATE;

-- Payments (1:1 with booking)
CREATE TABLE IF NOT EXISTS payments (
  payment_id      BIGSERIAL PRIMARY KEY,
  booking_id      BIGINT NOT NULL UNIQUE
                  REFERENCES bookings(booking_id) ON DELETE CASCADE,
  amount          NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  currency        currency_code NOT NULL DEFAULT 'USD',
  method          payment_method,
  status          payment_status,
  provider_txn_id TEXT,
  paid_at         TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_payments_status ON payments (status);

-- Reviews (one review per booking; ties back to property and guest)
CREATE TABLE IF NOT EXISTS reviews (
  review_id    BIGSERIAL PRIMARY KEY,
  booking_id   BIGINT NOT NULL UNIQUE
               REFERENCES bookings(booking_id) ON DELETE CASCADE,
  property_id  BIGINT NOT NULL REFERENCES properties(property_id) ON DELETE RESTRICT,
  guest_id     BIGINT NOT NULL REFERENCES users(user_id)         ON DELETE RESTRICT,
  rating       SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment      TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_property_rating ON reviews (property_id, rating);
CREATE INDEX IF NOT EXISTS idx_reviews_guest ON reviews (guest_id);

-- Messages between users (optional)
CREATE TABLE IF NOT EXISTS messages (
  message_id    BIGSERIAL PRIMARY KEY,
  sender_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
  recipient_id  BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
  booking_id    BIGINT     REFERENCES bookings(booking_id) ON DELETE SET NULL,
  body          TEXT NOT NULL,
  sent_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_read       BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_messages_inbox ON messages (recipient_id, is_read);
CREATE INDEX IF NOT EXISTS idx_messages_booking ON messages (booking_id);

-- Wishlists (optional)
CREATE TABLE IF NOT EXISTS wishlists (
  wishlist_id  BIGSERIAL PRIMARY KEY,
  owner_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
  name         TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wishlists_owner ON wishlists (owner_id);

-- Wishlist items (M:N)
CREATE TABLE IF NOT EXISTS wishlist_items (
  wishlist_id  BIGINT NOT NULL REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
  property_id  BIGINT NOT NULL REFERENCES properties(property_id) ON DELETE RESTRICT,
  PRIMARY KEY (wishlist_id, property_id)
);

CREATE INDEX IF NOT EXISTS idx_wishlist_items_property ON wishlist_items (property_id);

-- End of schema