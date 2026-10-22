#!/bin/bash

export BAMPFA_SERVER="localhost port=54321"
export BAMPFA_USER="bampfa"
export BAMPFA_CONTACT="osanchez@berkeley.edu"

export BOTGARDEN_SERVER="localhost port=54321"
export BOTGARDEN_USER="ucbg"
export BOTGARDEN_CONTACT="ucbg-cspace-bmu@berkeley.edu"

export CINEFILES_SERVER="localhost port=54321"
export CINEFILES_USER="cinefiles"
export CINEFILES_CONTACT="mcq@berkeley.edu"

export PAHMA_SERVER="localhost port=54321"
export PAHMA_USER="pahma"
export PAHMA_CONTACT="pahma-cspace-admin-notices@lists.berkeley.edu"

export UCJEPS_SERVER="localhost port=54321"
export UCJEPS_USER="ucjeps"
export UCJEPS_CONTACT="ucjeps-it@berkeley.edu"

export TECH_LEAD="jblowe@berkeley.edu"
export SUPPORT_CONTACT="cspace-support@lists.berkeley.edu"

# Serena, the new ImageServer (CSW-1027). Serena's team provides the base URL (without /etl/v1) and one
# token per museum. A museum's Serena step runs only when SERENA_TOKEN_DIR holds <tenant>.token: a file
# outside the repository, owned by the app user, mode 600 (like .pgpass). Never put a token in this file.
# SERENA_CONTACT: the addresses mailed when a Serena step fails (the ETL team); SUPPORT_CONTACT when empty.
# Museum contacts are never mailed about the Serena step.
export SERENA_BASE_URL=""
export SERENA_CONTACT=""
export SERENA_TOKEN_DIR="${HOME}/.serena"

source ${HOME}/set_platform.sh
