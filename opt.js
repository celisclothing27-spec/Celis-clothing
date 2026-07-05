/* Celis utilities — optImg + keep-alive */
function optImg(url, w) {
    if (!url || url.indexOf('cloudinary') === -1) return url;
    return url.replace('/image/upload/', '/image/upload/w_' + (w || 600) + ',q_auto,f_auto/');
}

/* Supabase keep-alive — prevent auto-pause on free tier (fires once per visit) */
(function() {
    try {
        var lastPing = parseInt(sessionStorage.getItem('yun_alive') || '0');
        var now = Date.now();
        if (now - lastPing < 30 * 60 * 1000) return;
        sessionStorage.setItem('yun_alive', now);
        fetch('https://afbmxzrtdwqiawzsddtq.supabase.co/rest/v1/products?select=id&limit=1', {
            headers: { apikey: 'sb_publishable_3zK-PWVRezCH0KrhzNNXUQ_Ud5Kmoz3', Authorization: 'Bearer sb_publishable_3zK-PWVRezCH0KrhzNNXUQ_Ud5Kmoz3' }
        }).catch(function(){});
    } catch(e) {}
})();
