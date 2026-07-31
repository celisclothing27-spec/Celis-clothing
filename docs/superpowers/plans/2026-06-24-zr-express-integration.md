# ZR Express Dynamic Shipping Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace static wilaya shipping rates with dynamic rates fetched from ZR Express API, while maintaining fallback capability.

**Architecture:** Add a new Netlify function to fetch rates from ZR Express API, update checkout to use API rates with static fallback, and add admin controls to sync rates from API.

**Tech Stack:** JavaScript, Supabase, Netlify Functions, ZR Express API (https://api.zrexpress.app/api/v1)

## Global Constraints
- Maintain existing checkout UX (no major layout changes)
- Keep static rates as fallback if API fails
- Admin must be able to toggle between API and static rates
- All prices in Algerian Dinar (DZD)
- ZR Express API requires X-Api-Key and X-Tenant headers

---

## Task 1: Create ZR Express Rates API Function

**Files:**
- Create: `netlify/functions/zr-rates.js`

**Interfaces:**
- Consumes: ZR Express API credentials (apiKey, tenantId) from request body
- Produces: JSON array of shipping rates for specified wilayas

- [ ] **Step 1: Create the Netlify function**

```javascript
// netlify/functions/zr-rates.js
exports.handler = async function(event) {
    var ZR_BASE = 'https://api.zrexpress.app/api/v1';
    var headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 204, headers, body: '' };
    }

    if (event.httpMethod !== 'POST') {
        return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };
    }

    try {
        var body = JSON.parse(event.body || '{}');
        var apiKey = body.apiKey;
        var tenantId = body.tenantId;
        var fromWilaya = body.fromWilaya || '16'; // Default: Alger
        var toWilaya = body.toWilaya;

        if (!apiKey || !tenantId) {
            return { statusCode: 400, headers, body: JSON.stringify({ error: 'Missing apiKey or tenantId' }) };
        }

        // Fetch rates from ZR Express API
        var path = `/rates?from_wilaya=${fromWilaya}&to_wilaya=${toWilaya}`;
        var res = await fetch(ZR_BASE + path, {
            method: 'GET',
            headers: {
                'X-Api-Key': apiKey,
                'X-Tenant': tenantId,
                'accept': 'application/json'
            }
        });

        var data = await res.json();

        return {
            statusCode: res.status,
            headers: { ...headers, 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        };
    } catch (e) {
        return { statusCode: 500, headers, body: JSON.stringify({ error: 'Server error', details: e.message }) };
    }
};
```

- [ ] **Step 2: Test the function locally**

Run: `netlify dev` and test with curl:
```bash
curl -X POST http://localhost:8888/.netlify/functions/zr-rates \
  -H "Content-Type: application/json" \
  -d '{"apiKey":"YOUR_KEY","tenantId":"YOUR_TENANT","toWilaya":"16"}'
```

Expected: JSON response with shipping rates

- [ ] **Step 3: Commit**

```bash
git add netlify/functions/zr-rates.js
git commit -m "feat: add ZR Express rates API function"
```

---

## Task 2: Update Checkout to Use Dynamic Rates

**Files:**
- Modify: `checkout.html` (lines 694-710, 797-808, 878-908)

**Interfaces:**
- Consumes: ZR Express API credentials from site_settings
- Produces: Updated shipping cost display and order total

- [ ] **Step 1: Add ZR Express settings loader**

```javascript
// Add after line 566 (after wilayaPricesCache)
var zrSettings = { apiKey: null, tenantId: null, useApiRates: false };

async function loadZrSettings() {
    try {
        var result = await yunDb.from('site_settings')
            .select('key, value')
            .in('key', ['zr_api_key', 'zr_tenant_id', 'zr_use_api_rates']);
        
        if (result.data) {
            result.data.forEach(function(row) {
                if (row.key === 'zr_api_key') zrSettings.apiKey = row.value;
                if (row.key === 'zr_tenant_id') zrSettings.tenantId = row.value;
                if (row.key === 'zr_use_api_rates') zrSettings.useApiRates = row.value === 'true';
            });
        }
    } catch(e) {
        console.warn('Failed to load ZR settings:', e);
    }
}
```

- [ ] **Step 2: Update fetchShippingPrice to use API**

```javascript
// Replace fetchShippingPrice function (lines 694-710)
async function fetchShippingPrice(wilayaCode) {
    var el = document.getElementById('summaryShipping');
    el.textContent = 'Calculating...';
    
    // Try API rates first if enabled
    if (zrSettings.useApiRates && zrSettings.apiKey && zrSettings.tenantId) {
        try {
            var response = await fetch('/.netlify/functions/zr-rates', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    apiKey: zrSettings.apiKey,
                    tenantId: zrSettings.tenantId,
                    toWilaya: wilayaCode
                })
            });
            
            var apiResult = await response.json();
            
            if (apiResult.rates && apiResult.rates.length > 0) {
                // Find rate matching delivery type
                var rate = apiResult.rates.find(function(r) {
                    return selectedDeliveryType === 'home' 
                        ? r.type === 'home_delivery' 
                        : r.type === 'stop_desk';
                });
                
                if (rate) {
                    wilayaPricesCache[wilayaCode] = {
                        home_price: rate.type === 'home_delivery' ? rate.price : null,
                        post_price: rate.type === 'stop_desk' ? rate.price : null
                    };
                    updateSummary();
                    return;
                }
            }
        } catch(e) {
            console.warn('API rates failed, falling back to static:', e);
        }
    }
    
    // Fallback to static rates
    try {
        var result = await yunDb.from('wilaya_pricing')
            .select('home_price, post_price')
            .eq('wilaya_code', wilayaCode)
            .single();
        
        if (result.data) {
            wilayaPricesCache[wilayaCode] = result.data;
            updateSummary();
        }
    } catch(e) {
        console.warn('Shipping price fetch failed:', e);
    }
}
```

- [ ] **Step 3: Initialize settings on page load**

```javascript
// Add after line 480 (after WILAYAS array)
loadZrSettings();
```

- [ ] **Step 4: Test checkout flow**

1. Select a wilaya
2. Verify "Calculating..." appears
3. Verify shipping cost displays (from API or static fallback)
4. Verify total updates correctly

- [ ] **Step 5: Commit**

```bash
git add checkout.html
git commit -m "feat: checkout uses dynamic ZR Express rates with static fallback"
```

---

## Task 3: Add Rate Sync to Admin Dashboard

**Files:**
- Modify: `admin/index.html` (add sync button and function)

**Interfaces:**
- Consumes: ZR Express API credentials from site_settings
- Produces: Updated wilaya_pricing table with API rates

- [ ] **Step 1: Add sync button to Shipping Prices section**

Find the shipping section (around line 1325) and add:
```html
<div id="section-shipping" class="hidden">
    <div class="section-title">Shipping Prices — Wilaya Rates</div>
    <p>Edit Zr Express shipping prices per wilaya. Home = delivery to door, Stop Desk = pickup point.</p>
    
    <!-- Add sync button -->
    <div style="margin-bottom: 16px;">
        <button onclick="syncRatesFromApi()" class="btn btn-outline">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 12a9 9 0 11-6.219-8.56"/>
                <path d="M21 3v5h-5"/>
            </svg>
            Sync Rates from ZR Express
        </button>
        <button onclick="loadShippingPrices()" class="btn btn-outline" style="margin-left: 8px;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M4 4v5h5"/>
                <path d="M20 12a9 9 0 11-6.219-8.56"/>
            </svg>
            Refresh
        </button>
    </div>
    
    <input id="shipSearch" placeholder="Search wilaya..." oninput="filterShipping()">
    <button onclick="saveShippingPrices(this)">Save All</button>
    <div id="shippingTable"><!-- populated by JS --></div>
</div>
```

- [ ] **Step 2: Add sync function to admin JavaScript**

```javascript
// Add after loadShippingPrices function (around line 3259)
async function syncRatesFromApi() {
    var creds = await getZrCredentials();
    if (!creds.apiKey || !creds.tenantId) {
        alert('Please configure ZR Express API credentials first in Settings tab.');
        return;
    }
    
    if (!confirm('This will fetch latest rates from ZR Express for all 58 wilayas. Continue?')) {
        return;
    }
    
    var btn = event.target.closest('button');
    var originalText = btn.innerHTML;
    btn.innerHTML = '<span class="spinner"></span> Syncing...';
    btn.disabled = true;
    
    try {
        // Fetch all rates (from_wilaya not required for ZR Express)
        var result = await zrProxy('/rates', 'GET', null, creds.apiKey, creds.tenantId);
        
        if (result.error) {
            throw new Error(result.error);
        }
        
        // Process rates and update database
        var rates = result.data || result;
        var updated = 0;
        
        for (var i = 0; i < rates.length; i++) {
            var rate = rates[i];
            if (rate.to_wilaya && (rate.home_price || rate.post_price)) {
                await yunDb.from('wilaya_pricing')
                    .upsert({
                        wilaya_code: rate.to_wilaya.toString().padStart(2, '0'),
                        wilaya_name: rate.wilaya_name || rate.to_wilaya_name,
                        home_price: rate.home_price || 0,
                        post_price: rate.post_price || 0
                    }, { onConflict: 'wilaya_code' });
                updated++;
            }
        }
        
        alert(`Successfully synced ${updated} wilaya rates from ZR Express.`);
        loadShippingPrices(); // Refresh table
        
    } catch(e) {
        console.error('Sync failed:', e);
        alert('Failed to sync rates: ' + e.message);
    } finally {
        btn.innerHTML = originalText;
        btn.disabled = false;
    }
}
```

- [ ] **Step 3: Test admin sync**

1. Go to admin > Shipping Prices
2. Click "Sync Rates from ZR Express"
3. Verify rates update in table
4. Verify changes persist after page refresh

- [ ] **Step 4: Commit**

```bash
git add admin/index.html
git commit -m "feat: admin can sync shipping rates from ZR Express API"
```

---

## Task 4: Add API Toggle in Admin Settings

**Files:**
- Modify: `admin/index.html` (add toggle in settings section)

**Interfaces:**
- Consumes: None
- Produces: Updated zr_use_api_rates setting in database

- [ ] **Step 1: Add toggle to ZR Express settings section**

Find the settings section (around line 1336) and add after the Tenant ID input:
```html
<div class="settings-card">
    <h3>Zr Express — API Integration</h3>
    <p>Connect your Zr Express account to ship orders directly from the dashboard.</p>
    
    <label style="display: block; margin-bottom: 16px;">
        <input type="checkbox" id="zrUseApiRates" style="margin-right: 8px;">
        Use ZR Express API for real-time shipping rates at checkout
    </label>
    
    <input type="password" id="zrApiKey" placeholder="Your Zr Express API Key">
    <input type="text" id="zrTenantId" placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx">
    
    <button onclick="saveZrSettings()">Save Settings</button>
    <button onclick="testZrApi()">Test API</button>
    <button onclick="testZrTerritories()">Test Territories</button>
</div>
```

- [ ] **Step 2: Update saveZrSettings to handle toggle**

```javascript
// Update saveZrSettings function (around line 2937)
async function saveZrSettings() {
    var apiKey = document.getElementById('zrApiKey').value.trim();
    var tenantId = document.getElementById('zrTenantId').value.trim();
    var useApiRates = document.getElementById('zrUseApiRates').checked;
    
    try {
        await yunDb.from('site_settings').upsert([
            { key: 'zr_api_key', value: apiKey },
            { key: 'zr_tenant_id', value: tenantId },
            { key: 'zr_use_api_rates', value: useApiRates.toString() }
        ], { onConflict: 'key' });
        
        alert('Settings saved successfully!');
    } catch(e) {
        alert('Failed to save settings: ' + e.message);
    }
}
```

- [ ] **Step 3: Update settings loader to set toggle state**

```javascript
// Update getZrCredentials or add new function
async function loadZrSettingsToForm() {
    try {
        var result = await yunDb.from('site_settings')
            .select('key, value')
            .in('key', ['zr_api_key', 'zr_tenant_id', 'zr_use_api_rates']);
        
        if (result.data) {
            result.data.forEach(function(row) {
                if (row.key === 'zr_api_key') {
                    document.getElementById('zrApiKey').value = row.value || '';
                }
                if (row.key === 'zr_tenant_id') {
                    document.getElementById('zrTenantId').value = row.value || '';
                }
                if (row.key === 'zr_use_api_rates') {
                    document.getElementById('zrUseApiRates').checked = row.value === 'true';
                }
            });
        }
    } catch(e) {
        console.warn('Failed to load ZR settings:', e);
    }
}

// Call on page load
loadZrSettingsToForm();
```

- [ ] **Step 4: Test toggle functionality**

1. Toggle the checkbox on/off
2. Save settings
3. Refresh page
4. Verify toggle state persists

- [ ] **Step 5: Commit**

```bash
git add admin/index.html
git commit -m "feat: add admin toggle for API-based shipping rates"
```

---

## Task 5: Update Database Schema for API Settings

**Files:**
- Modify: `supabase-schema.sql` (add default settings)

**Interfaces:**
- Consumes: None
- Produces: Updated schema with default ZR settings

- [ ] **Step 1: Add default settings to schema**

```sql
-- Add to end of supabase-schema.sql (after RLS policies)
INSERT INTO site_settings (key, value) VALUES
  ('zr_use_api_rates', 'false')
ON CONFLICT (key) DO NOTHING;
```

- [ ] **Step 2: Create migration file**

```sql
-- migrations/2026-06-24-add-zr-api-toggle.sql
INSERT INTO site_settings (key, value) VALUES
  ('zr_use_api_rates', 'false')
ON CONFLICT (key) DO NOTHING;
```

- [ ] **Step 3: Commit**

```bash
git add supabase-schema.sql migrations/
git commit -m "feat: add default ZR API rates toggle setting"
```

---

## Task 6: Documentation and Final Testing

**Files:**
- Create: `docs/shipping-integration.md`

**Interfaces:**
- Consumes: All previous tasks
- Produces: User documentation

- [ ] **Step 1: Create documentation**

```markdown
# ZR Express Shipping Integration

## Overview
This document describes how the ZR Express shipping integration works in the Celis clothing e-commerce store.

## Features

### 1. Dynamic Rate Fetching
- Fetches real-time shipping rates from ZR Express API
- Rates update automatically when ZR Express changes pricing
- Fallback to static rates if API is unavailable

### 2. Admin Controls
- **Toggle API Rates**: Enable/disable real-time rates in Settings tab
- **Sync Rates**: Manually sync rates from ZR Express in Shipping Prices tab
- **Manual Editing**: Override specific rates manually in Shipping Prices tab

### 3. Checkout Experience
- Customer selects wilaya and delivery type
- Shipping cost displays immediately (from API or static)
- Total updates in real-time

## Configuration

### Initial Setup
1. Go to Admin > Settings
2. Enter ZR Express API Key and Tenant ID
3. Toggle "Use ZR Express API for real-time shipping rates"
4. Save settings

### Syncing Rates
1. Go to Admin > Shipping Prices
2. Click "Sync Rates from ZR Express"
3. Rates update for all 58 wilayas

## API Endpoints

### Netlify Functions
- `/.netlify/functions/zr-rates` - Fetch rates for a specific wilaya
- `/.netlify/functions/zr-api` - General ZR Express API proxy

## Fallback Behavior
If ZR Express API fails:
1. Checkout uses static rates from `wilaya_pricing` table
2. Admin sync shows error message
3. Orders continue to process normally

## Troubleshooting

### Rates not updating
- Check ZR Express API credentials in Settings
- Verify API key is valid (use "Test API" button)
- Check browser console for errors

### Static rates showing instead of API rates
- Ensure "Use ZR Express API" toggle is enabled
- Check if ZR settings are saved (refresh page)
```

- [ ] **Step 2: Final testing checklist**

1. Test checkout with API rates enabled
2. Test checkout with API rates disabled (static fallback)
3. Test admin sync function
4. Test admin toggle persistence
5. Test order placement with both rate types

- [ ] **Step 3: Commit**

```bash
git add docs/shipping-integration.md
git commit -m "docs: add shipping integration documentation"
```

---

## Self-Review Checklist

1. **Spec coverage:** 
   - ✅ Dynamic rate fetching from ZR Express API
   - ✅ Static rate fallback
   - ✅ Admin toggle for API vs static
   - ✅ Admin sync function
   - ✅ Checkout integration
   - ✅ Documentation

2. **Placeholder scan:** No TBD/TODO markers found

3. **Type consistency:** All function names and parameters consistent across tasks

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-24-zr-express-integration.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?