#!/usr/bin/env bash
#
# get all publicly available cores from publicly available sources
#
# NB: only work with current UCB setup.
#     extracts are "manually curated" on Prod, and may not be the latest.
#
# see also 'scp4solr.sh' to get all extracts, with authentication
#
#wget https://webapps.cspace.berkeley.edu/4solr.bampfa.internal.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.bampfa.public.csv.gz
#wget https://webapps.cspace.berkeley.edu/4solr.botgarden.internal.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.botgarden.media.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.botgarden.propagations.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.botgarden.public.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.cinefiles.public.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.cinefiles.films.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.pahma.allmedia.csv.gz
#wget https://webapps.cspace.berkeley.edu/4solr.pahma.internal.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.pahma.locations.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.pahma.media.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.pahma.public.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.ucjeps.media.csv.gz
wget https://webapps.cspace.berkeley.edu/4solr.ucjeps.public.csv.gz
