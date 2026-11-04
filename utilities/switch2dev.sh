#!/usr/bin/env bash
#
# a lil helper script to change the solr ppipeline config to point to qa instead of prod and to
# send email notifications to Dev jblowe and not the various "real" addresses.
export DEVCONTACT="lkv@berkeley.edu"
cd
perl -i -pe 's/prod-45.ist.berkeley.edu/dev-45.ist.berkeley.edu/' solrdatasources/*/*.sh
perl -i -pe 's/=5313/=5114/' solrdatasources/*/*.sh
perl -i -pe 's/=5307/=5117/' solrdatasources/*/*.sh
perl -i -pe 's/=5310/=5119/' solrdatasources/*/*.sh
perl -i -pe 's/cspace.support.lists.berkeley.edu/$ENV{"DEVCONTACT"}/' solrdatasources/*/*.sh
perl -i -pe 's/cspace.support.lists.berkeley.edu/$ENV{"DEVCONTACT"}/' ${HOME}/*.sh
perl -i -pe 's/CONTACT=.*/CONTACT="$ENV{"DEVCONTACT"}"/' solrdatasources/*/*.sh
