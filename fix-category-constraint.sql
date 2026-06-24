-- Remove old hardcoded category check constraint
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_check;

-- Make category nullable (products without category are OK)
ALTER TABLE products ALTER COLUMN category DROP NOT NULL;
