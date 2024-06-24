#!/usr/bin/env bash

source ${HOME}/pipeline-config.sh

${HOME}/solrdatasources/pahma/solrETL-public.sh            pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.solr_extract_public.log  2>&1
${HOME}/solrdatasources/pahma/solrETL-internal.sh          pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.solr_extract_internal.log  2>&1
${HOME}/solrdatasources/pahma/solrETL-locations.sh         pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.solr_extract_locations.log  2>&1
# ${HOME}/solrdatasources/pahma/solrETL-osteology.sh         pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.solr_extract_osteology.log  2>&1
