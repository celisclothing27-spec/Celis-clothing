-- Fix foreign key constraints to allow product deletion
-- Run this in Supabase SQL Editor

-- 1. Drop existing foreign key constraints on order_items
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_variant_id_fkey;
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_product_id_fkey;

-- 2. Re-add with ON DELETE SET NULL (preserve order history, nullify references)
ALTER TABLE order_items ADD CONSTRAINT order_items_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;

ALTER TABLE order_items ADD CONSTRAINT order_items_variant_id_fkey 
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL;

-- Verify
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
JOIN information_schema.referential_constraints rc ON tc.constraint_name = rc.constraint_name
WHERE tc.table_name = 'order_items' AND tc.constraint_type = 'FOREIGN KEY';
