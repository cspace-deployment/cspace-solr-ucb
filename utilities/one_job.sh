#!/usr/bin/env bash
##################################################################################
#
# "One Job To Rule Them All"
#
##################################################################################
#
# run all solr ETL
#
# 1. run the 13 solr etl pipeline scripts, mostly in parallel
# 2. monitor solr datastore contents (i.e. email cspace-support, etc. if needed)
#
# some notes:
#
# in most cases, the jobs for each tenant must be ordered wrt to each other:
# e.g. the 'internal' cores often require data generated for the 'public' cores, etc.
#
# thus, the refreshes for a particular tenant must be run sequentially, i.e.
# not in parallel: they may overwrite files or otherwise conflict. there are no
# such conflicts *between* tenants, except for system resources such as cpu and
# memory.
#
# therefore, this version of one-job.sh runs the refresh for all 5 tenants in
# parallel, and waits for them all to finish.
#
# then does a bit of tidying up: solr optimize, check status of runs, etc.
##################################################################################
cd
source ${HOME}/pipeline-config.sh -q
echo 'starting solr refresh' `date` >> ${SOLR_LOG_DIR}/refresh.log
./oj.bampfa.sh
./oj.botgarden.sh
./oj.cinefiles.sh
./oj.pahma.sh
./oj.ucjeps.sh
##################################################################################
# gzip any ungzipped files in 'solr cache'
##################################################################################
gzip -f ${SOLR_CACHE_DIR}/*.csv
##################################################################################
# optimize all solrcores after refresh
# (nb: this seems to do little after solr v8, but leaving this here as a
# reminder to posterity that perhaps someday it might be useful again.
##################################################################################
# ${HOME}/optimize.sh > ${SOLR_LOG_DIR}/optimize.log
##################################################################################
# monitor solr datastores
##################################################################################
if [[ `${HOME}/checkstatus.sh` ]] ; then ${HOME}/checkstatus.sh -v | mail -r "cspace-support@lists.berkeley.edu" -s "PROBLEM with solr refresh nightly refresh" -- ${SUPPORT_CONTACT} ; fi
${HOME}/checkstatus.sh -v >> ${SOLR_LOG_DIR}/refresh.log
echo 'done with solr refresh' `date` >> ${SOLR_LOG_DIR}/refresh.log
