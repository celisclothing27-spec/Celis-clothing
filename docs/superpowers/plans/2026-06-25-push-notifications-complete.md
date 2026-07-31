# Push Notifications Complete - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the push notification system by adding a GitHub Actions workflow to auto-send notifications on new orders, adding a `notification_sent` column to track sent notifications, and ensuring the `push_subscriptions` table is created in Supabase.

**Architecture:** GitHub Actions polls Supabase every 2 minutes for orders where `notification_sent = false`, then calls the `push-send` Netlify function to notify all subscribers, then marks orders as `notification_sent = true`.

**Tech Stack:** GitHub Actions (cron), Supabase JS client, Netlify Functions (web-push), VAPID keys

## Global Constraints
- Supabase URL: `afbmxzrtdwqiawzsddtq.supabase.co`
- Supabase Key: `sb_publishable_3zK-PWVRezCH0KrhzNNXUQ_Ud5Kmoz3`
- VAPID Public Key: `BOGV0D0Zc-qxPnhJ_k0uk9jeJPWdGwjBx7J5ol5ZeeSs6w0yYLYa5XS7i_bk_gFuji2Z31dPna8vpIHE9XBLnC8`
- VAPID Private Key: `S39YzywjiQIbYijNiXqXleWkD5ZiUA5vcFu3XhnlkOk`
- Push Function URL: `/.netlify/functions/push-send`

## What Already EXISTS (DO NOT recreate)
- `push_subscriptions` table SQL (`add-push-subscriptions.sql`)
- Service Worker (`admin/sw.js`)
- PWA Manifest (`admin/manifest.json`)
- Netlify Function `push-send.js`
- In-app polling `checkNewOrders()` (15s interval)
- Sound, Badge, Alert Banners in Admin
- Enable/Test Push functions in Admin

## What NEEDS to be created
1. `notification_sent` column on `orders` table
2. GitHub Actions workflow `.github/workflows/order-notifications.yml`
3. Migration SQL to add `notification_sent` column

---

### Task 1: Create Migration SQL for `notification_sent` column

**Files:**
- Create: `/home/haitham/Desktop/yyyyy/stor 2/MIGRATION_NOTIFICATION_SENT.sql`

**Interfaces:**
- Modifies: `orders` table in Supabase
- Produces: `notification_sent` boolean column, defaults to `false`

- [ ] **Step 1: Create the migration SQL file**

```sql
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
```

- [ ] **Step 2: Commit**

```bash
git add MIGRATION_NOTIFICATION_SENT.sql
git commit -m "feat: add notification_sent column migration for orders table"
```

---

### Task 2: Create GitHub Actions Workflow

**Files:**
- Create: `/home/haitham/Desktop/yyyyy/stor 2/.github/workflows/order-notifications.yml`

**Interfaces:**
- Consumes: Supabase REST API to query orders
- Consumes: Supabase REST API to query push_subscriptions
- Produces: Calls Netlify Function `push-send` to send notifications
- Produces: Updates `notification_sent = true` on notified orders

- [ ] **Step 1: Create the `.github/workflows` directory**

```bash
mkdir -p .github/workflows
```

- [ ] **Step 2: Create the workflow file**

```yaml
name: Order Notifications

on:
  schedule:
    # Every 2 minutes
    - cron: '*/2 * * * *'
  workflow_dispatch: # Allow manual trigger

jobs:
  check-and-notify:
    runs-on: ubuntu-latest
    steps:
      - name: Check for new orders and send notifications
        uses: actions/github-script@v7
        with:
          script: |
            const supabaseUrl = 'https://afbmxzrtdwqiawzsddtq.supabase.co';
            const supabaseKey = 'sb_publishable_3zK-PWVRezCH0KrhzNNXUQ_Ud5Kmoz3';
            const pushFunctionUrl = 'https://celis-clothing.netlify.app/.netlify/functions/push-send';

            // 1. Fetch un-notified orders
            const ordersRes = await fetch(
              `${supabaseUrl}/rest/v1/orders?id=order_number,first_name,last_name,total,created_at&notification_sent=eq.false&order=created_at.desc`,
              {
                headers: {
                  'apikey': supabaseKey,
                  'Authorization': `Bearer ${supabaseKey}`,
                  'Prefer': 'return=representation'
                }
              }
            );

            if (!ordersRes.ok) {
              console.log('No new orders or error fetching orders:', ordersRes.status);
              return;
            }

            const orders = await ordersRes.json();
            if (!orders || orders.length === 0) {
              console.log('No new orders to notify about');
              return;
            }

            console.log(`Found ${orders.length} new order(s)`);

            // 2. Fetch all push subscriptions
            const subsRes = await fetch(
              `${supabaseUrl}/rest/v1/push_subscriptions?select=endpoint,p256dh,auth`,
              {
                headers: {
                  'apikey': supabaseKey,
                  'Authorization': `Bearer ${supabaseKey}`
                }
              }
            );

            if (!subsRes.ok) {
              console.log('No subscriptions found or error:', subsRes.status);
              return;
            }

            const subscriptions = await subsRes.json();
            if (!subscriptions || subscriptions.length === 0) {
              console.log('No push subscribers to notify');
              return;
            }

            console.log(`Sending to ${subscriptions.length} subscriber(s)`);

            // 3. Send push notification via Netlify function
            const orderSummary = orders.map(o => {
              const name = o.first_name || 'Customer';
              const total = o.total ? `${o.total} DZD` : '';
              return `${name} - ${total}`;
            }).join(', ');

            const pushRes = await fetch(pushFunctionUrl, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                title: `🔔 ${orders.length} New Order(s)`,
                body: orderSummary,
                url: '/admin/index.html',
                subscriptions: subscriptions
              })
            });

            const pushResult = await pushRes.json();
            console.log('Push result:', JSON.stringify(pushResult));

            // 4. Mark orders as notified
            const orderIds = orders.map(o => o.id);
            await fetch(
              `${supabaseUrl}/rest/v1/orders?id=in.(${orderIds.join(',')})`,
              {
                method: 'PATCH',
                headers: {
                  'apikey': supabaseKey,
                  'Authorization': `Bearer ${supabaseKey}`,
                  'Content-Type': 'application/json',
                  'Prefer': 'return=minimal'
                },
                body: JSON.stringify({ notification_sent: true })
              }
            );

            console.log(`Marked ${orderIds.length} order(s) as notified`);
```

- [ ] **Step 3: Verify the workflow syntax**

Run: `cat .github/workflows/order-notifications.yml`
Expected: Valid YAML output

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/order-notifications.yml
git commit -m "feat: add GitHub Actions workflow for order push notifications (every 2 min)"
```

---

### Task 3: Verify All Components Connected

- [ ] **Step 1: Check that `push_subscriptions` table exists in Supabase**
- [ ] **Step 2: Check that `notification_sent` column exists (run migration if not)**
- [ ] **Step 3: Check that Netlify function `push-send` is deployed**
- [ ] **Step 4: Check that GitHub Actions workflow is committed**
- [ ] **Step 5: Enable Notifications in Admin → Test Push → verify delivery**
- [ ] **Step 6: Place a test order → verify GitHub Actions sends notification within 2 minutes**

---

## Architecture Diagram

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  GitHub Actions  │────▶│  Supabase REST    │────▶│  Netlify Func   │
│  (every 2 min)  │     │  API (query)      │     │  push-send.js   │
│  order-notif.yml│     │  orders table     │     │  web-push lib   │
└─────────────────┘     │  push_subscriptions│     └────────┬────────┘
                        └──────────────────┘              │
                                                          ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Admin Dashboard │     │  Service Worker   │     │   Browser Push  │
│  checkNewOrders()│     │  sw.js            │────▶│   Notification  │
│  (15s polling)  │     │  push handler     │     │   (sound+badge) │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## Flow

1. **GitHub Actions** runs every 2 minutes
2. Queries Supabase for orders where `notification_sent = false`
3. If found, queries `push_subscriptions` for all subscribers
4. Calls Netlify function `push-send` with title + subscriptions
5. `push-send` uses web-push to deliver to each subscriber
6. Marks orders as `notification_sent = true`
7. **Service Worker** receives push → shows browser notification
8. **Admin Dashboard** also polls every 15s for in-app alerts (sound + badge)
