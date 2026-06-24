-- حذف الأوتفيت نهائياً
-- شغّل هذا في Supabase SQL Editor

DROP VIEW IF EXISTS outfits_with_items CASCADE;
DROP TABLE IF EXISTS outfit_items CASCADE;
DROP TABLE IF EXISTS outfit_images CASCADE;
DROP TABLE IF EXISTS outfits CASCADE;

SELECT '✅ All outfit tables dropped' AS result;
