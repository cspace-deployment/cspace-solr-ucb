# shellcheck shell=bash
# The Serena step (CSW-1027, Part 3) against a stand-in for Serena's ETL API and Solr: a refresh that is updated,
# a failed check, Serena busy (409) and unavailable (503) for a moment, a refresh still checking at the step
# timeout, a token for another museum, no servable list, a token file others can read, Serena unreachable, a
# base URL that isn't https; then serena-refresh.sh: skipped without a token, mail only on failure, to
# SERENA_CONTACT or else SUPPORT_CONTACT, never the museum's contact.

export PYTHONUNBUFFERED=1 SERENA_POLL_SECONDS=0 SERENA_RETRY_DELAY_SECONDS=0
mkdir -p tokens
printf 'test-token-0123456789abcdefghijklmnopqrstuvwxyz\n' > tokens/pahma.token
chmod 600 tokens/pahma.token
export SERENA_TOKEN_DIR="${PWD}/tokens"
echo docs.jsonl > solr-docs.txt
echo ok > scenario.txt

python3 stub_server.py &
stub=$!
trap 'kill "${stub}" 2>/dev/null' EXIT
for _ in $(seq 50); do [[ -s port.txt ]] && break; sleep 0.1; done
port="$(cat port.txt)"
export SOLR_URL="http://127.0.0.1:${port}/solr" SERENA_BASE_URL="http://127.0.0.1:${port}"

step() {
  echo "== $1"
  echo "== $1" >> requests.txt
  echo "$1" > scenario.txt
  python3 "$REPO/common/serena_refresh.py" pahma work 2>&1 \
    | sed -E -e 's/\[Errno [0-9]+\]/[Errno N]/' -e "s|${PWD}|.|g"
  echo "exit ${PIPESTATUS[0]}"
}

step ok
step check-fails
step busy
step stuck
step wrong-museum

echo bad-docs.jsonl > solr-docs.txt
step no-list
echo docs.jsonl > solr-docs.txt

chmod 644 tokens/pahma.token
step token-readable-by-others
chmod 600 tokens/pahma.token

SERENA_BASE_URL="http://127.0.0.1:1" step unreachable
SERENA_BASE_URL="http://serena.example.edu" step not-https

ls work

# serena-refresh.sh, with stand-ins for mail (and flock, where it isn't installed)
mkdir -p bin home/logs
# shellcheck disable=SC2016  # expanded by the stand-in, not here
printf '#!/bin/sh\n{ echo "mail $*"; cat; } >> "$HOME/mail.txt"\n' > bin/mail
command -v flock > /dev/null || printf '#!/bin/sh\nexit 0\n' > bin/flock
chmod +x bin/*
cat > home/pipeline-config.sh <<CONFIG
export SOLR_LOG_DIR="${PWD}/home/logs"
export PAHMA_CONTACT="pahma-contact@example.edu"
export SUPPORT_CONTACT="support@example.edu"
export SERENA_CONTACT="\${SERENA_CONTACT_FOR_TEST:-}"
CONFIG
wrapper() {
  echo "== serena-refresh.sh: $1"
  echo "== serena-refresh.sh: $1" >> requests.txt
  echo "$1" > scenario.txt
  PATH="${PWD}/bin:${PATH}" HOME="${PWD}/home" "$REPO/common/serena-refresh.sh" pahma 2>&1 \
    | grep -E '^(Serena|refresh)'
  echo "exit ${PIPESTATUS[0]}"
}
SERENA_TOKEN_DIR="${PWD}/no-tokens" wrapper ok
wrapper ok
wrapper check-fails
SERENA_CONTACT_FOR_TEST="etl-team@example.edu" wrapper check-fails
echo "== mail"
sed "s|${PWD}|.|g" home/mail.txt
ls home/logs
