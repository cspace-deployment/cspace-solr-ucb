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

# Serena, the new ImageServer (CSW-1027). Serena's team provides the base URL (without /etl/v1) and one
# token per museum. A museum's Serena step runs only when SERENA_TOKEN_DIR holds <tenant>.token: a file
# outside the repository, owned by the app user, mode 600 (like .pgpass). Never put a token in this file.
# SERENA_CONTACT: the addresses mailed when a Serena step fails (the ETL team); SUPPORT_CONTACT when empty.
# Museum contacts are never mailed about the Serena step.
export SERENA_BASE_URL=""
export SERENA_CONTACT=""
export SERENA_TOKEN_DIR="${HOME}/.serena"

source ${HOME}/set_platform.sh
