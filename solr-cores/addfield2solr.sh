#!/usr/bin/env bash

# drop and then recreate all UCB Solr cores based on the content of this script
# and the default configuration available in solr default configsets

# this script inspired by https://github.com/Brown-University-Library/bul-traject/blob/master/solr7/define_schema.sh
# thanks!

# for solr as deployed on my laptop
# SOLR_CMD=${HOME}/solr/bin/solr

# for solr as deployed on RTL-managed Ubuntu servers
SOLR_CMD=/opt/solr/bin/solr

SOLR_PORT="8983"

SOLR_CORE="bampfa-public
bampfa-internal
botgarden-public
botgarden-internal
botgarden-propagations
cinefiles-public
pahma-public
pahma-internal
pahma-locations
ucjeps-public
ucjeps-media
"

if [ $# -ne 2 ]; then
    echo "need two arguments: SOLR_CORE DYNAMIC_FIELD_NAME"
    exit 1
fi

SOLR_CORE="$1"
SOLR_CORE_URL="http://localhost:$SOLR_PORT/solr/$SOLR_CORE"
SOLR_RELOAD_URL="http://localhost:$SOLR_PORT/solr/admin/cores?action=RELOAD&core=$SOLR_CORE"

# something like xxx_ss -> xxx_txt
field_name="$2"
txt_field_name=${field_name%_*}_txt

function copy_fields()
{
    # ====================
    # Copy fields
    # ====================

    echo "Making copyField for $1 $2 ..."
    curl -s -S -X POST -H 'Content-type:application/json' --data-binary "{
      \"add-copy-field\":{
        \"source\": \"$1\",
        \"dest\": [ \"$2\" ]}
    }" $SOLR_CORE_URL/schema
}

echo "$SOLR_RELOAD_URL"

echo "Loading new config..."
copy_fields $field_name $txt_field_name

echo "Reloading core ${SOLR_CORE}..."
curl -s -S "$SOLR_RELOAD_URL"

# ====================
# Use this to export all the *actual* fields defined in the code
# *after* importing data
#
# curl -s -S $SOLR_CORE_URL/admin/luke?numTerms=0 > $SOLR_CORE_URL.luke7.xml
# ====================
