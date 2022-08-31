#!/bin/bash -x
date
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=propagations
SERVER="${BOTGARDEN_SERVER}"
USERNAME="${BOTGARDEN_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${BOTGARDEN_CONTACT}"
export NUMFIELDS=28
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# extract propagations info from CSpace
##############################################################################
time psql  -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f botgardenPropagations.sql -o p1.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' p1.csv > p2.csv
time perl -ne 'print unless /\(\d+ rows\)/' p2.csv > p3.csv
time perl -ne '$x = $_ ;s/[^\t]//g; if (length eq $ENV{NUMFIELDS}) { print $x;} '     p3.csv > p4.csv &
time perl -ne '$x = $_ ;s/[^\t]//g; unless (length eq $ENV{NUMFIELDS}) { print $x;} ' p3.csv > errors.csv &
wait
# extract displayName from all refNames
perl -pe "s/urn:cspace:.*?.cspace.berkeley.edu:.*?:name(.*?):item:name(.*?)'(.*?)'/\3/g" p4.csv > p5.csv
head -1 p5.csv | perl -pe 's/\r//;s/\t/_s\t/g;s/_s//;s/$/_s/;' > header4Solr.csv
#tail -n +2 p5.csv | perl fixdate.pl > p7.csv
tail -n +2 p5.csv > p6.csv
cat header4Solr.csv p6.csv > 4solr.${TENANT}.${CORE}.csv
##############################################################################
# here are the solr csv update parameters needed for multivalued fields
##############################################################################
perl -pe 's/\t/\n/g' header4Solr.csv| perl -ne 'chomp; next unless /_ss/; next if /blob/; print "f.$_.split=true&f.$_.separator=%7C&"' > uploadparms.txt
##############################################################################
# get rid of intermediate files
##############################################################################
rm -f p?.csv header4Solr.csv
##############################################################################
# OK, we are good to go! clear out the existing data and reload
##############################################################################
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT}  20000 86
date
