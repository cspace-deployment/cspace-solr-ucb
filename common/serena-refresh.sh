#!/usr/bin/env bash
#
# Hand a museum's servable list to Serena, the new ImageServer (Jira CSW-1027, Part 3).
#
# Called by oj.<tenant>.sh in the background, right after the museum's public Solr refresh. It never stops,
# delays or undoes the Solr refresh: a failure is logged and mailed to SERENA_CONTACT (SUPPORT_CONTACT when
# that is empty), and the job carries on. Museum contacts are never mailed about the Serena step.
#
# The token never appears in a log, an argument or an email: serena_refresh.py reads it from its file and sends
# it only in the Authorization header. Tracing stays off here, whatever the caller does.
#
# Runs only when the museum's token file, ${SERENA_TOKEN_DIR}/<tenant>.token, exists (with SERENA_BASE_URL set);
# otherwise it logs one line and skips. Holds ${SOLR_LOG_DIR}/<tenant>.serena.lock while it runs, so one_job.sh
# can wait for it at the end and two runs for one museum can't overlap.
#
# Usage: serena-refresh.sh <tenant>

set +x
set -uo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <tenant>" >&2
  exit 2
fi
TENANT=$1

# shellcheck source=/dev/null
source "${HOME}/pipeline-config.sh"

TOKEN_FILE="${SERENA_TOKEN_DIR:-}/${TENANT}.token"
if [[ -z "${SERENA_BASE_URL:-}" || -z "${SERENA_TOKEN_DIR:-}" || ! -f "${TOKEN_FILE}" ]]; then
  echo "Serena ${TENANT}: skipped (no SERENA_BASE_URL or no token file for ${TENANT})"
  exit 0
fi

exec 9> "${SOLR_LOG_DIR}/${TENANT}.serena.lock"
if ! flock -n 9; then
  echo "Serena ${TENANT}: skipped (another Serena step for ${TENANT} is still running)"
  exit 0
fi

CONTACT="${SERENA_CONTACT:-}"
if [[ -z "${CONTACT}" ]]; then
  CONTACT="${SUPPORT_CONTACT:-}"
fi
WORK="${HOME}/solrdatasources/${TENANT}/serena"
REPORT="$(mktemp)"
trap 'rm -f "${REPORT}"' EXIT

python3 "$(dirname "${BASH_SOURCE[0]}")/serena_refresh.py" "${TENANT}" "${WORK}" > "${REPORT}" 2>&1
status=$?
cat "${REPORT}"

if [[ ${status} -ne 0 ]]; then
  # shellcheck disable=SC2086  # the contacts may be several addresses
  mail -r "cspace-support@lists.berkeley.edu" -s "PROBLEM ${TENANT} Serena refresh failed" -- \
    ${CONTACT} < "${REPORT}"
fi
exit ${status}
