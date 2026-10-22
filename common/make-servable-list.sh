#!/usr/bin/env bash
#
# Make a museum's servable list for Serena, the new ImageServer (Jira CSW-1027), from its live public core.
# Runs on its own at any time; see make_servable_list.py for the format and exit status.
#
# Usage: make-servable-list.sh <tenant> <output file>
# Solr: $SOLR_URL (default http://localhost:8983/solr)

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $(basename "$0") <tenant> <output file>" >&2
  exit 2
fi

exec python3 "$(dirname "${BASH_SOURCE[0]}")/make_servable_list.py" "$1" "$2"
