# Product Sort Order — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `sort_order` column to the products table and build an admin drag-and-drop reordering UI so the admin can control the display order of products on the storefront.

**Architecture:** 
- Add `sort_order` integer column to `products` table (SQL migration)
- In admin, add a "Reorder Products" panel with HTML5 drag-and-drop
- On the products page, change the default sort from `.order('name')` to `.order('sort_order').order('name')`
- "Featured" sort option on the storefront uses this admin-defined order

**Tech Stack:** Supabase (PostgreSQL), vanilla JS, HTML5 Drag and Drop API, existing CSS patterns

## Global Constraints
- Single-page static site hosted on Netlify
- Supabase backend (URL: `afbmxzrtdwqiawzsddtq.supabase.co`)
- No build tools or frameworks — vanilla JS only
- Accent color: `#c5d98b`
- Fonts: Barlow Condensed (display), Inter (body), Space Mono (mono)
- Admin panel is at `admin/index.html`
- Products page is at `products.html`

---

### Task 1: SQL Migration — Add `sort_order` to products table

**Files:**
- Create: `migration-product-sort-order.sql`

**Interfaces:**
- Produces: `sort_order` integer column on `products` table, default 0, with index

- [ ] **Step 1: Create migration SQL file**

```sql
-- migration-product-sort-order.sql
-- Adds sort_order column to products table for admin-controlled display ordering

ALTER TABLE products ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Set initial sort_order based on created_at (oldest first = lowest sort_order)
UPDATE products SET sort_order = sub.row_num - 1
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY created_at ASC) AS row_num
    FROM products
) AS sub
WHERE products.id = sub.id
AND products.sort_order = 0;

-- Add index for faster sorting queries
CREATE INDEX IF NOT EXISTS idx_products_sort_order ON products(sort_order);

-- Verify
SELECT id, name, sort_order, created_at FROM products ORDER BY sort_order, created_at;
```

- [ ] **Step 2: User runs this SQL in Supabase Dashboard**

The user must go to Supabase Dashboard → SQL Editor → paste and run the above SQL.

---

### Task 2: Admin Panel — Add "Reorder Products" UI

**Files:**
- Modify: `admin/index.html` (add reorder section HTML + JS)

**Interfaces:**
- Consumes: `products` table with `sort_order` column
- Produces: `saveProductSortOrder(ids)` function that updates `sort_order` in DB

- [ ] **Step 1: Add "Reorder" button to admin products header**

In `admin/index.html`, find the products section header (near the filter/sort controls) and add a "Reorder" button. Search for the existing product sort dropdown area and add the button next to it.

- [ ] **Step 2: Add reorder modal HTML**

Add a full-screen modal/overlay that shows all products as draggable cards in a vertical list. Each card shows: drag handle, product image thumbnail, product name, current price. The modal has "Save Order" and "Cancel" buttons.

- [ ] **Step 3: Implement drag-and-drop JS**

Use HTML5 Drag and Drop API:
- `dragstart`: store the dragged element index
- `dragover`: prevent default, show drop indicator
- `drop`: reorder the DOM elements
- `saveProductSortOrder()`: collect all product IDs in new DOM order, batch update `sort_order` in Supabase

- [ ] **Step 4: Add `saveProductSortOrder()` function**

```javascript
async function saveProductSortOrder() {
    var cards = document.querySelectorAll('#reorderList .reorder-card');
    var updates = [];
    cards.forEach(function(card, index) {
        var id = card.getAttribute('data-product-id');
        updates.push(yunDb.from('products').update({ sort_order: index }).eq('id', id));
    });
    await Promise.all(updates);
    showToast('✓ Product order saved');
    closeReorderModal();
    loadProducts();
}
```

---

### Task 3: Products Page — Use `sort_order` for default display

**Files:**
- Modify: `products.html` (change Supabase query + sort handler)

**Interfaces:**
- Consumes: `sort_order` column from products table
- Produces: Products displayed in admin-defined order by default

- [ ] **Step 1: Update the products query**

Change the Supabase query from:
```javascript
.order('name');
```
To:
```javascript
.order('sort_order', { ascending: true, nullsFirst: false })
.order('name');
```

This makes products display in the admin-defined order by default. Products with the same `sort_order` (or no order set) fall back to alphabetical.

- [ ] **Step 2: Update the "Featured" sort to use `sort_order`**

In the sort handler, the "default" option (which returns `return 0`) already preserves DOM order. Since the query now returns products in `sort_order` first, the default/featured sort will show admin-defined order automatically. No change needed to the sort handler itself.

- [ ] **Step 3: Add `data-sort-order` attribute to product cards**

In `renderProducts()`, add `data-sort-order` to each card so the sort handler can use it if needed:
```javascript
'data-sort-order="' + escapeHtml(p.sort_order || 0) + '"'
```

---

### Task 4: Verify — Test the complete flow

- [ ] **Step 1:** Run the SQL migration in Supabase Dashboard
- [ ] **Step 2:** Open admin panel → Products → click "Reorder Products"
- [ ] **Step 3:** Drag products into desired order → click "Save Order"
- [ ] **Step 4:** Open products page → verify products appear in the saved order
- [ ] **Step 5:** Test sort dropdown — "Featured" should show admin order, other sorts should work
- [ ] **Step 6:** Create a new product → verify it gets `sort_order: 0` (appears first in reorder UI)
