#!/bin/bash

# for qa deployments, we send notification email to Cesar, for now

export BAMPFA_SERVER="localhost port=54321"
export BAMPFA_USER="bampfa"
export BAMPFA_CONTACT="cesarv.h@berkeley.edu"

export BOTGARDEN_SERVER="localhost port=54321"
export BOTGARDEN_USER="ucbg"
export BOTGARDEN_CONTACT="cesarv.h@berkeley.edu"

export CINEFILES_SERVER="localhost port=54321"
export CINEFILES_USER="cinefiles"
export CINEFILES_CONTACT="cesarv.h@berkeley.edu"

# for cinefiles denorm script
#export CINEFILES_PGHOST="localhost port=54321"
#export CINEFILES_PGUSER="nuxeo_cinefiles"
#export CINEFILES_PGPORT=5113

export PAHMA_SERVER="localhost port=54321"
export PAHMA_USER="pahma"
export PAHMA_CONTACT="cesarv.h@berkeley.edu"

export UCJEPS_SERVER="localhost port=54321"
export UCJEPS_USER="ucjeps"
export UCJEPS_CONTACT="cesarv.h@berkeley.edu"

export SUPPORT_CONTACT="cesarv.h@berkeley.edu"

source ${HOME}/set_platform.sh
