#!/bin/bash -x
#
##############################################################################
# shell script to extract osteology data from database and prep them for load
# into Solr4 using the "csv datahandler"
##############################################################################
date
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=osteology
SERVER="${PAHMA_SERVER}"
USERNAME="${PAHMA_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${PAHMA_CONTACT}"
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# extract media info from CSpace
##############################################################################
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f osteology.sql -o o1.csv
# cleanup newlines and crlf in data, then switch record separator.
time perl -i -pe 's/[\r\n]/ /g;s/\@\@/\n/g' o1.csv
##############################################################################
# compress the osteology data into a single variable
##############################################################################
python3 osteology_analyzer.py o1.csv o2.csv
sort o2.csv > o3.csv
# add the internal data
cp ${SOLR_CACHE_DIR}/4solr.${TENANT}.internal.csv.gz .
gunzip 4solr.${TENANT}.internal.csv.gz
python3 join.py o3.csv 4solr.${TENANT}.internal.csv > o4.csv
# get rid of the copy we made
rm -f 4solr.${TENANT}.internal.csv
# csid_s is both files, let's keep only one in this file
cut -f1,3- o4.csv > o5.csv
##############################################################################
# we want to recover and use our "special" solr-friendly header, which got buried
##############################################################################
grep -P "^id\t" o5.csv > header4Solr.csv
grep -v -P "^id\t" o5.csv > o6.csv
cat header4Solr.csv o6.csv > o7.csv
##############################################################################
# count the types and tokens in the final file
##############################################################################
time python3 ../common/evaluate.py o7.csv 4solr.${TENANT}.${CORE}.csv > /dev/null
##############################################################################
rm o?.csv header4Solr.csv
##############################################################################
# OK, we are good to go! clear out the existing data and reload
##############################################################################
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT}  15000 67
date
