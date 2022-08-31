#!/bin/bash -x
date
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=public
SERVER="${BAMPFA_SERVER}"
USERNAME="${BAMPFA_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${BAMPFA_CONTACT}"
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# extract metadata and media info from CSpace
##############################################################################
# note this query included current location and current crate, which are
# removed later. The values are needed, however, to calculate viewing status
time psql -R"@@" -F $'\t' -A -U $USERNAME -d "$CONNECTSTRING"  -f metadata_public.sql -o d1.csv
# some fix up required, alas: data from cspace is dirty: contain csv delimiters, newlines, etc. that's why we used @@ as temporary record separator
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1.csv > d3.csv
##############################################################################
# check cell counts
##############################################################################
time python3 ../common/evaluate.py d3.csv d4.csv > ${TENANT}.counts.public.errors.csv
time psql -R"@@" -F $'\t' -A -U $USERNAME -d "$CONNECTSTRING" -f media_public.sql -o m1.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' m1.csv > media.csv
time psql -R"@@" -F $'\t' -A -U $USERNAME -d "$CONNECTSTRING" -f blobs.sql -o b1.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' b1.csv > blobs.csv
# Compute the "view status" of each object
time perl addStatus.pl ${CORE} 37 38 < d4.csv > metadata.csv
# make the header
head -1 metadata.csv > header4Solr.csv
# add the blob field name to the header (the header already ends with a tab); rewrite objectcsid_s to id (for solr id...)
perl -i -pe 's/\r//;s/\t/_s\t/g;s/objectcsid_s/id/;s/$/_s\tblob_ss/;s/_ss_s/_ss/g;s/_dt_s/_dt/g;' header4Solr.csv
# add the blobcsids to the rest of the data
time perl mergeObjectsAndMedia.pl media.csv metadata.csv > d6.csv
# we want to use our "special" solr-friendly header.
tail -n +2 d6.csv > d7.csv
cat header4Solr.csv d7.csv > d8.csv
##############################################################################
# compute _i values for _dt values (to support BL date range searching)
##############################################################################
time python3 computeTimeIntegersBAMPFA.py d8.csv 4solr.${TENANT}.${CORE}.csv
##############################################################################
# OK, we are good to go! clear out the existing data and reload
##############################################################################
# get rid of intermediate files
##############################################################################
rm d?.csv m?.csv b?.csv media.csv metadata.csv header4Solr.csv
# note: current location, current crate, appraised values have all been redacted
# in the sql queries themselves.
# some values were needed for computing the status field (i.e. "on view")
# TODO however we could also skip them in the Solr load as well...
# try to upload the file via POST/HTTP to Solr
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT}  22000 43
date
