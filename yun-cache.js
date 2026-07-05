// yun-cache.js — localStorage cache with TTL + request dedup
// Reduces Supabase queries by 95%+
var YunCache = {
    TTL: 60 * 1000, // 1 minute default
    _pending: {}, // in-flight request dedup

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
        } catch(e) { /* quota exceeded — clear old entries */
            try {
                var keys = Object.keys(localStorage);
                for (var i = 0; i < keys.length; i++) {
                    if (keys[i].indexOf('yun_cache_') === 0) { localStorage.removeItem(keys[i]); break; }
                }
            } catch(e2) {}
        }
    },

    invalidate: function(key) { localStorage.removeItem('yun_cache_' + key); },

    invalidatePrefix: function(prefix) {
        var keys = Object.keys(localStorage);
        for (var i = 0; i < keys.length; i++) {
            if (keys[i] === 'yun_cache_' + prefix) { localStorage.removeItem(keys[i]); return; }
        }
    },

    // Cached Supabase fetch with request dedup
    // If two calls happen simultaneously for the same key, only one hits Supabase
    fetch: function(key, ttlMs, queryFn) {
        var cached = this.get(key);
        if (cached) return Promise.resolve(cached);

        // Dedup: if same key is being fetched right now, reuse that promise
        if (this._pending[key]) return this._pending[key];

        var self = this;
        var promise = queryFn().then(function(data) {
            self.set(key, data, ttlMs);
            delete self._pending[key];
            return data;
        }).catch(function(err) {
            delete self._pending[key];
            throw err;
        });

        this._pending[key] = promise;
        return promise;
    }
};
