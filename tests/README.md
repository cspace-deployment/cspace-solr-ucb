# Tests

## Golden-file tests for the ETL transform helpers

`tests/run_golden.sh` runs characterization tests for the standalone Perl and
Python helpers that the `solrETL-*.sh` pipelines call (merge objects and media,
compute `_i` year fields, fix dates, set view status, obfuscate archaeology
site coordinates, etc.). Each test feeds a small synthetic input through the
helper exactly as the pipeline invokes it, then compares the output with a
checked-in expected copy.

The expected files record what the code does **today**, including some odd
behavior (see "Known quirks" below). Their purpose is to make refactoring safe:
if a change alters any output byte, a test fails and the diff shows what changed.

```bash
tests/run_golden.sh                       # run all cases
tests/run_golden.sh pahma-join            # run one or more named cases
tests/run_golden.sh --update pahma-join   # re-record expected output from the current code
```

Requirements: `bash`, `perl`, `python3` (standard library only). No database or
Solr server is needed.

### Layout

```
tests/golden/<tenant>-<helper>/
  run.sh      commands to run; executed from a scratch copy of input/ with $REPO set
  input/      synthetic input files
  expected/   files compared after run.sh finishes; stdout.txt and stderr.txt
              hold run.sh's captured output. Only files present here are compared.
```

An empty `expected/stdout.txt` asserts that the helper prints nothing.
`stderr.txt` is only compared for Perl helpers and for Python helpers whose
stderr carries counts, because Python can emit version-specific warnings.

### Adding a case

1. Create `tests/golden/<name>/run.sh` and `input/` files.
2. Create empty files in `expected/` for each output you want checked.
3. Run `tests/run_golden.sh --update <name>`, then **read the recorded output**
   to confirm it's what you expect before committing.

### Fixture data

All fixture data is synthetic (`csid-001`, `obj-01`, `Site A`, ...). Do not copy
rows from production extracts into fixtures: this repo is public, and some
source data (for example, archaeological site locations and culturally
restricted objects) is sensitive.

### What's not covered yet

- The inline `perl -pe` / `perl -ne` one-liners inside the `solrETL-*.sh`
  drivers and `common/post_to_solr.sh` (header rewriting, lat/long filtering,
  collector-name parsing, etc.). These need extracting into scripts first.
- `pahma/osteology_analyzer.py` and `botgarden/gbif/parseAndInsertGBIFparts.py`
  (the latter needs `names.pickle`).
- SQL, `psql` extraction and the Solr POST itself.

### Known quirks captured by the expected output

Recorded as-is; fix them deliberately, in their own commits, re-recording the
affected expected files.

- `common/evaluate.py` prints error rows as a Python bytes repr (`b'...'`).
- `ucjeps/fixdate.pl` turns an empty timestamp in columns 35/64 into `Z`.
- `bampfa/computeTimeIntegersBAMPFA.py` falls back to the *verbatim made date*
  for every empty `_dt` column, including acquisition date; it also has
  unreachable code after `return ''`.
- `pahma/computeTimeIntegersPAHMA.py` blanks begin-years before 1695 but does
  not reject end-years in the future.
- The `mergeObjectsAndMedia.pl` scripts count the header row as metadata and
  append an unnamed blob column to it; `open ... || die` never dies
  (precedence bug), so a missing input file is silently treated as empty.
- `pahma/mergeObjectsAndMediaPAHMA.py` counts the media header row in `media`.
