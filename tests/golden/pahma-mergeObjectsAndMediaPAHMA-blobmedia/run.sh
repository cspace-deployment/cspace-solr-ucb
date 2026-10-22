# shellcheck shell=bash
# blobmedia_ss (CSW-1027): Blobs shared between objects and Media records, restricted cards and primary images,
# a Media record without a Blob, and the US burial rule.
python3 "$REPO/pahma/mergeObjectsAndMediaPAHMA.py" allmedia.csv temp.public.csv public d6a.csv
python3 "$REPO/pahma/mergeObjectsAndMediaPAHMA.py" allmedia.csv temp.internal.csv internal d6b.csv
