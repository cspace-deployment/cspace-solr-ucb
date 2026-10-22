"""Make a museum's servable list for Serena, the new ImageServer (Jira CSW-1027), from its live public core.

The servable list names every Blob the public core links to, with the Media record Serena fetches it through, its
kind and who may see it. The contract is Serena's (ets-berkeley-edu/cspace-media-server, docs/design.md, The
servable list):

- tab-separated, UTF-8, lines ending in LF, header blob_csid, media_csid, kind, access;
- one row per Blob CSID in the museum's Blob fields, no more and no fewer;
- media_csid from blobmedia_ss, written by the museum's merge step; empty only for the museum's placeholder image;
- kind from the field the Blob came from; a Blob in several fields takes the first of pdf, 3D, card, image;
- access public or restricted, by the museum's rules.

Usage: python3 make_servable_list.py <tenant> <output file> [--docs <file>]

Reads the core <tenant>-public from Solr at $SOLR_URL (default http://localhost:8983/solr), paging with cursorMark.
With --docs, reads the documents from a file instead, one JSON object per line (for tests).

The list is written only if every row is valid; otherwise the problems go to stderr and nothing is written.
Exit status: 0 written; 1 not written, the list would have problems; 2 usage, Solr or file error.
"""
import argparse
import json
import os
import re
import sys
import tempfile
import urllib.parse
import urllib.request

HEADER = ['blob_csid', 'media_csid', 'kind', 'access']
CSID = re.compile(r'[A-Za-z0-9-]{1,64}')
KIND_ORDER = ['pdf', '3D', 'card', 'image', 'audio', 'video']  # a Blob in several fields takes the first
PAGE_ROWS = 2000
MAX_PROBLEMS = 20

# Per museum: the public core's Blob fields and their kinds, and the placeholder image's Blob CSID.
# The other museums are added when their merge steps write blobmedia_ss (CSW-1027, sub-task 2).
MUSEUMS = {
    'pahma': {
        'fields': {
            'blob_ss': 'image',
            'primaryimage_s': 'image',
            'card_ss': 'card',
            'd3_csid_ss': '3D',
            'audio_csid_ss': 'audio',
            'video_csid_ss': 'video',
        },
        'placeholder': '59a733dd-d641-4e1a-8552',
    },
}


class Problems:
    def __init__(self):
        self.count = 0
        self.listed = []

    def add(self, message):
        self.count += 1
        if len(self.listed) < MAX_PROBLEMS:
            self.listed.append(message)


def values(doc, field):
    """A field's values as a list, whether Solr returns it single- or multi-valued."""
    value = doc.get(field)
    if value is None:
        return []
    if isinstance(value, list):
        return [v for v in value if v != '']
    return [value] if value != '' else []


def solr_docs(tenant, fields):
    """Every document of the museum's live public core, paging with cursorMark."""
    base = os.environ.get('SOLR_URL', 'http://localhost:8983/solr').rstrip('/')
    url = '%s/%s-public/select' % (base, tenant)
    cursor = '*'
    while True:
        query = urllib.parse.urlencode({'q': '*:*', 'fl': ','.join(['id'] + fields), 'sort': 'id asc',
                                        'rows': PAGE_ROWS, 'cursorMark': cursor, 'wt': 'json'})
        with urllib.request.urlopen('%s?%s' % (url, query), timeout=120) as response:
            page = json.load(response)
        for doc in page['response']['docs']:
            yield doc
        next_cursor = page['nextCursorMark']
        if next_cursor == cursor:
            return
        cursor = next_cursor


def file_docs(path):
    with open(path, encoding='utf-8') as f:
        for line in f:
            if line.strip():
                yield json.loads(line)


def access_of(museum, doc, kind):
    """Today every PAHMA row is public. (Cinefiles' pdf rows will depend on code_s.)"""
    return 'public'


def build(museum, docs, problems):
    """The rows of the servable list, keyed by Blob CSID."""
    placeholder = museum.get('placeholder')
    kinds = {}  # blob -> set of kinds
    media = {}  # blob -> Media CSID
    access = {}  # blob -> access
    documents = 0
    for doc in docs:
        documents += 1
        doc_id = doc.get('id', '?')
        pairs = {}
        for value in values(doc, 'blobmedia_ss'):
            blob, sep, media_csid = value.partition(':')
            if not sep:
                problems.add('document %s: blobmedia_ss value %r has no ":"' % (doc_id, value))
                continue
            pairs[blob] = media_csid
        for field, kind in museum['fields'].items():
            for blob in values(doc, field):
                kinds.setdefault(blob, set()).add(kind)
                if blob == placeholder:
                    media_csid = ''  # never a Media CSID for the placeholder image (decision D256)
                elif blob in pairs and pairs[blob]:
                    media_csid = pairs[blob]
                else:
                    problems.add('document %s: Blob %s in %s has no Media CSID in blobmedia_ss'
                                 % (doc_id, blob, field))
                    continue
                if media.setdefault(blob, media_csid) != media_csid:
                    problems.add('document %s: Blob %s is paired with Media %s here and %s in another document'
                                 % (doc_id, blob, media_csid, media[blob]))
                row_access = access_of(museum, doc, kind)
                if access.get(blob) != 'restricted':
                    access[blob] = row_access
    rows = {}
    for blob, blob_kinds in kinds.items():
        kind = next(k for k in KIND_ORDER if k in blob_kinds)
        rows[blob] = (media.get(blob, ''), kind, access.get(blob, 'public'))
    for blob, (media_csid, _, _) in rows.items():
        if not CSID.fullmatch(blob):
            problems.add('Blob CSID %r is not 1 to 64 letters, digits and hyphens' % blob)
        if media_csid and not CSID.fullmatch(media_csid):
            problems.add('Media CSID %r (Blob %s) is not 1 to 64 letters, digits and hyphens' % (media_csid, blob))
    if documents == 0:
        problems.add('the core has no documents')
    return documents, rows


def write(rows, path):
    """Write the list atomically: a temporary file in the same folder, then rename."""
    folder = os.path.dirname(os.path.abspath(path))
    fd, temp = tempfile.mkstemp(prefix='.servable-list.', dir=folder)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='\n') as f:
            f.write('\t'.join(HEADER) + '\n')
            for blob in sorted(rows):
                f.write('\t'.join((blob,) + rows[blob]) + '\n')
        os.chmod(temp, 0o644)
        os.replace(temp, path)
    except BaseException:
        os.unlink(temp)
        raise


def main(argv=None):
    parser = argparse.ArgumentParser(description='Make a museum\'s servable list for Serena from its public core.')
    parser.add_argument('tenant', help='museum: %s' % ', '.join(sorted(MUSEUMS)))
    parser.add_argument('output', help='the servable list to write, e.g. servable-list.pahma.2026-10-22.tsv')
    parser.add_argument('--docs', help='read documents from this file (one JSON object per line), not Solr')
    args = parser.parse_args(argv)

    museum = MUSEUMS.get(args.tenant)
    if museum is None:
        print('make_servable_list: no servable list configuration for %r (configured: %s)'
              % (args.tenant, ', '.join(sorted(MUSEUMS))), file=sys.stderr)
        return 2
    fields = sorted(museum['fields']) + ['blobmedia_ss']
    source = args.docs or 'Solr core %s-public' % args.tenant
    docs = file_docs(args.docs) if args.docs else solr_docs(args.tenant, fields)
    problems = Problems()
    try:
        documents, rows = build(museum, docs, problems)
    except (OSError, ValueError, KeyError) as e:
        print('make_servable_list: could not read %s: %s' % (source, e), file=sys.stderr)
        return 2
    if problems.count:
        print('make_servable_list: %s not written: %d problem(s); the first %d:'
              % (args.output, problems.count, len(problems.listed)), file=sys.stderr)
        for message in problems.listed:
            print('  ' + message, file=sys.stderr)
        return 1
    try:
        write(rows, args.output)
    except OSError as e:
        print('make_servable_list: could not write %s: %s' % (args.output, e), file=sys.stderr)
        return 2
    counts = {}
    for _, kind, row_access in rows.values():
        counts[(kind, row_access)] = counts.get((kind, row_access), 0) + 1
    source = args.docs or 'Solr core %s-public' % args.tenant
    print('%s: %d rows from %d documents of %s' % (args.output, len(rows), documents, source))
    for (kind, row_access), n in sorted(counts.items()):
        print('  %s %s: %d' % (kind, row_access, n))
    return 0


if __name__ == '__main__':
    sys.exit(main())
