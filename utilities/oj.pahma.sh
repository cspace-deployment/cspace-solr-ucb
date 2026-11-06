#!/usr/bin/env bash

source ${HOME}/pipeline-config.sh

${HOME}/solrdatasources/pahma/solrETL-public.sh            pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.solr_extract_public.log  2>&1
# Serena (CSW-1027): hand Serena the servable list, in the background so it never holds up the rest of the job.
# It skips unless SERENA_TOKEN_DIR holds pahma.token. one_job.sh waits for it at the end.
${HOME}/solrdatasources/common/serena-refresh.sh            pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.serena.log  2>&1 &
${HOME}/solrdatasources/pahma/solrETL-internal.sh          pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.solr_extract_internal.log  2>&1
${HOME}/solrdatasources/pahma/solrETL-locations.sh         pahma     2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/pahma.solr_extract_locations.log  2>&1
