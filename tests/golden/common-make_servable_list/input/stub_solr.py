"""A stand-in for Solr's select handler, for the servable list script's test: serves docs.jsonl two documents per
page with cursorMark paging, logs each request's parameters, and writes its port to port.txt."""
import json
import os
import urllib.parse
from http.server import BaseHTTPRequestHandler, HTTPServer

DOCS = [json.loads(line) for line in open('docs.jsonl')]
PAGE = 2


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(url.query)
        with open('requests.log', 'a') as log:
            log.write('%s %s\n' % (url.path, json.dumps({k: v[0] for k, v in sorted(params.items())})))
        if url.path != '/solr/pahma-public/select':
            self.send_error(404)
            return
        start = 0 if params['cursorMark'][0] == '*' else int(params['cursorMark'][0])
        fields = params['fl'][0].split(',')
        docs = [{k: v for k, v in d.items() if k in fields} for d in DOCS[start:start + PAGE]]
        nxt = start + len(docs)
        body = json.dumps({'responseHeader': {'status': 0}, 'response': {'docs': docs},
                           'nextCursorMark': str(nxt) if docs else params['cursorMark'][0]}).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


server = HTTPServer(('127.0.0.1', 0), Handler)
with open('port.txt.tmp', 'w') as f:
    f.write(str(server.server_port))
os.replace('port.txt.tmp', 'port.txt')
server.serve_forever()
