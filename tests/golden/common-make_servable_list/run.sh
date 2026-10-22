# shellcheck shell=bash
# The servable list script (CSW-1027): from a file of documents, from a stand-in for Solr (cursorMark paging),
# and with problems (nothing written).

python3 "$REPO/common/make_servable_list.py" pahma from-file.tsv --docs docs.jsonl

python3 stub_solr.py &
stub=$!
trap 'kill "${stub}" 2>/dev/null' EXIT
for _ in $(seq 50); do [[ -s port.txt ]] && break; sleep 0.1; done
SOLR_URL="http://127.0.0.1:$(cat port.txt)/solr" "$REPO/common/make-servable-list.sh" pahma from-solr.tsv
cmp from-file.tsv from-solr.tsv && echo "from Solr: the same list"
sed 's/^\/solr\/pahma-public\/select //' requests.log > requests.txt

python3 "$REPO/common/make_servable_list.py" pahma bad.tsv --docs bad-docs.jsonl 2> problems.txt \
  || echo "bad documents: exit $?"
[[ -e bad.tsv ]] || echo "bad.tsv not written"

python3 "$REPO/common/make_servable_list.py" bampfa x.tsv --docs docs.jsonl 2>> problems.txt \
  || echo "unconfigured museum: exit $?"
"$REPO/common/make-servable-list.sh" pahma 2>> problems.txt || echo "usage: exit $?"
