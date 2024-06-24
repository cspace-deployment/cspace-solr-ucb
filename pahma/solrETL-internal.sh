#!/bin/bash -x
#
##############################################################################
# this script loads the solr core for the "internal" portal.
#
# the input file is created by the script that creates the input file for
# the public core, so all this script has to do is POST it to
# to the Solr update endpoint...
#
# Features of the 'internal' metadata, so far:
#
# un-obfuscated latlongs
# all images, "in the clear", including catalog cards
# museum storage location info
#
##############################################################################
date
##############################################################################
# note that there are 3 nightly scripts, public, internal, and locations,
# the scripts need to run in order: public > internal > locations.
# internal (this script) depends on data created by public
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintenance. ergo, the TENANT parameter
##############################################################################
source ${HOME}/pipeline-config.sh
TENANT=$1
CORE=internal
CONTACT="${PAHMA_CONTACT}"
##############################################################################
cd ${HOME}/solrdatasources/${TENANT}
##############################################################################
# we use the csv file for the internal store, prepared by the solrETL-public.sh
##############################################################################
gunzip 4solr.${TENANT}.internal.csv.gz
../common/post_to_solr.sh ${TENANT} ${CORE} ${CONTACT} 720000 68
date
