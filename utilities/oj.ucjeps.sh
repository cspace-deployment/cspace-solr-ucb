#!/usr/bin/env bash

source ${HOME}/pipeline-config.sh

${HOME}/solrdatasources/ucjeps/solrETL-media.sh            ucjeps    2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/ucjeps.solr_extract_media.log  2>&1
${HOME}/solrdatasources/ucjeps/solrETL-public.sh           ucjeps    2>&1 | /usr/bin/ts '[%Y-%m-%d %H:%M:%S]' >> ${SOLR_LOG_DIR}/ucjeps.solr_extract_public.log  2>&1
