# shellcheck shell=bash
python3 "$REPO/pahma/mergeObjectsAndMediaPAHMA.py" allmedia.csv temp.public.csv public d6a.csv
python3 "$REPO/pahma/mergeObjectsAndMediaPAHMA.py" allmedia.csv temp.internal.csv internal d6b.csv
