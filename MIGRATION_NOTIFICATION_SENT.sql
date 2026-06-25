-- Add notification_sent column to orders table
-- Run this in Supabase SQL Editor

ALTER TABLE orders ADD COLUMN IF NOT EXISTS notification_sent BOOLEAN DEFAULT false;

-- Mark all existing orders as already notified (so we don't spam for old orders)
UPDATE orders SET notification_sent = true WHERE notification_sent IS NULL OR notification_sent = false;

-- Create index for fast polling
CREATE INDEX IF NOT EXISTS idx_orders_notification_sent ON orders(notification_sent, created_at DESC);

-- Verify
SELECT column_name, data_type, default_value 
FROM information_schema.columns 
WHERE table_name = 'orders' AND column_name = 'notification_sent';
