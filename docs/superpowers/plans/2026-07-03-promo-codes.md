# Promo Code System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Full promo code/coupon system with admin management and checkout redemption.

**Architecture:** New `promo_codes` table in Supabase. Admin panel section to CRUD codes. Checkout page field to apply code and calculate discount. Discount applied to cart total before shipping.

**Tech Stack:** Supabase (PostgreSQL), HTML/CSS/JS, existing patterns (YunCache, toast, admin UI)

---

## Database Schema

```sql
CREATE TABLE IF NOT EXISTS promo_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  discount_type TEXT NOT NULL DEFAULT 'percent', -- 'percent' or 'fixed'
  discount_value NUMERIC NOT NULL DEFAULT 0,
  min_order NUMERIC DEFAULT 0,
  max_uses INTEGER DEFAULT 0, -- 0 = unlimited
  used_count INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

## Task 1: Create Database Table

**Files:**
- Create: `migration-promo-codes.sql`

**Steps:**

- [ ] **Step 1: Write migration SQL**

```sql
-- migration-promo-codes.sql
CREATE TABLE IF NOT EXISTS promo_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  discount_type TEXT NOT NULL DEFAULT 'percent',
  discount_value NUMERIC NOT NULL DEFAULT 0,
  min_order NUMERIC DEFAULT 0,
  max_uses INTEGER DEFAULT 0,
  used_count INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE promo_codes DISABLE ROW LEVEL SECURITY;
```

- [ ] **Step 2: Tell user to run in Supabase Dashboard**

---

## Task 2: Admin Panel — Promo Codes Section

**Files:**
- Modify: `admin/index.html`

**Steps:**

- [ ] **Step 1: Add nav link for Promo Codes**

Find the nav links section, add after Products Page link:
```html
<div class="nav-link" onclick="switchTab('promocodes')">🎟 Promo Codes</div>
```

- [ ] **Step 2: Add section HTML**

Add after the `section-productspage` div:
```html
<div id="section-promocodes" class="hidden">
    <div class="section-title">Promo Codes</div>
    <div style="display:flex;gap:8px;margin-bottom:20px">
        <button class="btn-admin" onclick="openPromoForm()">+ Create Code</button>
    </div>

    <!-- Create/Edit Form -->
    <div id="promoForm" style="display:none" class="settings-card" style="margin-bottom:20px">
        <h3 id="promoFormTitle" style="font-size:1rem;margin-bottom:16px">Create Promo Code</h3>
        <div class="form-row">
            <div class="form-group" style="flex:1">
                <label class="form-label">Code</label>
                <input type="text" id="promoCode" class="form-input" placeholder="e.g. SUMMER20" style="text-transform:uppercase">
            </div>
            <div class="form-group" style="flex:1">
                <label class="form-label">Discount Type</label>
                <select id="promoType" class="form-input" onchange="togglePromoFields()">
                    <option value="percent">Percent (%)</option>
                    <option value="fixed">Fixed Amount (DA)</option>
                </select>
            </div>
        </div>
        <div class="form-row">
            <div class="form-group" style="flex:1">
                <label class="form-label">Discount Value</label>
                <input type="number" id="promoValue" class="form-input" placeholder="e.g. 20" min="0">
            </div>
            <div class="form-group" style="flex:1">
                <label class="form-label">Min Order (DA) <span style="color:rgba(255,255,255,0.3)">0 = no min</span></label>
                <input type="number" id="promoMinOrder" class="form-input" placeholder="0" value="0" min="0">
            </div>
        </div>
        <div class="form-row">
            <div class="form-group" style="flex:1">
                <label class="form-label">Max Uses <span style="color:rgba(255,255,255,0.3)">0 = unlimited</span></label>
                <input type="number" id="promoMaxUses" class="form-input" placeholder="0" value="0" min="0">
            </div>
            <div class="form-group" style="flex:1">
                <label class="form-label">Expires At <span style="color:rgba(255,255,255,0.3)">empty = never</span></label>
                <input type="datetime-local" id="promoExpires" class="form-input">
            </div>
        </div>
        <div class="form-group">
            <label class="form-label">Active</label>
            <label style="display:flex;align-items:center;gap:8px;font-size:0.85rem;color:rgba(255,255,255,0.7);cursor:pointer;margin-top:6px">
                <input type="checkbox" id="promoActive" checked style="accent-color:#c5d98b;width:16px;height:16px">
                Code is active and can be used
            </label>
        </div>
        <div style="display:flex;gap:8px;margin-top:16px">
            <button class="btn-admin" onclick="savePromoCode()" id="promoSaveBtn">Save Code</button>
            <button class="btn-admin-ghost" onclick="closePromoForm()">Cancel</button>
        </div>
    </div>

    <!-- Codes List -->
    <div id="promoCodesList"></div>
</div>
```

- [ ] **Step 3: Add switchTab case for promocodes**

Find the `switchTab` function, add:
```javascript
if (tab === 'promocodes') loadPromoCodes();
```

- [ ] **Step 4: Add JS functions**

```javascript
// === PROMO CODES ===
var editingPromoId = null;

function togglePromoFields() {
    var type = document.getElementById('promoType').value;
    var label = document.querySelector('#promoValue').closest('.form-group').querySelector('.form-label');
    if (type === 'percent') {
        label.innerHTML = 'Discount Value (%)';
    } else {
        label.innerHTML = 'Discount Value (DA)';
    }
}

function openPromoForm(id) {
    editingPromoId = id || null;
    document.getElementById('promoForm').style.display = 'block';
    document.getElementById('promoFormTitle').textContent = id ? 'Edit Promo Code' : 'Create Promo Code';
    if (!id) {
        document.getElementById('promoCode').value = '';
        document.getElementById('promoType').value = 'percent';
        document.getElementById('promoValue').value = '';
        document.getElementById('promoMinOrder').value = '0';
        document.getElementById('promoMaxUses').value = '0';
        document.getElementById('promoExpires').value = '';
        document.getElementById('promoActive').checked = true;
        document.getElementById('promoSaveBtn').textContent = 'Save Code';
    }
}

function closePromoForm() {
    document.getElementById('promoForm').style.display = 'none';
    editingPromoId = null;
}

async function savePromoCode() {
    var code = document.getElementById('promoCode').value.trim().toUpperCase();
    var type = document.getElementById('promoType').value;
    var value = parseFloat(document.getElementById('promoValue').value) || 0;
    var minOrder = parseFloat(document.getElementById('promoMinOrder').value) || 0;
    var maxUses = parseInt(document.getElementById('promoMaxUses').value) || 0;
    var expires = document.getElementById('promoExpires').value || null;
    var active = document.getElementById('promoActive').checked;

    if (!code) { alert('Code is required'); return; }
    if (value <= 0) { alert('Discount value must be > 0'); return; }
    if (type === 'percent' && value > 100) { alert('Percent cannot exceed 100'); return; }

    var data = {
        code: code,
        discount_type: type,
        discount_value: value,
        min_order: minOrder,
        max_uses: maxUses,
        expires_at: expires ? new Date(expires).toISOString() : null,
        is_active: active
    };

    var btn = document.getElementById('promoSaveBtn');
    btn.disabled = true; btn.textContent = 'Saving...';
    try {
        if (editingPromoId) {
            var { error } = await yunDb.from('promo_codes').update(data).eq('id', editingPromoId);
            if (error) throw error;
        } else {
            var { error } = await yunDb.from('promo_codes').insert(data);
            if (error) throw error;
        }
        showToast('✓ Promo code saved!');
        closePromoForm();
        loadPromoCodes();
    } catch(e) {
        alert('Error: ' + e.message);
    } finally {
        btn.disabled = false; btn.textContent = 'Save Code';
    }
}

async function loadPromoCodes() {
    var container = document.getElementById('promoCodesList');
    container.innerHTML = '<div class="loading">Loading promo codes...</div>';
    try {
        var { data: codes, error } = await yunDb.from('promo_codes').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (!codes || codes.length === 0) {
            container.innerHTML = '<div class="empty">No promo codes yet. Create your first one!</div>';
            return;
        }
        var html = '<div style="display:grid;gap:12px">';
        codes.forEach(function(c) {
            var typeLabel = c.discount_type === 'percent' ? c.discount_value + '%' : c.discount_value.toLocaleString() + ' DA';
            var status = c.is_active ? '<span style="color:#00c864">● Active</span>' : '<span style="color:#ff3232">● Inactive</span>';
            var expiry = c.expires_at ? new Date(c.expires_at).toLocaleDateString() : 'Never';
            var uses = c.max_uses > 0 ? c.used_count + '/' + c.max_uses : c.used_count + ' / ∞';
            var isExpired = c.expires_at && new Date(c.expires_at) < new Date();
            html += '<div style="background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;padding:16px;display:flex;align-items:center;gap:16px;flex-wrap:wrap">' +
                '<div style="font-family:\'Space Mono\',monospace;font-weight:700;font-size:1rem;color:#c5d98b;letter-spacing:0.05em;min-width:120px">' + c.code + '</div>' +
                '<div style="font-family:\'Barlow Condensed\',sans-serif;font-weight:800;font-style:italic;font-size:1.1rem">' + typeLabel + ' OFF</div>' +
                '<div style="font-size:0.75rem;color:rgba(255,255,255,0.4)">Min: ' + (c.min_order > 0 ? c.min_order.toLocaleString() + ' DA' : 'None') + '</div>' +
                '<div style="font-size:0.75rem;color:rgba(255,255,255,0.4)">Uses: ' + uses + '</div>' +
                '<div style="font-size:0.75rem;color:rgba(255,255,255,0.4)">Expires: ' + (isExpired ? '<span style="color:#ff3232">Expired</span>' : expiry) + '</div>' +
                '<div style="margin-left:auto;display:flex;gap:6px;align-items:center">' +
                    status +
                    '<button class="btn-admin-ghost btn-sm" onclick="copyPromoCode(\'' + c.code + '\')" title="Copy">📋</button>' +
                    '<button class="btn-admin-ghost btn-sm" onclick="editPromoCode(\'' + c.id + '\')">✏️</button>' +
                    '<button class="btn-danger btn-sm" onclick="deletePromoCode(\'' + c.id + '\')">🗑</button>' +
                '</div>' +
            '</div>';
        });
        html += '</div>';
        container.innerHTML = html;
    } catch(e) {
        container.innerHTML = '<div class="empty">Error: ' + e.message + '</div>';
    }
}

function copyPromoCode(code) {
    navigator.clipboard.writeText(code).then(function() {
        showToast('✓ Code copied: ' + code);
    });
}

async function editPromoCode(id) {
    var { data: code } = await yunDb.from('promo_codes').select('*').eq('id', id).single();
    if (!code) return;
    openPromoForm(id);
    document.getElementById('promoCode').value = code.code;
    document.getElementById('promoType').value = code.discount_type;
    document.getElementById('promoValue').value = code.discount_value;
    document.getElementById('promoMinOrder').value = code.min_order || 0;
    document.getElementById('promoMaxUses').value = code.max_uses || 0;
    document.getElementById('promoExpires').value = code.expires_at ? code.expires_at.slice(0, 16) : '';
    document.getElementById('promoActive').checked = code.is_active;
    document.getElementById('promoSaveBtn').textContent = 'UPDATE CODE';
    togglePromoFields();
}

async function deletePromoCode(id) {
    if (!confirm('Delete this promo code?')) return;
    var { error } = await yunDb.from('promo_codes').delete().eq('id', id);
    if (error) { alert('Error: ' + error.message); return; }
    showToast('✓ Promo code deleted');
    loadPromoCodes();
}
```

---

## Task 3: Checkout Page — Promo Code Field

**Files:**
- Modify: `checkout.html`

**Steps:**

- [ ] **Step 1: Add promo code UI**

Find the order summary section, add promo code field before the total:

```html
<!-- Promo Code -->
<div style="margin-bottom:16px">
    <label class="form-label" style="margin-bottom:8px;display:block">Promo Code</label>
    <div style="display:flex;gap:8px">
        <input type="text" id="promoInput" class="form-input" placeholder="Enter code" style="text-transform:uppercase;flex:1">
        <button type="button" id="promoApplyBtn" onclick="applyPromoCode()" style="padding:10px 20px;background:#c5d98b;color:#0a0a0a;border:none;border-radius:8px;font-weight:700;font-size:0.8rem;cursor:pointer;white-space:nowrap">APPLY</button>
    </div>
    <div id="promoMessage" style="margin-top:8px;font-size:0.75rem;display:none"></div>
</div>
```

- [ ] **Step 2: Add promo code JS logic**

```javascript
// === PROMO CODE ===
var appliedPromo = null;

async function applyPromoCode() {
    var code = document.getElementById('promoInput').value.trim().toUpperCase();
    var msg = document.getElementById('promoMessage');
    var btn = document.getElementById('promoApplyBtn');

    if (!code) { msg.style.display = 'block'; msg.style.color = '#ff3232'; msg.textContent = 'Enter a code'; return; }

    btn.textContent = '...';
    btn.disabled = true;

    try {
        var { data: promo, error } = await yunDb.from('promo_codes')
            .select('*')
            .eq('code', code)
            .eq('is_active', true)
            .single();

        if (error || !promo) {
            msg.style.display = 'block'; msg.style.color = '#ff3232'; msg.textContent = 'Invalid or inactive code';
            appliedPromo = null;
            updatePromoDisplay();
            return;
        }

        // Check expiry
        if (promo.expires_at && new Date(promo.expires_at) < new Date()) {
            msg.style.display = 'block'; msg.style.color = '#ff3232'; msg.textContent = 'Code has expired';
            appliedPromo = null;
            updatePromoDisplay();
            return;
        }

        // Check max uses
        if (promo.max_uses > 0 && promo.used_count >= promo.max_uses) {
            msg.style.display = 'block'; msg.style.color = '#ff3232'; msg.textContent = 'Code usage limit reached';
            appliedPromo = null;
            updatePromoDisplay();
            return;
        }

        // Check min order
        var subtotal = cart.reduce(function(s, i) { return s + i.price * i.qty; }, 0);
        if (promo.min_order > 0 && subtotal < promo.min_order) {
            msg.style.display = 'block'; msg.style.color = '#ff3232'; msg.textContent = 'Minimum order: ' + promo.min_order.toLocaleString() + ' DA';
            appliedPromo = null;
            updatePromoDisplay();
            return;
        }

        // Calculate discount
        var discount = 0;
        if (promo.discount_type === 'percent') {
            discount = Math.round(subtotal * promo.discount_value / 100);
        } else {
            discount = Math.min(promo.discount_value, subtotal);
        }

        appliedPromo = { ...promo, discount: discount };
        msg.style.display = 'block'; msg.style.color = '#00c864';
        msg.textContent = '✓ ' + (promo.discount_type === 'percent' ? promo.discount_value + '% off' : promo.discount_value.toLocaleString() + ' DA off') + ' — You save ' + discount.toLocaleString() + ' DA';

        btn.textContent = 'REMOVE';
        btn.onclick = removePromoCode;
        updatePromoDisplay();
    } catch(e) {
        msg.style.display = 'block'; msg.style.color = '#ff3232'; msg.textContent = 'Error: ' + e.message;
    } finally {
        btn.textContent = appliedPromo ? 'REMOVE' : 'APPLY';
        btn.disabled = false;
    }
}

function removePromoCode() {
    appliedPromo = null;
    document.getElementById('promoInput').value = '';
    var msg = document.getElementById('promoMessage');
    msg.style.display = 'none';
    var btn = document.getElementById('promoApplyBtn');
    btn.textContent = 'APPLY';
    btn.onclick = applyPromoCode;
    updatePromoDisplay();
}

function updatePromoDisplay() {
    // Update order summary with discount
    var subtotal = cart.reduce(function(s, i) { return s + i.price * i.qty; }, 0);
    var discount = appliedPromo ? appliedPromo.discount : 0;
    var afterDiscount = subtotal - discount;

    var discountRow = document.getElementById('promoDiscountRow');
    if (discount > 0) {
        if (!discountRow) {
            discountRow = document.createElement('div');
            discountRow.id = 'promoDiscountRow';
            discountRow.className = 'cart-summary-row';
            var totalRow = document.querySelector('.cart-total-row');
            if (totalRow) totalRow.parentNode.insertBefore(discountRow, totalRow);
        }
        discountRow.innerHTML = '<span class="cart-summary-label" style="color:#00c864">PROMO DISCOUNT</span><span class="cart-summary-value" style="color:#00c864">-' + discount.toLocaleString() + ' DA</span>';
        discountRow.style.display = 'flex';
    } else if (discountRow) {
        discountRow.style.display = 'none';
    }
}

// Add to order data before submission
function getOrderData() {
    // ... existing code ...
    if (appliedPromo) {
        orderData.promo_code = appliedPromo.code;
        orderData.promo_discount = appliedPromo.discount;
    }
    return orderData;
}
```

---

## Task 4: Apply Promo on Order Submission

**Files:**
- Modify: `checkout.html` — order submission function

**Steps:**

- [ ] **Step 1: Decrement used_count after order**

In the order submission success handler, add:
```javascript
// Increment promo code usage
if (appliedPromo) {
    await yunDb.from('promo_codes').update({ used_count: appliedPromo.used_count + 1 }).eq('id', appliedPromo.id);
}
```

---

## Testing Checklist

1. Admin: Create promo code (percent type)
2. Admin: Create promo code (fixed amount type)
3. Admin: Edit a promo code
4. Admin: Delete a promo code
5. Admin: Copy code to clipboard
6. Checkout: Enter valid code → discount shows
7. Checkout: Enter expired code → error message
8. Checkout: Enter code below min order → error
9. Checkout: Remove applied code → discount removed
10. Checkout: Place order with code → used_count increments
