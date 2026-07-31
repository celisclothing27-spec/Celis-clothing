import json
import os
import sys
import urllib.request
import urllib.error
import urllib.parse
from http.server import SimpleHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn

ROOT = os.path.dirname(os.path.abspath(__file__))
ZR_BASE = 'https://api.zrexpress.app/api/v1'
SUPABASE_URL = os.environ.get('SUPABASE_URL') or 'https://afbmxzrtdwqiawzsddtq.supabase.co'

CONFIG = {}
_config_candidates = [
    os.path.join(ROOT, 'local-config.json'),
    os.path.join(ROOT, '..', 'secrets', 'local-config.json'),
]
_config_path = next((p for p in _config_candidates if os.path.exists(p)), '')
if _config_path:
    try:
        with open(_config_path, 'r', encoding='utf-8') as _f:
            CONFIG = json.load(_f) or {}
    except Exception:
        CONFIG = {}

SECRET_KEY = os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or CONFIG.get('service_role_key') or ''
ZR_API_KEY = os.environ.get('ZR_API_KEY') or CONFIG.get('zr_api_key') or ''
ZR_TENANT_ID = os.environ.get('ZR_TENANT_ID') or CONFIG.get('zr_tenant_id') or ''


def fetch_url(url, method='GET', headers=None, data=None, timeout=40):
    req = urllib.request.Request(url, method=method)
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    resp = urllib.request.urlopen(req, data=data, timeout=timeout)
    body = resp.read()
    return resp.status, body, resp.headers


def supabase_get(key, url_suffix):
    status, body, _ = fetch_url(
        SUPABASE_URL + url_suffix,
        headers={'apikey': key, 'Authorization': 'Bearer ' + key, 'Accept': 'application/json'},
    )
    if status != 200:
        raise RuntimeError('Supabase GET %s -> %d' % (url_suffix, status))
    return json.loads(body.decode('utf-8'))


def resolve_secret_key():
    if SECRET_KEY:
        return SECRET_KEY
    raise RuntimeError('Missing service_role key (local-config.json -> service_role_key)')


def fetch_site_settings():
    key = resolve_secret_key()
    rows = supabase_get(key, '/rest/v1/site_settings?select=key,value&key=in.(admin_username,admin_password,zr_api_key,zr_tenant_id)')
    out = {}
    for r in rows:
        out[r.get('key')] = r.get('value')
    return out


ADMIN_USER = os.environ.get('ADMIN_USER') or '1234567'
ADMIN_PASS = os.environ.get('ADMIN_PASS') or '1234567'


def verify_admin_creds(username, password):
    if not username or not password:
        return False
    return username == ADMIN_USER and password == ADMIN_PASS


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def log_message(self, fmt, *args):
        sys.stdout.write("%s %s\n" % (self.address_string(), fmt % args))
        sys.stdout.flush()

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, apikey, Authorization, Prefer, Accept, Range, X-Admin-User, X-Admin-Pass')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT, DELETE, HEAD, OPTIONS')
        self.end_headers()

    def do_GET(self):
        if self.path.startswith('/.netlify/functions/'):
            self.proxy_function()
            return
        super().do_GET()

    def do_POST(self):
        if self.path.startswith('/.netlify/functions/'):
            self.proxy_function()
            return
        self.send_error(404)

    def do_PATCH(self):
        if self.path.startswith('/.netlify/functions/'):
            self.proxy_function()
            return
        self.send_error(404)

    def do_PUT(self):
        if self.path.startswith('/.netlify/functions/'):
            self.proxy_function()
            return
        self.send_error(404)

    def do_DELETE(self):
        if self.path.startswith('/.netlify/functions/'):
            self.proxy_function()
            return
        self.send_error(404)

    def read_json_body(self):
        length = int(self.headers.get('Content-Length', 0) or 0)
        raw = self.rfile.read(length).decode('utf-8') if length else '{}'
        try:
            return json.loads(raw) if raw else {}
        except Exception:
            return {}

    def proxy_function(self):
        path = self.path.split('?')[0]
        if path == '/.netlify/functions/zr-rates':
            self.proxy_zr_rates()
            return
        if path == '/.netlify/functions/zr-api':
            self.proxy_zr_api()
            return
        if path.startswith('/.netlify/functions/admin-db'):
            self.admin_db(path)
            return
        if path == '/.netlify/functions/push-send':
            self.proxy_push_send()
            return
        if path == '/.netlify/functions/cloudinary-delete':
            self.proxy_cloudinary_delete()
            return
        self.json_response(404, {'error': 'Unknown function: ' + path})

    # ---------------- admin-db (login + reverse proxy) ----------------
    def admin_db(self, path):
        if path == '/.netlify/functions/admin-db':
            self.admin_db_login()
            return
        if path.startswith('/.netlify/functions/admin-db/rest/v1'):
            self.admin_db_proxy()
            return
        self.json_response(404, {'error': 'Not found'})

    def admin_db_login(self):
        try:
            body = self.read_json_body()
            ok = verify_admin_creds(body.get('username') or '', body.get('password') or '')
            if ok:
                self.json_response(200, {'ok': True})
            else:
                self.json_response(401, {'ok': False, 'error': 'Invalid username or password'})
        except Exception as e:
            self.json_response(500, {'error': 'Server error', 'details': str(e)})

    def admin_db_proxy(self):
        try:
            key = resolve_secret_key()
            user = self.headers.get('X-Admin-User') or ''
            pw = self.headers.get('X-Admin-Pass') or ''
            if not verify_admin_creds(user, pw):
                self.json_response(401, {'error': 'Unauthorized'})
                return

            prefix = '/.netlify/functions/admin-db'
            rel = self.path.split('?')[0][len(prefix):] or '/'
            raw_query = (self.path.split('?', 1)[1] if '?' in self.path else '')
            url = SUPABASE_URL + rel + ('?' + raw_query if raw_query else '')

            fwd = {
                'apikey': key,
                'Authorization': 'Bearer ' + key,
                'Accept': self.headers.get('Accept') or 'application/json',
            }
            for h in ('Content-Type', 'Prefer', 'Range', 'X-Client-Info'):
                v = self.headers.get(h)
                if v:
                    fwd[h] = v

            method = self.command
            data = None
            if self.command in ('POST', 'PATCH', 'PUT'):
                length = int(self.headers.get('Content-Length', 0) or 0)
                data = self.rfile.read(length) if length else None

            status, body, resp_headers = fetch_url(url, method=method, headers=fwd, data=data)
            self.send_response(status)
            self.send_header('Access-Control-Allow-Origin', '*')
            cr = resp_headers.get('Content-Range')
            if cr:
                self.send_header('Content-Range', cr)
            pa = resp_headers.get('Preference-Applied')
            if pa:
                self.send_header('Preference-Applied', pa)
            ctype = resp_headers.get('Content-Type')
            self.send_header('Content-Type', ctype or 'application/json')
            self.end_headers()
            self.wfile.write(body)
        except urllib.error.HTTPError as e:
            out = e.read()
            self.send_response(e.code)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(out)
        except Exception as e:
            self.json_response(502, {'error': 'Upstream error', 'details': str(e)})

    # ---------------- push-send (stub: real push needs Node web-push) ----------------
    def proxy_push_send(self):
        try:
            body = self.read_json_body()
            sent = 0
            try:
                key = resolve_secret_key()
                rows = supabase_get(key, '/rest/v1/push_subscriptions?select=endpoint&limit=1')
                sent = len(rows)
            except Exception:
                pass
            self.json_response(200, {
                'sent': 0,
                'message': 'Push sending is not available on the local dev server. Deploy to Netlify to send real pushes.',
                'subscriptions_found': sent,
            })
        except Exception as e:
            self.json_response(500, {'error': 'Server error', 'details': str(e)})

    # ---------------- cloudinary-delete (real delete via Cloudinary API) ----------------
    def proxy_cloudinary_delete(self):
        try:
            body = self.read_json_body()
            public_ids = body.get('public_ids') or []
            resource_type = body.get('resource_type') or 'image'
            if not public_ids:
                self.json_response(400, {'error': 'No public_ids provided'})
                return

            cloud_name = os.environ.get('CLOUDINARY_CLOUD_NAME') or CONFIG.get('cloudinary_cloud_name') or 'dblanptpo'
            api_key = os.environ.get('CLOUDINARY_API_KEY') or CONFIG.get('cloudinary_api_key') or '261814773818142'
            api_secret = os.environ.get('CLOUDINARY_API_SECRET') or CONFIG.get('cloudinary_api_secret') or '93oDYQY4KQZ4wym4DZEovpg83kQ'

            import base64
            auth = 'Basic ' + base64.b64encode((api_key + ':' + api_secret).encode('utf-8')).decode('utf-8')

            if len(public_ids) == 1:
                url = ('https://api.cloudinary.com/v1_1/%s/%s/upload/%s'
                       % (cloud_name, resource_type, urllib.parse.quote(public_ids[0])))
                status, out, _ = fetch_url(url, method='DELETE', headers={'Authorization': auth})
                self.send_response(status)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(out)
                return

            url = 'https://api.cloudinary.com/v1_1/%s/resources/%s/upload' % (cloud_name, resource_type)
            data = json.dumps({'public_ids': public_ids}).encode('utf-8')
            status, out, _ = fetch_url(url, method='DELETE', headers={'Authorization': auth, 'Content-Type': 'application/json'}, data=data)
            self.send_response(status)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out)
        except urllib.error.HTTPError as e:
            out = e.read()
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out)
        except Exception as e:
            self.json_response(500, {'error': 'Server error', 'details': str(e)})

    # ---------------- zr-api / zr-rates (server-side keys) ----------------
    def resolve_zr_credentials(self, body):
        api_key = body.get('apiKey') or ZR_API_KEY
        tenant_id = body.get('tenantId') or ZR_TENANT_ID
        if not api_key or not tenant_id:
            try:
                s = fetch_site_settings()
                api_key = api_key or s.get('zr_api_key') or ''
                tenant_id = tenant_id or s.get('zr_tenant_id') or ''
            except Exception:
                pass
        return api_key, tenant_id

    def proxy_zr_api(self):
        try:
            body = self.read_json_body()
            api_key, tenant_id = self.resolve_zr_credentials(body)
            path = body.get('path') or '/users/profile'
            method = (body.get('method') or 'GET').upper()
            payload = body.get('body')

            if not api_key or not tenant_id:
                self.json_response(400, {'error': 'Missing ZR credentials (local-config.json / env / site_settings)'})
                return
            if not path.startswith('/'):
                self.json_response(400, {'error': 'Invalid path'})
                return

            url = ZR_BASE + path
            headers = {'X-Api-Key': api_key, 'X-Tenant': tenant_id, 'Accept': 'application/json'}
            data = None
            if payload is not None and method != 'GET':
                headers['Content-Type'] = 'application/json'
                data = json.dumps(payload).encode('utf-8')
            status, body, _ = fetch_url(url, method=method, headers=headers, data=data)
            self.send_response(status)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(body)
        except urllib.error.HTTPError as e:
            out = e.read()
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out)
        except Exception as e:
            self.json_response(500, {'error': 'Server error', 'details': str(e)})

    def proxy_zr_rates(self):
        try:
            body = self.read_json_body()
            api_key, tenant_id = self.resolve_zr_credentials(body)
            from_wilaya = body.get('fromWilaya') or '16'
            to_wilaya = body.get('toWilaya') or ''

            if not api_key or not tenant_id:
                self.json_response(400, {'error': 'Missing ZR credentials (local-config.json / env / site_settings)'})
                return

            query = '?from_wilaya=' + str(from_wilaya)
            if to_wilaya:
                query += '&to_wilaya=' + str(to_wilaya)
            status, body, _ = fetch_url(
                ZR_BASE + '/rates' + query,
                headers={'X-Api-Key': api_key, 'X-Tenant': tenant_id, 'Accept': 'application/json'},
            )
            self.send_response(status)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(body)
        except urllib.error.HTTPError as e:
            out = e.read()
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out)
        except Exception as e:
            self.json_response(500, {'error': 'Server error', 'details': str(e)})

    def json_response(self, code, obj):
        data = json.dumps(obj).encode('utf-8')
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)


class ThreadingServer(ThreadingMixIn, HTTPServer):
    daemon_threads = True


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    server = ThreadingServer(('127.0.0.1', port), Handler)
    print('Local dev server: http://127.0.0.1:%d  (serving %s)' % (port, ROOT))
    print('Emulated Netlify functions: admin-db (login+proxy), zr-api, zr-rates')
    print('Secrets: local-config.json (service_role_key, zr_api_key, zr_tenant_id) or env vars')
    sys.stdout.flush()
    server.serve_forever()
