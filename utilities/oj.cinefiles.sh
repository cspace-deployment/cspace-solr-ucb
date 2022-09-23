#!/usr/bin/env bash

source ${HOME}/pipeline-config.sh

# we RTL no longer run the 'legacy denormalizing' script, LYRASIS does
# cd ${HOME}/solrdatasources/cinefiles ; /bin/bash -l -c './cinefiles_denorm_nightly.sh' | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/cinefiles.solr_extract_public.log  2>&1 ; cd
# run the regular pipeline that populates solr
${HOME}/solrdatasources/cinefiles/solrETL-public.sh        cinefiles 2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/cinefiles.solr_extract_public.log  2>&1
