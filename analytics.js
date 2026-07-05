/* Celis Analytics — lightweight page view counter */
(function() {
    try {
        // Skip admin pages
        var path = window.location.pathname;
        if (path.indexOf('/admin') !== -1) return;

        // Don't track same page twice in same session (avoids double-counting on SPA navigation)
        var sessionKey = 'yun_viewed_' + path;
        if (sessionStorage.getItem(sessionKey)) return;
        sessionStorage.setItem(sessionKey, '1');

        // Determine page name
        var page = 'other';
        if (path === '/' || path.indexOf('index.html') !== -1) page = 'home';
        else if (path.indexOf('products.html') !== -1) page = 'products';
        else if (path.indexOf('product.html') !== -1) page = 'product';
        else if (path.indexOf('outfit.html') !== -1) page = 'outfit';
        else if (path.indexOf('checkout.html') !== -1) page = 'checkout';
        else if (path.indexOf('cart.html') !== -1) page = 'cart';
        else if (path.indexOf('thankyou.html') !== -1) page = 'thankyou';

        // Build full path with params for detail
        var fullPath = path + window.location.search;

        // Fire-and-forget insert (non-blocking)
        var url = 'https://afbmxzrtdwqiawzsddtq.supabase.co/rest/v1/page_views';
        var key = 'sb_publishable_3zK-PWVRezCH0KrhzNNXUQ_Ud5Kmoz3';
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'apikey': key,
                'Authorization': 'Bearer ' + key,
                'Prefer': 'return=minimal'
            },
            body: JSON.stringify({
                page: page,
                path: fullPath,
                referrer: document.referrer || null,
                screen_width: window.screen.width
            })
        }).catch(function() {});
    } catch(e) {}
})();
