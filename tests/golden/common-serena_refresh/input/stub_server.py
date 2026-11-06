"""A stand-in for Solr's select handler and Serena's ETL API, for the Serena step's test.

Solr: serves the documents in the file named in solr-docs.txt, all on one page. Serena: follows the scenario named
in scenario.txt (read on every request, so the test can switch scenarios without a restart), keeps one refresh in
memory, and logs each request to requests.txt: method, path, whether the token was right (never the token), and for
an upload its headers and what the body holds. Writes its port to port.txt."""
import gzip
import hashlib
import json
import os
import urllib.parse
from http.server import BaseHTTPRequestHandler, HTTPServer

TOKEN = 'test-token-0123456789abcdefghijklmnopqrstuvwxyz'
state = {'refresh': None, 'n': 0, 'calls': {}}


def scenario():
    with open('scenario.txt') as f:
        return f.read().strip()


def refresh_out(r):
    base = '/etl/v1/museums/pahma/refreshes/' + r['refresh_id']
    out = dict(r)
    out.update({'museum': 'pahma', 'refresh_date': '2026-10-22', 'file_name': 'servable-list.pahma.2026-10-22.tsv',
                'poll_interval_seconds': 1 if scenario() == 'stuck' else 0,
                'step_timeout_seconds': 1 if scenario() == 'stuck' else 5,
                'links': {'self': base, 'servable_list': base + '/servable-list', 'check': base + '/check'}})
    return out


class Handler(BaseHTTPRequestHandler):
    def note(self, text=''):
        auth = self.headers.get('Authorization')
        who = 'none' if auth is None else ('ok' if auth == 'Bearer ' + TOKEN else 'wrong')
        with open('requests.txt', 'a') as log:
            log.write('%s %s token=%s%s\n' % (self.command, urllib.parse.urlsplit(self.path).path, who,
                                              (' ' + text) if text else ''))

    def send(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json' if status < 400 else 'application/problem+json')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def problem(self, status, title, detail=''):
        self.send(status, {'type': 'about:blank', 'title': title, 'status': status, 'detail': detail})

    def count(self, key):
        state['calls'][key] = state['calls'].get(key, 0) + 1
        return state['calls'][key]

    def do_GET(self):
        path = urllib.parse.urlsplit(self.path).path
        if path == '/solr/pahma-public/select':
            with open('solr-docs.txt') as f:
                docs = [json.loads(line) for line in open(f.read().strip())]
            cursor = urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)['cursorMark'][0]
            self.send(200, {'response': {'docs': docs if cursor == '*' else []}, 'nextCursorMark': 'end'
                            if cursor == '*' else cursor})
            return
        self.note()
        if self.headers.get('Authorization') != 'Bearer ' + TOKEN:
            self.problem(401, 'Unauthorized')
        elif path == '/etl/v1/ping':
            self.send(200, {'museum': 'bampfa' if scenario() == 'wrong-museum' else 'pahma'})
        elif state['refresh'] and path == '/etl/v1/museums/pahma/refreshes/' + state['refresh']['refresh_id']:
            r = state['refresh']
            if r['state'] == 'checking':
                if scenario() == 'check-fails':
                    r['state'] = 'check_failed'
                    r['check'] = {'result': 'failed', 'rows': 7, 'added': 7, 'removed': 0, 'changed': 0,
                                  'delta_percent': 100.0, 'threshold_percent': 5.0, 'error_count': 1,
                                  'errors': [{'line': 3, 'field': 'kind', 'problem': "isn't image, card, audio, "
                                              "video, 3D or pdf"}], 'warnings': []}
                elif scenario() == 'stuck':
                    pass
                else:
                    r['state'] = 'updating'
                    r['check'] = {'result': 'passed', 'rows': 7, 'added': 1, 'removed': 0, 'changed': 0,
                                  'delta_percent': 0.2, 'threshold_percent': 5.0, 'error_count': 0, 'errors': [],
                                  'warnings': []}
            elif r['state'] == 'updating':
                r['state'] = 'updated'
                r['update'] = {'deleted': 0, 'written': 1, 'unchanged': 6}
            self.send(200, refresh_out(r))
        else:
            self.problem(404, 'Not found')

    def do_POST(self):
        path = urllib.parse.urlsplit(self.path).path
        self.note()
        if self.headers.get('Authorization') != 'Bearer ' + TOKEN:
            self.problem(401, 'Unauthorized')
        elif path == '/etl/v1/museums/pahma/refreshes':
            if scenario() == 'busy' and self.count('start') == 1:
                self.problem(409, 'Out of order', 'the previous refresh is still being checked')
                return
            state['n'] += 1
            state['refresh'] = {'refresh_id': 'pahma-2026-10-22-%d' % state['n'], 'state': 'started'}
            self.send(201, refresh_out(state['refresh']))
        elif state['refresh'] and path.endswith('/check'):
            state['refresh']['state'] = 'checking'
            self.send(202, refresh_out(state['refresh']))
        else:
            self.problem(404, 'Not found')

    def do_PUT(self):
        path = urllib.parse.urlsplit(self.path).path
        body = self.rfile.read(int(self.headers.get('Content-Length', 0)))
        if scenario() == 'busy' and self.count('upload') == 1:
            self.note('-> 503')
            self.problem(503, 'Storage unavailable', 'try again')
            return
        data = gzip.decompress(body) if self.headers.get('Content-Encoding') == 'gzip' else body
        sha_ok = hashlib.sha256(data).hexdigest() == self.headers.get('X-Content-SHA256')
        rows_ok = str(data.count(b'\n') - 1) == self.headers.get('X-Row-Count')
        self.note('type=%s encoding=%s rows=%s sha256=%s header=%r' % (
            self.headers.get('Content-Type'), self.headers.get('Content-Encoding'), self.headers.get('X-Row-Count'),
            'matches' if sha_ok else 'WRONG', data.split(b'\n')[0].decode()))
        if not (sha_ok and rows_ok):
            self.problem(422, 'Upload mismatch')
        elif state['refresh'] and path.endswith('/servable-list'):
            state['refresh']['state'] = 'received'
            self.send(200, refresh_out(state['refresh']))
        else:
            self.problem(404, 'Not found')

    def log_message(self, *args):
        pass


server = HTTPServer(('127.0.0.1', 0), Handler)
with open('port.txt.tmp', 'w') as f:
    f.write(str(server.server_port))
os.replace('port.txt.tmp', 'port.txt')
server.serve_forever()
