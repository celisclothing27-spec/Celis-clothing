/* Celis utilities — optImg + keep-alive */
function optImg(url, w) {
    if (!url || url.indexOf('cloudinary') === -1) return url;
    return url.replace('/image/upload/', '/image/upload/w_' + (w || 600) + ',q_auto,f_auto/');
}

/* Supabase keep-alive — prevent auto-pause on free tier */
(function() {
    try {
        var lastPing = parseInt(localStorage.getItem('yun_keepalive') || '0');
        var now = Date.now();
        if (now - lastPing < 10 * 60 * 1000) return; // max once per 10 min
        localStorage.setItem('yun_keepalive', now);
        var url = 'https://afbmxzrtdwqiawzsddtq.supabase.co/rest/v1/products?select=id&limit=1';
        var key = 'sb_publishable_3zK-PWVRezCH0KrhzNNXUQ_Ud5Kmoz3';
        fetch(url, { headers: { apikey: key, Authorization: 'Bearer ' + key }, mode: 'cors' }).catch(function(){});
    } catch(e) {}
})();
