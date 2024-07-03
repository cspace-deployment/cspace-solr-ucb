#!/usr/bin/env bash
#
# create the current set of cURL commands that will refresh
# the Solr cores from the extracted .csv files.
#
# (3 curls for each core: delete, commit, POST fresh data)
#
rm -f allcurls.sh
for TENANT in bampfa botgarden cinefiles pahma ucjeps
do
    for CORE in public internal propagations locations media
    do
       FILE_PART=${CORE}
       if [[ -e ${HOME}/solrdatasources/${TENANT}/uploadparms.${TENANT}.${FILE_PART}.txt ]]
       then
          echo "# ${TENANT}-${CORE}" >> allcurls.sh
          echo "curl -S -s http://localhost:8983/solr/${TENANT}-${CORE}/update --data '<delete><query>*:*</query></delete>' -H 'Content-type:text/xml; charset=utf-8'" >> allcurls.sh
          echo "curl -S -s http://localhost:8983/solr/${TENANT}-${CORE}/update --data '<commit/>' -H 'Content-type:text/xml; charset=utf-8'" >> allcurls.sh
          ss_string=`cat ${HOME}/solrdatasources/${TENANT}/uploadparms.${TENANT}.${FILE_PART}.txt`
          SOLRCMD="http://localhost:8983/solr/${TENANT}-${CORE}/update/csv?commit=true&header=true&trim=true&separator=%09&${ss_string}&encapsulator=\\"
          echo "time curl -X POST -S -s '$SOLRCMD' -H 'Content-type:text/plain; charset=utf-8' -T 4solr.${TENANT}.${FILE_PART}.csv" >> allcurls.sh
       fi
    done
done
chmod +x allcurls.sh
