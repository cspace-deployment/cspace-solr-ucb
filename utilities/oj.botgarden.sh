#!/usr/bin/env bash

source ${HOME}/pipeline-config.sh

${HOME}/solrdatasources/botgarden/solrETL-public.sh        botgarden 2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/botgarden.solr_extract_public.log  2>&1
${HOME}/solrdatasources/botgarden/solrETL-internal.sh      botgarden 2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/botgarden.solr_extract_internal.log  2>&1
${HOME}/solrdatasources/botgarden/solrETL-propagations.sh  botgarden 2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/botgarden.solr_extract_propagations.log  2>&1
