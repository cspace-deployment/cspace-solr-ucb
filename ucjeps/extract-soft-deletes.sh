#!/bin/bash -x
#
# script to extract soft-deleted accession and email the list to those who need it.
#
date
source ${HOME}/pipeline-config.sh
TENANT=$1
cd ${HOME}/solrdatasources/${TENANT}
SERVER="${UCJEPS_SERVER}"
USERNAME="${UCJEPS_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${UCJEPS_CONTACT}"
##############################################################################
#
##############################################################################
time psql -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f list-deletes.sql -o ${TENANT}_soft-deletes.tab
# some fix up required, alas: data from cspace is dirty: contain csv delimiters, newlines, etc. that's why we used @@ as temporary record separator
time perl -i -pe 's/[\r\n]/ /g;s/\@\@/\n/g;s/\|/\t/g;' ${TENANT}_soft-deletes.tab
rm -f ${TENANT}_soft-deletes.tab.gz
gzip ${TENANT}_soft-deletes.tab
mail -A ${TENANT}_soft-deletes.tab.gz -r "cspace-support@lists.berkeley.edu" -s "${TENANT}_soft-deletes.tab.gz" -- ${CONTACT} < /dev/null
#
date
