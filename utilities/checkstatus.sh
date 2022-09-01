#!/usr/bin/env bash

cd
source ${HOME}/pipeline-config.sh -q

for t in bampfa botgarden cinefiles pahma ucjeps
do
    for d in public internal propagations locations media osteology
    do
       LOG=${SOLR_LOG_DIR}/${t}.solr_extract_${d}.log
       if [[ -e ${LOG} ]]
       then
           CORE="${t}-${d}"
           # TODO this 'error detection code' could still be a lot better!
           grep "`tail -1 $LOG | cut -c2-10`" $LOG | perl -ne 'print if /(ERROR|refresh aborted|giving up)/i' > ${t}.discrepancies.txt
           DATE=`tail -1 ${LOG} | perl -ne 'if (/(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/){print}else{print "PROBLEM: log file does not show a date as last line"}'`
           NUMFOUND=`curl -s -S "http://localhost:8983/solr/${t}-${d}/select?q=*%3A*&rows=0&wt=json&indent=true" | grep numFound | perl -pe 's/.*"numFound":(\d+),.*/\1 rows/;'`
           SOLR_STATUS=`grep '"status":' $LOG | tail -1 | perl -ne 'unless (/.status.:0/) {print "\nNon-zero status from Solr:\n$_"}'`
           if [ `echo "$DATE" | grep -q "PROBLEM"` ] || [ "$SOLR_STATUS" != "" ] || [ -s ${t}.discrepancies.txt ]
           then
               STATUS="PROBLEM"
           else
               STATUS="OK"
           fi
           if [ "-v" == "$1" ] || [ "${STATUS}" == "PROBLEM" ]
           then
               echo "${STATUS}: $CORE,$DATE,$NUMFOUND $STATUS"
               cat ${t}.discrepancies.txt
           fi
           rm ${t}.discrepancies.txt
       fi
    done
done
