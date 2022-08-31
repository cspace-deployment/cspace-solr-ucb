#!/usr/bin/env bash
#
# redeploy the Solr ETL from github
#
if [[ $# -ne 2 ]] ;
then
  echo
  echo "Usage: $0 <version> <environment>"
  echo
  echo "environment is one of 'dev', 'qa', 'prod'"
  echo "version is like 6.2.0-rc9 or 6.2.0 or latest (meaning 'tip of main branch', not an actual tag)"
  echo
  exit 1
fi

cd
SOLRETLDIR=${HOME}/solrdatasources
SOLR_REPO=${HOME}/cspace-solr-ucb
ENVIRONMENT=$2
# check to see we are plausibly able to do something...
if [ ! -d ${SOLR_REPO} ]
then
   echo "Solr repo ${SOLR_REPO} not found in this directory. Please clone into home dir from GitHub."
   exit 1
fi

cd ${SOLR_REPO}

# deploy fresh code from github
git checkout main
git pull -v
if [[ $1 != 'latest' ]]; then
  git -c advice.detachedHead=false checkout $1
fi
if [ $? -ne 0 ]
then
  echo "Could not check out $1 from github. Please try again."
  exit 1
fi

# select correct config file for this environment
if [ ! -e pipeline-config-${ENVIRONMENT}.sh ]
then
   echo "Solr config file pipeline-config-${ENVIRONMENT}.sh not found in this directory."
   echo "Should be one of prod/qa/dev; please try again."
   exit 1
else
  cp pipeline-config-${ENVIRONMENT}.sh ${HOME}/pipeline-config.sh
fi

cp utilities/o*.sh ${HOME}
cp utilities/checkstatus.sh ${HOME}
cp utilities/set_platform.sh ${HOME}

if [ ! -d ${SOLRETLDIR} ]
then
   echo "Solr ETL directory ${SOLRETLDIR} not found. Assuming this is a fresh install"
else
    # make a backup of the current ETL directory just in case
    YYYYMMDDHHMM=`date +%Y%m%d%H%M`
    BACKUPDIR=${SOLRETLDIR}.${YYYYMMDDHHMM}
    if [ -d ${BACKUPDIR} ];
    then
       echo "Backup ETL directory ${BACKUPDIR} already exists. Please move or remove it and try again"
       exit 1
    fi
    mv ${SOLRETLDIR} ${BACKUPDIR}
fi

mkdir ${SOLRETLDIR}

cd
rsync -a --exclude .git --exclude .gitignore --exclude solr-cores --exclude utilities ${SOLR_REPO}/ ${SOLRETLDIR}/

# try to put botgarden's pickle file back; it takes hours to recreate from scratch.
if [ ! -f ${BACKUPDIR}/botgarden/gbif/names.pickle ]
then
    echo "${BACKUPDIR}/botgarden/gbif/names.pickle not found. UCBG refresh will try to rebuild it from scratch"
    echo "which takes about 8-10 hours; consider finding a copy and putting it where it belongs"
else
    cp ${BACKUPDIR}/botgarden/gbif/names.pickle ${SOLRETLDIR}/botgarden/gbif
fi
echo
echo "Solr ETL ppipeline deploy complete."
echo
echo "Double-check configuration of code in ${HOME}/pipeline-config.sh!"
