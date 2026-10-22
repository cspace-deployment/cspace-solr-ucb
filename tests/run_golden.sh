#!/usr/bin/env bash
#
# Golden-file (characterization) tests for the ETL transform helpers.
#
# Each case lives in tests/golden/<case>/ and contains:
#   run.sh     commands to run; executed with bash from a scratch copy of input/,
#              with REPO set to the repository root
#   input/     synthetic input files (never real collection data)
#   expected/  the files that must match after run.sh finishes. stdout and
#              stderr of run.sh are captured as stdout.txt and stderr.txt;
#              only files present in expected/ are compared.
#
# Usage:
#   tests/run_golden.sh [case ...]            run all (or the named) cases
#   tests/run_golden.sh --update [case ...]   regenerate expected/ from current code
#
# With --update, only files already in expected/ are rewritten (plus stdout.txt
# if expected/ is empty), so choose what a case checks by adding or removing
# files in expected/. Always review the diff after updating.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GOLDEN="${REPO}/tests/golden"
export REPO
export PYTHONDONTWRITEBYTECODE=1
export LC_ALL=C.UTF-8
export TZ=UTC

update=0
if [[ "${1:-}" == "--update" ]]; then
  update=1
  shift
fi

if [[ $# -gt 0 ]]; then
  cases=("$@")
else
  cases=()
  for d in "${GOLDEN}"/*/; do
    cases+=("$(basename "${d}")")
  done
fi

scratch="$(mktemp -d)"
trap 'rm -rf "${scratch}"' EXIT

pass=0
fail=0
failed=()

for c in "${cases[@]}"; do
  casedir="${GOLDEN}/${c}"
  if [[ ! -f "${casedir}/run.sh" ]]; then
    echo "MISSING ${c}: no run.sh"
    fail=$((fail + 1))
    failed+=("${c}")
    continue
  fi
  work="${scratch}/${c}"
  mkdir -p "${work}"
  if [[ -d "${casedir}/input" ]]; then
    cp -R "${casedir}/input/." "${work}/"
  fi
  (cd "${work}" && bash "${casedir}/run.sh" > stdout.txt 2> stderr.txt)
  status=$?

  if [[ ${update} -eq 1 ]]; then
    mkdir -p "${casedir}/expected"
    if [[ -z "$(ls -A "${casedir}/expected")" ]]; then
      touch "${casedir}/expected/stdout.txt"
    fi
    for f in "${casedir}"/expected/*; do
      name="$(basename "${f}")"
      if [[ -f "${work}/${name}" ]]; then
        cp "${work}/${name}" "${f}"
      else
        echo "WARNING ${c}: run did not produce ${name}"
      fi
    done
    echo "UPDATED ${c} (exit ${status})"
    continue
  fi

  ok=1
  if [[ ${status} -ne 0 ]]; then
    echo "FAIL ${c}: run.sh exited with ${status}"
    sed 's/^/    /' "${work}/stderr.txt" | head -20
    ok=0
  fi
  for f in "${casedir}"/expected/*; do
    name="$(basename "${f}")"
    if [[ ! -f "${work}/${name}" ]]; then
      echo "FAIL ${c}: ${name} was not produced"
      ok=0
    elif ! diff -u "${f}" "${work}/${name}" > "${work}/.diff"; then
      echo "FAIL ${c}: ${name} differs from expected"
      head -40 "${work}/.diff" | sed 's/^/    /'
      ok=0
    fi
  done
  if [[ ${ok} -eq 1 ]]; then
    echo "ok   ${c}"
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    failed+=("${c}")
  fi
done

if [[ ${update} -eq 1 ]]; then
  exit 0
fi

echo
echo "${pass} passed, ${fail} failed"
if [[ ${fail} -gt 0 ]]; then
  printf '  %s\n' "${failed[@]}"
  exit 1
fi
