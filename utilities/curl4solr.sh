#!/usr/bin/env bash
#
# fetches all the *publicly* available solr4 datasources
#
# NB: only work with current UCB setup.
#     extracts are "manually curated" on Prod, and may not be the latest.
#
# see also 'wget4solr.sh', same thing with wget.
#
# no authentication required!
curl -O https://webapps.cspace.berkeley.edu/4solr.bampfa.public.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.botgarden.propagations.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.botgarden.public.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.cinefiles.public.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.cinefiles.films.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.pahma.locations.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.pahma.allmedia.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.pahma.public.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.ucjeps.media.csv.gz
curl -O https://webapps.cspace.berkeley.edu/4solr.ucjeps.public.csv.gz
