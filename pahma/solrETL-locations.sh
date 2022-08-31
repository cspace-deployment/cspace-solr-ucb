#!/bin/bash -x
#
##############################################################################
# shell script to extract multiple tabular data files from CSpace,
# prep them for load into Solr4 using the "csv datahandler"
##############################################################################
date
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=locations
SERVER="${PAHMA_SERVER}"
USERNAME="${PAHMA_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${PAHMA_CONTACT}"
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# extract locations, past and present, from CSpace
##############################################################################
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f locations1.sql -o m1.csv &
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f locations2.sql -o m2.csv &
wait
# cleanup newlines and crlf in data, then switch record separator.
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' m1.csv > m1a.csv &
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' m2.csv > m2a.csv &
wait
rm m1.csv m2.csv
##############################################################################
# stitch the two files together
##############################################################################
time sort m1a.csv > m1a.sort.csv &
time sort m2a.csv > m2a.sort.csv &
wait
rm m1a.csv m2a.csv
time join -j 1 -t $'\t' m1a.sort.csv m2a.sort.csv > m3.sort.csv
rm m1a.sort.csv m2a.sort.csv
##############################################################################
# we want to recover and use our "special" solr-friendly header, which got buried
##############################################################################
grep -P "^object_" m3.sort.csv > header4Solr.csv &
grep -v -P "^object_" m3.sort.csv > m4.csv &
wait
# add a sequential integer as the solr id
perl -i -pe '$i++;print $i . "\t"' m4.csv
perl -i -pe 's/^/id\t/' header4Solr.csv
cat header4Solr.csv m4.csv > m6.csv
rm m3.sort.csv m4.csv
##############################################################################
# check the final file
##############################################################################
time python3 ../common/evaluate.py m6.csv 4solr.${TENANT}.${CORE}.csv > /dev/null
###############################################################################
# get rid of intermediate files
###############################################################################
rm m6.csv header4Solr.csv
###############################################################################
## OK, we are good to go! clear out the existing data and reload
###############################################################################
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT}  3700000 67
date
