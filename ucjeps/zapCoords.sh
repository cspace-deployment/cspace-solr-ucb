source ${HOME}/pipeline-config.sh
cd ${HOME}/solrdatasources/ucjeps/
awk -F'\t' -v OFS="\t" '{$25 = ""; print}' ucjeps.counts.errors_in_latlong.csv > e2.csv
cat header4Solr.csv e2.csv > e3.csv
#cut -f3,25 e3.csv | expand -20
curl -X POST -S -s 'http://localhost:8983/solr/ucjeps-public/update/csv?commit=true&header=true&trim=true&separator=%09&f.comments_ss.split=true&f.comments_ss.separator=%7C&f.collector_ss.split=true&f.collector_ss.separator=%7C&f.previousdeterminations_ss.split=true&f.previousdeterminations_ss.separator=%7C&f.otherlocalities_ss.split=true&f.otherlocalities_ss.separator=%7C&f.associatedtaxa_ss.split=true&f.associatedtaxa_ss.separator=%7C&f.typeassertions_ss.split=true&f.typeassertions_ss.separator=%7C&f.alllocalities_ss.split=true&f.alllocalities_ss.separator=%7C&f.othernumber_ss.split=true&f.othernumber_ss.separator=%7C&f.blob_ss.split=true&f.blob_ss.separator=,&f.card_ss.split=true&f.card_ss.separator=,&encapsulator=\' -T e3.csv -H 'Content-type:text/plain; charset=utf-8'
rm e2.csv
rm e3.csv