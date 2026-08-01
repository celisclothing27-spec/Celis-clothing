const https = require('https');

module.exports = async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') return res.status(200).end();
    if (req.method !== 'POST') return res.status(405).json({ error: 'POST only' });

    const { apiKey, tenantId, toWilaya, fromWilaya } = req.body;
    if (!apiKey || !tenantId || !toWilaya) return res.status(400).json({ error: 'Missing params' });

    const from = fromWilaya || '16';
    const options = {
        hostname: 'api.zrexpress.app',
        path: '/api/v1/rates?from_wilaya=' + from + '&to_wilaya=' + toWilaya,
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'X-Api-Key': apiKey,
            'X-Tenant': tenantId
        }
    };

    return new Promise((resolve) => {
        const r = https.request(options, (resp) => {
            let data = '';
            resp.on('data', (chunk) => { data += chunk; });
            resp.on('end', () => {
                let parsed;
                try { parsed = JSON.parse(data); } catch(e) { parsed = { raw: data }; }
                res.status(resp.statusCode).json(parsed);
                resolve();
            });
        });
        r.on('error', (e) => {
            res.status(500).json({ error: e.message });
            resolve();
        });
        r.end();
    });
};

module.exports.config = { maxDuration: 30 };
