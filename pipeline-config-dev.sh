#!/bin/bash

# for dev deployments, we send notification email to nobody

export BAMPFA_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5114"
export BAMPFA_USER="reporter_bampfa"
export BAMPFA_CONTACT="nobody@nowhere.edu"

export BOTGARDEN_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5114"
export BOTGARDEN_USER="reporter_botgarden"
export BOTGARDEN_CONTACT="nobody@nowhere.edu"

export CINEFILES_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5114"
export CINEFILES_USER="reporter_cinefiles"
export CINEFILES_CONTACT="nobody@nowhere.edu"

# for cinefiles denorm script
export CINEFILES_PGHOST="dba-postgres-dev-45.ist.berkeley.edu"
export CINEFILES_PGUSER="nuxeo_cinefiles"
export CINEFILES_PGPORT=5114

export PAHMA_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5117"
export PAHMA_USER="reporter_pahma"
export PAHMA_CONTACT="nobody@nowhere.edu"

export UCJEPS_SERVER="dba-postgres-dev-45.ist.berkeley.edu port=5119"
export UCJEPS_USER="reporter_ucjeps"
export UCJEPS_CONTACT="nobody@nowhere.edu"

export TECH_LEAD="nobody@nowhere.edu"
export SUPPORT_CONTACT="nobody@nowhere.edu"

source ${HOME}/set_platform.sh
