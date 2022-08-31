#!/bin/bash -x
date
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=media
SERVER="${UCJEPS_SERVER}"
USERNAME="${UCJEPS_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${UCJEPS_CONTACT}"
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# get media
##############################################################################
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f ucjepsNewMedia.sql -o newmedia.csv
time perl -i -pe 's/[\r\n]/ /g;s/\@\@/\n/g' newmedia.csv
perl -ne 's/\\/x/g; next if / rows\)/; print $_' newmedia.csv > 4solr.${TENANT}.${CORE}.csv
##############################################################################
# get rid of intermediate files
##############################################################################
rm newmedia.csv
##############################################################################
# OK, we are good to go! clear out the existing data and reload
##############################################################################
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT} 19000 8
date
