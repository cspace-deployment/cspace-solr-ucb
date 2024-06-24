#!/usr/bin/env bash

# echo "Solr Pipeline Discrepancies, checked  on `date`"
# echo

cd
source ${HOME}/pipeline-config.sh -q

for t in bampfa botgarden cinefiles pahma ucjeps
do
    for d in public internal propagations locations media
    do
       LOG=${SOLR_LOG_DIR}/${t}.solr_extract_${d}.log
       if [[ -e ${LOG} ]]
       then
           CORE="${t}-${d}"
           grep "`tail -1 $LOG | cut -c2-13`" $LOG > ${SOLR_LOG_DIR}/${t}.${d}.latest.log
           # TODO this 'error detection code' could still be a lot better!
           perl -ne 'print if /(ERROR\b|refresh aborted)/i' ${SOLR_LOG_DIR}/${t}.${d}.latest.log > ${SOLR_LOG_DIR}/${t}.${d}.discrepancies.log
           DATE=`tail -1 ${LOG} | perl -ne 'if (/(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/){print}else{print "PROBLEM: log file does not show a date as last line"}'`
           NUMFOUND=`curl -s -S "http://localhost:8983/solr/${t}-${d}/select?q=*%3A*&rows=0&wt=json&indent=true" | grep numFound | perl -pe 's/.*"numFound":(\d+),.*/\1 rows/;'`
           SOLR_STATUS=`grep '"status":' $LOG | tail -1 | perl -ne 'unless (/.status.:0/) {print "\nNon-zero status from Solr:\n$_"}'`
           if [[ "$DATE" == *"PROBLEM"* ]] || [ "$SOLR_STATUS" != "" ] || [ -s ${SOLR_LOG_DIR}/${t}.${d}.discrepancies.log ]
           then
               STATUS="PROBLEM"
           else
               STATUS="OK"
           fi
           if [ "-v" == "$1" ] || [ "${STATUS}" == "PROBLEM" ]
           then
               echo "${STATUS}: $CORE,$DATE,$NUMFOUND"
               cat ${SOLR_LOG_DIR}/${t}.${d}.discrepancies.log
           fi
           #rm ${SOLR_LOG_DIR}/${t}.${d}.discrepancies.log ${SOLR_LOG_DIR}/${t}.${d}.latest.log
       fi
    done
done
