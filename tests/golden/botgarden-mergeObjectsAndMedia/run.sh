# shellcheck shell=bash
perl "$REPO/botgarden/mergeObjectsAndMedia.pl" media.csv metadata.csv public > out.public.csv 2> stderr.public.txt
perl "$REPO/botgarden/mergeObjectsAndMedia.pl" media.csv metadata.csv internal > out.internal.csv 2> stderr.internal.txt
