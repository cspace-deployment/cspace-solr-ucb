#!/bin/bash

# for qa and dev deployments, we send notification email to nobody

export BAMPFA_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5113"
export BAMPFA_USER="reporter_bampfa"
export BAMPFA_CONTACT="nobody@nowhere.edu"

export BOTGARDEN_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5113"
export BOTGARDEN_USER="reporter_botgarden"
export BOTGARDEN_CONTACT="nobody@nowhere.edu"

export CINEFILES_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5113"
export CINEFILES_USER="reporter_cinefiles"
export CINEFILES_CONTACT="nobody@nowhere.edu"

# for cinefiles denorm script
export CINEFILES_PGHOST="dba-postgres-dev-45.ist.berkeley.edu"
export CINEFILES_PGUSER="nuxeo_cinefiles"
export CINEFILES_PGPORT=5113

export PAHMA_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5107"
export PAHMA_USER="reporter_pahma"
export PAHMA_CONTACT="nobody@nowhere.edu"

export UCJEPS_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5110"
export UCJEPS_USER="reporter_ucjeps"
export UCJEPS_CONTACT="nobody@nowhere.edu"

export SUPPORT_CONTACT="nobody@nowhere.edu"

source ${HOME}/set_platform.sh
