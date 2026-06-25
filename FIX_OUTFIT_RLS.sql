-- اسمح بقراءة المنتجات الفرعية للأوتفيت (حتى لو is_active: false)
CREATE POLICY "Allow reading outfit children" ON products
  FOR SELECT USING (parent_product_id IS NOT NULL);
