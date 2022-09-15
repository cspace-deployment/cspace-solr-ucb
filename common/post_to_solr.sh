#!/usr/bin/env bash
# we only get SOLR_CACHE_DIR from here, the rest of the parms are passed in from caller
source ${HOME}/pipeline-config.sh
export TENANT=$1
export CORE=$2
export CONTACT=$3
# MINIMUM is an approximate lower bound on the number of rows there should
# be, based on data as of 2019-09-11. It may need to be periodically adjusted.
export MINIMUM=$4
export BLOB_COLUMN=$5
export FILE_PART=$6
# set by ${HOME}/set_platform.sh
export TEMP_DIR=${SOLR_CACHE_DIR}
##############################################################################
# show how much space, etc we have at this moment
##############################################################################
../common/check_space.sh
##############################################################################
# a helper function
##############################################################################
function notify()
{
  echo "$1"
  echo "$1" | mail -r "cspace-support@lists.berkeley.edu" -s "$2" -- ${CONTACT}
}
if [[ ! -d ${TEMP_DIR} ]]; then
  MSG="Could not find temporary directory ${TEMP_DIR}; refresh aborted, core left untouched."
  notify "${MSG}" "PROBLEM ${TENANT}-${CORE} nightly solr refresh failed: ${TEMP_DIR} missing"
  exit 1
fi
# nb: in general the name of the core and the name of the file are related.
# however, sometimes the same core may get refreshed with more than one file.
# ergo, we need to (optionally) distinguish CORE and FILE.
if [[ "${FILE_PART}" == "" ]]; then
  FILE_PART=${CORE}
fi
##############################################################################
# check if we have enough data to be worth refreshing...
##############################################################################
CSVFILE="4solr.${TENANT}.${FILE_PART}.csv"
if [[ ! -e ${CSVFILE} ]]; then
  MSG="Could not find ${CSVFILE} in this directory; refresh aborted, core left untouched."
  notify "${MSG}" "PROBLEM ${TENANT}-${CORE} nightly solr refresh failed: ${CSVFILE} missing"
  exit 1
fi
ROWS=`wc -l < ${CSVFILE}`
if (( ${ROWS} < ${MINIMUM} )); then
   MSG="Only ${ROWS} rows in ${CSVFILE}; refresh aborted, core left untouched."
   notify "${MSG}" "PROBLEM with ${TENANT}-${CORE} nightly solr refresh: not enough rows"
   exit 1
else
   echo "${ROWS} rows in ${CSVFILE}: so we have the number (${MINIMUM}) to proceed. Full speed ahead."
fi
##############################################################################
# count the types and tokens in the final file, check cell counts
##############################################################################
time python3 ../common/evaluate.py ${CSVFILE} /dev/null > ${TENANT}.counts.${FILE_PART}.csv &
# zap the existing core, if the file we are loading is the CORE file.
# (we might be loading several into this core)
if [ "${FILE_PART}" == "${CORE}" ]; then
  echo "this file is ${CSVFILE}, ergo, we zap solr/${TENANT}-${CORE} first..."
  curl -S -s "http://localhost:8983/solr/${TENANT}-${CORE}/update" --data '<delete><query>*:*</query></delete>' -H 'Content-type:text/xml; charset=utf-8'
  curl -S -s "http://localhost:8983/solr/${TENANT}-${CORE}/update" --data '<commit/>' -H 'Content-type:text/xml; charset=utf-8'
else
  echo "POSTing ${CSVFILE}, i.e. adding documents to existing solr/${TENANT}-${CORE} ..."
fi
##############################################################################
# generate the field splitting parameters for the post to solr
##############################################################################
head -1 ${CSVFILE} | sort | perl -pe 's/[\t\r]/\n/g' | perl -ne 'chomp; next unless /_(dt|s|i)s/; print "f.$_.split=true&f.$_.separator=%7C&"' > uploadparms.${TENANT}.${FILE_PART}.txt
ss_string=`cat uploadparms.${TENANT}.${FILE_PART}.txt`
SOLRCMD="http://localhost:8983/solr/${TENANT}-${CORE}/update/csv?commit=true&header=true&trim=true&separator=%09&${ss_string}&encapsulator=\\"
##############################################################################
# the heavy lifting starts...
##############################################################################
echo "time curl -X POST -S -s "${SOLRCMD}" -H 'Content-type:text/plain; charset=utf-8' -T ${CSVFILE}"
time curl -X POST -S -s "${SOLRCMD}" -H 'Content-type:text/plain; charset=utf-8' -T ${CSVFILE}
if [ $? != 0 ]; then
  MSG="Solr POST failed for ${TENANT}-${CORE}, file ${CSVFILE} ; retrying using previous successful upload"
  notify "${MSG}" "PROBLEM ${TENANT}-${CORE} nightly solr refresh failed"
  gunzip -k -f ${TEMP_DIR}/${CSVFILE}.gz
  time curl -X POST -S -s "$SOLRCMD" -H 'Content-type:text/plain; charset=utf-8' -T ${TEMP_DIR}/${CSVFILE}
  if [ $? != 0 ]; then
    MSG="Solr re-POST failed for ${TENANT}-${CORE}, file ${CSVFILE}; giving up and sending email."
    notify "${MSG}" "PROBLEM ${TENANT}-${CORE} nightly solr refresh from previous saved file (2nd attempt), failed too."
    exit 1
  else
    MSG="Solr re-POST succeed for ${TENANT}-${CORE}, file ${CSVFILE}."
    notify "${MSG}" "PROBLEM ${TENANT}-${CORE} nightly solr refreshed from previous saved file."
    exit 1
  fi
  # remove the gunzipped copy we made, but leave the original gzipped file
  rm ${TEMP_DIR}/${CSVFILE}
else
  ##############################################################################
  # the refresh succeeded.
  ##############################################################################
  # count rows, blobs, etc.
  ##############################################################################
  if [ ${BLOB_COLUMN} != 0 ]; then
    cut -f${BLOB_COLUMN} ${CSVFILE} | grep -v 'blob_ss' | perl -pe 's/\r//' |  grep . | wc -l > ${TENANT}.counts.${FILE_PART}.blobs.csv
    cut -f${BLOB_COLUMN} ${CSVFILE} | grep -v 'blob_ss' | perl -pe 's/\r//;s/,/\n/g;s/\|/\n/g;'| grep . | wc -l >> ${TENANT}.counts.${FILE_PART}.blobs.csv
    cp ${TENANT}.counts.${FILE_PART}.blobs.csv ${TEMP_DIR}/
    cat ${TENANT}.counts.${FILE_PART}.blobs.csv
  fi
  cp ${TENANT}.counts.${FILE_PART}.csv ${TEMP_DIR}/
  ##############################################################################
  # log the state of the .csv files
  ##############################################################################
  wc -l *.csv
  ##############################################################################
  # gzip and copy the successful extract to ${TEMP_DIR} in case we need it tomorrow.
  # (but first wait for any processes started earlier...)
  ##############################################################################
  wait
  gzip -f ${CSVFILE}
  mv ${CSVFILE}.gz ${TEMP_DIR}
  ##############################################################################
  # deal with statistics: move counts to apache public dir, email the errors off
  ##############################################################################
  cp ${TENANT}.counts.*.csv /var/www/static
  tar -czf counts.tgz ${TENANT}.counts.*.csv
  ../common/make_error_report.sh | mail -r "cspace-support@lists.berkeley.edu" -A counts.tgz -s "${TENANT} ${FILE_PART} Solr Refresh: Counts and Errors `date`" ${CONTACT}
fi
# tidy up: move all csv files to cache directory
mv *.csv ${TEMP_DIR}
