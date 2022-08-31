#!/bin/bash

export BAMPFA_SERVER="dba-postgres-prod-45.ist.berkeley.edu port=5313"
export BAMPFA_USER="reporter_bampfa"
export BAMPFA_CONTACT="osanchez@berkeley.edu"

export BOTGARDEN_SERVER="dba-postgres-prod-45.ist.berkeley.edu port=5313"
export BOTGARDEN_USER="reporter_botgarden"
export BOTGARDEN_CONTACT="ucbg-cspace-bmu@berkeley.edu"

export CINEFILES_SERVER="dba-postgres-prod-45.ist.berkeley.edu port=5313"
export CINEFILES_USER="reporter_cinefiles"
export CINEFILES_CONTACT="mcq@berkeley.edu"

# for cinefiles denorm script
export CINEFILES_PGHOST="dba-postgres-prod-45.ist.berkeley.edu"
export CINEFILES_PGUSER="nuxeo_cinefiles"
export CINEFILES_PGPORT=5313

export PAHMA_SERVER="dba-postgres-prod-45.ist.berkeley.edu port=5307"
export PAHMA_USER="reporter_pahma"
export PAHMA_CONTACT="mtblack@berkeley.edu"

export UCJEPS_SERVER="dba-postgres-prod-45.ist.berkeley.edu port=5310"
export UCJEPS_USER="reporter_ucjeps"
export UCJEPS_CONTACT="ucjeps-it@berkeley.edu"

export SUPPORT_CONTACT="cspace-support@berkeley.edu"

source ${HOME}/set_platform.sh
