"""Hand a museum's servable list to Serena, the new ImageServer, through its ETL API (Jira CSW-1027, Part 3).

Run after the museum's public Solr refresh, by serena-refresh.sh. The API is Serena's
(ets-berkeley-edu/cspace-media-server, docs/design.md, The daily sequence and The ETL API; docs/api/etl-v1.json):

1. ping: the token must belong to this museum;
2. make the servable list from the live public core (make_servable_list.py); if that fails, stop here;
3. start a refresh: Serena returns the list's file name (a 409 means Serena is still busy with an earlier refresh:
   try again until the step timeout);
4. upload the list (gzip), with X-Row-Count and X-Content-SHA256;
5. ask Serena to check it: if the check passes, Serena does the servability update at once;
6. poll until the refresh is updated, check_failed, update_failed or abandoned, or the step timeout passes.

Usage: python3 serena_refresh.py <tenant> <work folder>

Settings, from the environment (pipeline-config.sh):
  SERENA_BASE_URL   Serena's base URL, without /etl/v1
  SERENA_TOKEN_DIR  holds <tenant>.token, the museum's bearer token: owned by the app user, mode 600
  SOLR_URL          Solr, for the servable list (default http://localhost:8983/solr)
  SERENA_POLL_SECONDS, SERENA_RETRY_DELAY_SECONDS  waits before Serena gives its own (15 and 2; for tests)

The token is read from its file and sent only in the Authorization header: never logged or printed.
Prints a report on stdout. Exit status: 0 the refresh is updated; 1 it isn't (Serena unreachable, a timeout, a
failed check or servability update, or no servable list); 2 a setting is missing or wrong.
"""
import gzip
import hashlib
import http.client
import json
import os
import ssl
import stat
import sys
import time
import urllib.parse

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_servable_list  # noqa: E402

API = '/etl/v1'
CONNECT_TIMEOUT = 10
READ_TIMEOUT = 60
RETRIES = 3
RETRY_DELAY = float(os.environ.get('SERENA_RETRY_DELAY_SECONDS', '2'))  # doubled for each retry
DEFAULT_POLL_SECONDS = float(os.environ.get('SERENA_POLL_SECONDS', '15'))  # until Serena says
DEFAULT_STEP_TIMEOUT_SECONDS = 1800
DONE = {'updated', 'check_failed', 'update_failed', 'abandoned'}


class SerenaError(Exception):
    """A call that failed for good: unreachable after its retries, or an answer the job can't carry on from."""


class Answer:
    def __init__(self, status, body):
        self.status = status
        try:
            self.json = json.loads(body.decode('utf-8')) if body else {}
        except ValueError:
            self.json = {}

    def problem(self):
        """Serena's application/problem+json, in a line."""
        title = self.json.get('title', '')
        detail = self.json.get('detail', '')
        return '%s %s%s' % (self.status, title, (': ' + detail) if detail else '')


class Serena:
    def __init__(self, base_url, token, tenant):
        url = urllib.parse.urlsplit(base_url)
        local = url.hostname in ('localhost', '127.0.0.1')
        if not url.hostname or not (url.scheme == 'https' or (url.scheme == 'http' and local)):
            raise ValueError('SERENA_BASE_URL must be an https URL')
        self.scheme = url.scheme
        self.host = url.hostname
        self.port = url.port
        self.prefix = url.path.rstrip('/')
        self.token = token
        self.tenant = tenant

    def _once(self, method, path, body, headers):
        if self.scheme == 'https':
            conn = http.client.HTTPSConnection(self.host, self.port, timeout=CONNECT_TIMEOUT,
                                               context=ssl.create_default_context())
        else:
            conn = http.client.HTTPConnection(self.host, self.port, timeout=CONNECT_TIMEOUT)
        try:
            conn.connect()
            conn.sock.settimeout(READ_TIMEOUT)
            all_headers = {'Authorization': 'Bearer ' + self.token, 'Accept': 'application/json'}
            all_headers.update(headers or {})
            conn.request(method, self.prefix + path, body=body, headers=all_headers)
            response = conn.getresponse()
            return Answer(response.status, response.read())
        finally:
            conn.close()

    def call(self, method, path, body=None, headers=None):
        """One API call, retried up to RETRIES times with backoff for connection errors and 5xx answers."""
        delay = RETRY_DELAY
        for attempt in range(RETRIES + 1):
            try:
                answer = self._once(method, path, body, headers)
                if answer.status < 500:
                    return answer
                failure = answer.problem()
            except (OSError, http.client.HTTPException) as e:
                failure = '%s: %s' % (type(e).__name__, e)
            if attempt < RETRIES:
                log('%s %s: %s; retrying in %gs' % (method, path, failure, delay))
                time.sleep(delay)
                delay *= 2
        raise SerenaError('%s %s failed after %d retries: %s' % (method, path, RETRIES, failure))


def log(message):
    print(message, flush=True)


def read_token(token_dir, tenant):
    path = os.path.join(token_dir, '%s.token' % tenant)
    info = os.stat(path)
    if info.st_mode & (stat.S_IRWXG | stat.S_IRWXO):
        raise ValueError('%s must be readable only by its owner (mode 600)' % path)
    with open(path, encoding='utf-8') as f:
        token = f.read().strip()
    if not token:
        raise ValueError('%s is empty' % path)
    return token


def report_refresh(refresh):
    """The refresh's outcome, for the log and the email: counts, problems (line, field, what is wrong), warnings."""
    log('refresh %s: %s' % (refresh.get('refresh_id'), refresh.get('state')))
    for reason in refresh.get('reasons') or []:
        log('  reason: %s' % reason)
    check = refresh.get('check') or {}
    if check:
        log('  check: %s; %s rows; %s added, %s removed, %s changed; delta %s%% (threshold %s%%); %s problem(s)'
            % (check.get('result'), check.get('rows'), check.get('added'), check.get('removed'), check.get('changed'),
               check.get('delta_percent'), check.get('threshold_percent'), check.get('error_count')))
        for error in check.get('errors') or []:
            log('    line %s, %s: %s' % (error.get('line'), error.get('field'), error.get('problem')))
        for warning in check.get('warnings') or []:
            log('    warning: %s' % warning)
    update = refresh.get('update') or {}
    if update:
        log('  update: %s deleted, %s written, %s unchanged'
            % (update.get('deleted'), update.get('written'), update.get('unchanged')))


def run(tenant, work, serena):
    refreshes = '%s/museums/%s/refreshes' % (API, tenant)

    # 1. ping
    answer = serena.call('GET', API + '/ping')
    if answer.status != 200:
        raise SerenaError('ping: %s' % answer.problem())
    if answer.json.get('museum') != tenant:
        raise SerenaError('ping: the token belongs to %r, not %r' % (answer.json.get('museum'), tenant))
    log('ping: ok')

    # 2. the servable list, before a refresh is started, so a failure here leaves Serena untouched
    made = os.path.join(work, 'servable-list.%s.new.tsv' % tenant)
    if make_servable_list.main([tenant, made]) != 0:
        raise SerenaError('the servable list could not be made; no refresh was started')

    # 3. start a refresh; 409: Serena is busy with an earlier one
    deadline = time.monotonic() + DEFAULT_STEP_TIMEOUT_SECONDS
    while True:
        answer = serena.call('POST', refreshes)
        if answer.status in (200, 201):
            break
        if answer.status == 409 and time.monotonic() < deadline:
            log('start: %s; trying again in %gs' % (answer.problem(), DEFAULT_POLL_SECONDS))
            time.sleep(DEFAULT_POLL_SECONDS)
            continue
        raise SerenaError('start: %s' % answer.problem())
    refresh = answer.json
    refresh_path = '%s/%s' % (refreshes, refresh['refresh_id'])
    poll_seconds = refresh.get('poll_interval_seconds', DEFAULT_POLL_SECONDS)
    step_timeout = refresh.get('step_timeout_seconds', DEFAULT_STEP_TIMEOUT_SECONDS)
    log('start: %s (%s), state %s' % (refresh['refresh_id'], 'new' if answer.status == 201 else 'already open',
                                      refresh['state']))
    servable_list = os.path.join(work, os.path.basename(refresh['file_name']))
    os.replace(made, servable_list)

    # 4. upload
    with open(servable_list, 'rb') as f:
        data = f.read()
    rows = data.count(b'\n') - 1
    headers = {'Content-Type': 'text/tab-separated-values', 'Content-Encoding': 'gzip',
               'X-Row-Count': str(rows), 'X-Content-SHA256': hashlib.sha256(data).hexdigest()}
    answer = serena.call('PUT', refresh_path + '/servable-list', body=gzip.compress(data), headers=headers)
    if answer.status != 200:
        raise SerenaError('upload: %s' % answer.problem())
    log('upload: %s, %d rows, state %s' % (os.path.basename(servable_list), rows, answer.json.get('state')))

    # 5. check (and, when it passes, the servability update)
    answer = serena.call('POST', refresh_path + '/check')
    if answer.status not in (200, 202):
        raise SerenaError('check: %s' % answer.problem())
    refresh = answer.json
    log('check: requested, state %s' % refresh.get('state'))

    # 6. poll
    deadline = time.monotonic() + step_timeout
    while refresh.get('state') not in DONE:
        if time.monotonic() >= deadline:
            report_refresh(refresh)
            raise SerenaError('the refresh is still %s after %ds; carrying on without Serena'
                              % (refresh.get('state'), step_timeout))
        time.sleep(poll_seconds)
        answer = serena.call('GET', refresh_path)
        if answer.status != 200:
            raise SerenaError('poll: %s' % answer.problem())
        refresh = answer.json
    report_refresh(refresh)
    return refresh.get('state') == 'updated'


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if len(argv) != 2:
        print('Usage: serena_refresh.py <tenant> <work folder>', file=sys.stderr)
        return 2
    tenant, work = argv
    try:
        serena = Serena(os.environ['SERENA_BASE_URL'], read_token(os.environ['SERENA_TOKEN_DIR'], tenant), tenant)
    except KeyError as e:
        log('Serena %s: setting %s is missing' % (tenant, e))
        return 2
    except (OSError, ValueError) as e:
        log('Serena %s: %s' % (tenant, e))
        return 2
    os.makedirs(work, exist_ok=True)
    try:
        updated = run(tenant, work, serena)
    except SerenaError as e:
        log('Serena %s: FAILED: %s' % (tenant, e))
        return 1
    log('Serena %s: %s' % (tenant, 'updated' if updated else 'FAILED: the refresh was not updated'))
    return 0 if updated else 1


if __name__ == '__main__':
    sys.exit(main())
