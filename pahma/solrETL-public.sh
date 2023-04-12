#!/bin/bash -x
#
##############################################################################
# shell script to extract multiple tabular data files from CSpace,
# "stitch" them together (see join.py)
# prep them for load into solr using the "csv data import handler"
##############################################################################
date
##############################################################################
# note that in this case there are 4 nightly scripts, public, internal, and locations,
# and osteology. internal depends on data created by public, so this case has to be handled
# specially, and the scripts need to run in order: public > internal > locations
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=public
SERVER="${PAHMA_SERVER}"
USERNAME="${PAHMA_USER}"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE sslmode=prefer"
CONTACT="${PAHMA_CONTACT}"
# field collection place ("FCP") is used in various calculations, set a
# variable to indicate which column it is in the extract
# (it has to be exported so the perl one-liner below can get the value from
# the environment; the value is used in 2 places below.)
export FCPCOL=39
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# run the "all media query"
##############################################################################
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f mediaAllImages.sql -o i4.csv
# cleanup newlines and crlf in data, then switch record separator.
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' i4.csv > 4solr.${TENANT}.allmedia.csv
rm i4.csv
##############################################################################
# start the stitching process: extract the "basic" data (both restricted and unrestricted)
##############################################################################
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f basic_restricted.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' | sort > basic_restricted.csv
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f basic_all.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' | sort > basic_all.csv
##############################################################################
# stitch this together with the results of the rest of the "subqueries"
##############################################################################
cp basic_restricted.csv restricted.csv
cp basic_all.csv internal.csv
# rather than refactor right now, use two sequences of queries for the public core...1 through 20, and 40 through 60.
for i in $(seq 1 1 20; seq 40 1 60)
do
 if [ -e part$i.sql ]; then
     time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f part$i.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' | sort > part$i.csv
     time python3 join.py restricted.csv part$i.csv > temp1.csv &
     time python3 join.py internal.csv part$i.csv > temp2.csv &
     wait
     mv temp1.csv restricted.csv
     mv temp2.csv internal.csv
 fi
done
##############################################################################
# these queries are for the internal datastore
##############################################################################
for i in {21..30}
do
 if [ -e part$i.sql ]; then
    time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f part$i.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' | sort > part$i.csv
    time python3 join.py internal.csv part$i.csv > temp.csv
    mv temp.csv internal.csv
 fi
done
##############################################################################
# recover the headers and put them back at the top of the file
##############################################################################
time grep -P "^id\t"  restricted.csv > header4Solr.csv &
time grep -v -P "^id\t" restricted.csv > d8.csv &
wait
cat header4Solr.csv d8.csv | perl -pe 's/␥/|/g' > restricted.csv
#
time grep -P "^id\t"  internal.csv > header4Solr.csv &
time grep -v -P "^id\t" internal.csv > d8.csv &
wait
cat header4Solr.csv d8.csv | perl -pe 's/␥/|/g' > internal.csv
##############################################################################
# internal.csv and restricted.csv contain the basic metadata for the internal
# and public portals respectively. We keep these around for debugging.
# no other accesses to the database are made after this point
#
# the script from here on uses only three files: these two and
# 4solr.${TENANT}.allmedia.csv, so if you wanted to re-run the next chunks of
# the ETL, you can use these files for that purpose.
##############################################################################
# check to see that each row has the right number of columns (solr will barf)
##############################################################################
time perl -pe 's/\r//g;s/\\/\//g;s/\t"/\t/g;s/"\t/\t/g;s/\"\"/"/g' restricted.csv > d6a.csv &
time perl -pe 's/\r//g;s/\\/\//g;s/\t"/\t/g;s/"\t/\t/g;s/\"\"/"/g' internal.csv > d6b.csv &
wait
time python3 ../common/evaluate.py d6a.csv temp.${CORE}.csv > ${TENANT}.counts.${CORE}.rawdata.csv &
time python3 ../common/evaluate.py d6b.csv temp.internal.csv > ${TENANT}.counts.internal.rawdata.csv &
wait
##############################################################################
# check latlongs for ${CORE} datastore
##############################################################################
perl -ne '@y=split /\t/;$x=$y[$ENV{"FCPCOL"}];print if     $x =~ /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/ || $x =~ /_p/ || $x eq "" ;' temp.${CORE}.csv >d6a.csv &
perl -ne '@y=split /\t/;$x=$y[$ENV{"FCPCOL"}];print unless $x =~ /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/ || $x =~ /_p/ || $x eq "" ;' temp.${CORE}.csv > ${TENANT}.counts.latlong_errors.csv &
##############################################################################
# check latlongs for internal datastore
##############################################################################
perl -ne '@y=split /\t/;$x=$y[$ENV{"FCPCOL"}];print if     $x =~ /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/ || $x =~ /_p/ || $x eq "" ;' temp.internal.csv > d6b.csv &
# nb: we don"t have to save the errors in this datastore, they will be the same as the restricted one.
wait
mv d6a.csv temp.${CORE}.csv
mv d6b.csv temp.internal.csv
##############################################################################
# add the blob and card csids and other flags to the rest of the metadata
# nb: has dependencies on the media file order; less so on the metadata.
##############################################################################
time python3 mergeObjectsAndMediaPAHMA.py 4solr.${TENANT}.allmedia.csv temp.${CORE}.csv public d6a.csv &
time python3 mergeObjectsAndMediaPAHMA.py 4solr.${TENANT}.allmedia.csv temp.internal.csv internal d6b.csv &
wait
mv d6a.csv temp.${CORE}.csv
mv d6b.csv temp.internal.csv
##############################################################################
#  compute a boolean: hascoords = yes/no
##############################################################################
time perl setCoords.pl ${FCPCOL} < temp.${CORE}.csv   > d6a.csv &
time perl setCoords.pl ${FCPCOL} < temp.internal.csv > d6b.csv &
wait
##############################################################################
#  Obfuscate the lat-longs of sensitive sites for public portal
#  nb: this script has dependencies on 4 columns in the input file.
#      if you change them or other order, you'll need to modify this script.
##############################################################################
time python3 obfuscateUSArchaeologySites.py d6a.csv d7.csv
##############################################################################
# clean up some outstanding sins perpetuated by obfuscateUSArchaeologySites.py
##############################################################################
time perl -i -pe 's/\r//g;s/\\/\//g;s/\t"/\t/g;s/"\t/\t/g;s/\"\"/"/g' d7.csv
##############################################################################
# we want to recover and use our "special" solr-friendly header, which got buried
##############################################################################
time grep -P "^id\t" d7.csv > header4Solr.csv &
time grep -v -P "^id\t" d7.csv > d8.csv &
wait
cat header4Solr.csv d8.csv | perl -pe 's/␥/|/g' > d9.csv
##############################################################################
# compute _i values for _dt values (to support BL date range searching)
##############################################################################
time python3 computeTimeIntegersPAHMA.py d9.csv 4solr.${TENANT}.${CORE}.csv > ${TENANT}.counts.date_hacks.csv &
#
time grep -P "^id\t" d6b.csv > header4Solr.csv &
time grep -v -P "^id\t" d6b.csv > d8.csv &
wait
cat header4Solr.csv d8.csv | perl -pe 's/␥/|/g' > d9.csv
##############################################################################
# compute _i values for _dt values (to support BL date range searching)
##############################################################################
time python3 computeTimeIntegers.py d9.csv 4solr.${TENANT}.internal.csv
##############################################################################
# check high water mark for storage use; get rid of intermediate files
##############################################################################
../common/check_space.sh
##############################################################################
# tidy up the many intermediate files
##############################################################################
rm d?.csv d6?.csv part*.csv temp.*.csv basic*.csv header4Solr.csv
rm internal.csv restricted.csv
##############################################################################
# save (hide) the internal extract so that the internal pipeline can find it
##############################################################################
gzip 4solr.${TENANT}.internal.csv
##############################################################################
# OK, we are good to go! clear out the existing data and reload
##############################################################################
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT}  720000 58
date
