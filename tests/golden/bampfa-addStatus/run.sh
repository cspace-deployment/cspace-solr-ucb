# shellcheck shell=bash
perl "$REPO/bampfa/addStatus.pl" public 37 38 < d4.csv > out.public.csv
perl "$REPO/bampfa/addStatus.pl" internal 37 38 < d4.csv > out.internal.csv
