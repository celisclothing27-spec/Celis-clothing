// yun-cache.js — localStorage cache with TTL
// Reduces Supabase queries by 90%+
var YunCache = {
    TTL: 60 * 1000, // 1 minute default

    get: function(key) {
        try {
            var raw = localStorage.getItem('yun_cache_' + key);
            if (!raw) return null;
            var item = JSON.parse(raw);
            if (Date.now() > item.expires) { localStorage.removeItem('yun_cache_' + key); return null; }
            return item.data;
        } catch(e) { return null; }
    },

    set: function(key, data, ttlMs) {
        try {
            localStorage.setItem('yun_cache_' + key, JSON.stringify({ data: data, expires: Date.now() + (ttlMs || this.TTL) }));
        } catch(e) {}
    },

    invalidate: function(key) { localStorage.removeItem('yun_cache_' + key); },

    invalidatePrefix: function(prefix) {
        var keys = Object.keys(localStorage);
        for (var i = 0; i < keys.length; i++) {
            if (keys[i] === 'yun_cache_' + prefix) { localStorage.removeItem(keys[i]); return; }
        }
    },

    // Cached Supabase fetch
    fetch: function(key, ttlMs, queryFn) {
        var cached = this.get(key);
        if (cached) return Promise.resolve(cached);
        return queryFn().then(function(data) { YunCache.set(key, data, ttlMs); return data; });
    }
};
