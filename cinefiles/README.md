This is the prototype solr4 datasource ETL for CineFiles.

It does the following:

* Extracts metadata and media CSIDs from CSpace
* Massages the extract to make sure it will load into solr4
* Loads it into the cinefiles-public solr4 core, which is assumed to be up and available on localhost.

Run it the usual way:

nohup time ./solrETL-public.sh cinefiles &

(Takes a few minutes to run at the moment...)