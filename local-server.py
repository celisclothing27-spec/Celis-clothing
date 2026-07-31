import json
import os
import sys
import urllib.request
import urllib.error
from http.server import SimpleHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn

ROOT = os.path.dirname(os.path.abspath(__file__))
ZR_BASE = 'https://api.zrexpress.app/api/v1'


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def log_message(self, fmt, *args):
        sys.stdout.write("%s %s\n" % (self.address_string(), fmt % args))
        sys.stdout.flush()

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
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

    def proxy_function(self):
        if self.path.startswith('/.netlify/functions/zr-rates'):
            self.proxy_zr_rates()
            return
        self.proxy_zr_api()

    def proxy_zr_api(self):
        try:
            length = int(self.headers.get('Content-Length', 0) or 0)
            raw = self.rfile.read(length).decode('utf-8') if length else '{}'
            try:
                body = json.loads(raw) if raw else {}
            except Exception:
                body = {}
            api_key = body.get('apiKey') or ''
            tenant_id = body.get('tenantId') or ''
            path = body.get('path') or '/users/profile'
            method = (body.get('method') or 'GET').upper()
            payload = body.get('body')

            if not api_key or not tenant_id:
                self.json_response(400, {'error': 'Missing apiKey or tenantId'})
                return
            if not path.startswith('/'):
                self.json_response(400, {'error': 'Invalid path'})
                return

            url = ZR_BASE + path
            req = urllib.request.Request(url, method=method)
            req.add_header('X-Api-Key', api_key)
            req.add_header('X-Tenant', tenant_id)
            req.add_header('Accept', 'application/json')
            data = None
            if payload is not None and method != 'GET':
                req.add_header('Content-Type', 'application/json')
                data = json.dumps(payload).encode('utf-8')
            resp = urllib.request.urlopen(req, data=data, timeout=40)
            out = resp.read().decode('utf-8')
            self.send_response(resp.status)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out.encode('utf-8'))
        except urllib.error.HTTPError as e:
            out = e.read().decode('utf-8')
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out.encode('utf-8'))
        except Exception as e:
            self.json_response(500, {'error': 'Server error', 'details': str(e)})

    def proxy_zr_rates(self):
        try:
            length = int(self.headers.get('Content-Length', 0) or 0)
            raw = self.rfile.read(length).decode('utf-8') if length else '{}'
            try:
                body = json.loads(raw) if raw else {}
            except Exception:
                body = {}
            api_key = body.get('apiKey') or ''
            tenant_id = body.get('tenantId') or ''
            from_wilaya = body.get('fromWilaya') or '16'
            to_wilaya = body.get('toWilaya') or ''

            if not api_key or not tenant_id:
                self.json_response(400, {'error': 'Missing apiKey or tenantId'})
                return

            query = '?from_wilaya=' + str(from_wilaya)
            if to_wilaya:
                query += '&to_wilaya=' + str(to_wilaya)
            url = ZR_BASE + '/rates' + query
            req = urllib.request.Request(url, method='GET')
            req.add_header('X-Api-Key', api_key)
            req.add_header('X-Tenant', tenant_id)
            req.add_header('Accept', 'application/json')
            resp = urllib.request.urlopen(req, timeout=40)
            out = resp.read().decode('utf-8')
            self.send_response(resp.status)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out.encode('utf-8'))
        except urllib.error.HTTPError as e:
            out = e.read().decode('utf-8')
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(out.encode('utf-8'))
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
    print('Emulated Netlify functions: zr-api, zr-rates')
    sys.stdout.flush()
    server.serve_forever()
