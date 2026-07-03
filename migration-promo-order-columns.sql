-- migration-promo-order-columns.sql
-- Add promo_code and promo_discount columns to orders table
-- Run this in Supabase Dashboard → SQL Editor

ALTER TABLE orders ADD COLUMN IF NOT EXISTS promo_code TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS promo_discount NUMERIC DEFAULT 0;
