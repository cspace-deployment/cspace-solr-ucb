#!/bin/bash
#
# Script for nightly update of cinefiles_denorm tables. Reads a list of
# SQL files (script.list) and submits each file in turn, via psql, to the
# Postgresql database.
#
# To minimize downtime, new tables are created with temporary names.
# After all of the tables have been successfully created, they are
# renamed in a single batch. Then, finally, one more batch file is
# executed to create indexes.
#
# This script should be installed in ${HOME}/solrdatasources/cinefiles/scripts
# SQL files go in ${HOME}/solrdatasources/cinefiles/scripts/sql/denorm_nightly
# Log files go in ${SOLR_LOG_DIR}
# NB: gets password for nuxeo_cinefiles from .pgpass

source ${HOME}/pipeline-config.sh

export BASEDIR=${HOME}/solrdatasources/cinefiles
export SCRIPTDIR=$BASEDIR/scripts
export PGUSER="${CINEFILES_PGUSER}"
export PGDATABASE=cinefiles_domain_cinefiles
export PGHOST="${CINEFILES_PGHOST}"
export PGPORT="${CINEFILES_PGPORT}"
export CONTACT="${CINEFILES_CONTACT}"

export SQLDIR="$SCRIPTDIR/sql/denorm_nightly"
export LOGDIR="${SOLR_LOG_DIR}"
export LOGFILE="$LOGDIR/cinefiles.denorm_nightly.log.$(date +'%d')"
export FOOFILE="$LOGDIR/cinefiles.solr_extract_public.log"
export LOGLEVEL=3

echo  "$(date): starting cinefiles_denorm_nightly" >> $FOOFILE

[ -d "$LOGDIR" ] && [ -n "$LOGFILE" ] && [ "$LOGLEVEL" -gt 0 ] && echo "Starting cinefiles_denorm_nightly at $(date)." > "$LOGFILE"

function notify
{
   echo "NOTIFY: $1" | mail -r "cspace-support@lists.berkeley.edu" -s "cinefiles denorm" ${CONTACT}
}

function log
{
   [ "$LOGLEVEL" -gt 0 ] && [ -f "$LOGFILE" ] && echo "$1" >> $LOGFILE
}

function trace
{
   [ "$LOGLEVEL" -gt 1 ] && [[ -t 0 ]] && echo "TRACE: $1"
   [ "$LOGLEVEL" -gt 2 ] && log "$1"
}

function exit_msg
{
   echo "$1" >&2
   notify "$1"
   exit 1
}

function stripws
{
   r=$(echo "$1 " | sed -e 's/^ *//' -e 's/ *$//')
   echo "${r###*}"
}

function comparetables
{
   re='^[0-9]+ [0-9]+$'
   c1=$1
   c2=$2
   [[ "$c1 $c2" =~ $re ]] && return 0
   return 1;
}

update_status=0
STATUSMSG="ALL DONE"
linecount=0

while read FILE
do
   linecount=$((linecount + 1))
   trace "${linecount}) READING: $FILE"

   SQLFILE="$(stripws "$FILE")"
   [ -n "$SQLFILE" ] || continue

   trace "USING: $(ls -l ${SQLDIR}/${SQLFILE})"

   SECONDS=0
   result=$(psql -q -t -f "${SQLDIR}/${SQLFILE}")
   echo "$result"
   duration=$SECONDS
   trace "TIME:  $(echo "scale=2; $duration / 60" | bc -l)"
   trace "RESULT: ${result}"

   if ! comparetables $result
   then
      update_status=$((update_status+1))
      STATUSMSG="Table counts DO NOT agree for $SQLFILE. (Status: $update_status)"
      trace "$STATUSMSG"
   else
      trace "Table counts DO agree for $SQLFILE. (Status: $update_status)"
   fi
done < "${SQLDIR}/script.list"

trace "DONE LOOPING, STATUS = $update_status"

if [ "$update_status" -eq 0 ]
then
   trace "GETTING TABLE COUNTS"
   psql -q -t -f "${SQLDIR}/checkalltables.sql" > "${LOGDIR}/checkalltables.out" 2>&1
   trace "RENAMING TEMP TABLES (STATUS: $update_status)"
   result=$(psql -q -t -f "${SQLDIR}/rename_all.sql")
   trace "RENAMED ALL FILES (STATUS: $update_status)"
   trace "CREATING INDEXES"
   result=$(psql -q -t -f "${SQLDIR}/create_indexes.sql")
else
   trace "BAILING"
   trace "$STATUSMSG (STATUS: $update_status)"
   notify "$STATUSMSG (STATUS: $update_status)"
   exit_msg "$STATUSMSG (STATUS: $update_status)"
fi

FILE="originaljpegs.sql"
SQLFILE="$(stripws "$FILE")"

if [ -n "$SQLFILE" ]
then
   trace "USING: $(ls -l ${SQLDIR}/${SQLFILE})"
   result=$(psql -q -t -f "${SQLDIR}/${SQLFILE}")
   trace "RESULT: $result"
else
   trace "SKIPPING $FILE"
fi

echo  "$(date): finished cinefiles_denorm_nightly" >> $FOOFILE

trace "ALL DONE at `date`"
