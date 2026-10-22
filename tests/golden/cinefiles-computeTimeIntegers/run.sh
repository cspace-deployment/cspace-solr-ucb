# shellcheck shell=bash
python3 "$REPO/cinefiles/computeTimeIntegersCineFiles.py" docs.csv < d1a.csv
python3 "$REPO/cinefiles/computeTimeIntegersCineFiles.py" films.csv < d1b.csv
