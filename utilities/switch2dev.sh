#
# a lil script to change the solr pipelines to point to qa instead of prod and to
# send email notifications to jblowe and not the various "real" addresses. 
perl -i -pe 's/prod.42.ist.berkeley.edu port=53/dev-42.ist.berkeley.edu port=53/' solrdatasources/*/*.sh
perl -i -pe 's/=5313/=5114/' solrdatasources/*/*.sh
perl -i -pe 's/=5307/=5117/' solrdatasources/*/*.sh
perl -i -pe 's/=5310/=5119/' solrdatasources/*/*.sh
perl -i -pe 's/cspace.support.lists./jblowe@/' solrdatasources/*/*.sh
perl -i -pe 's/CONTACT=.*/CONTACT="jblowe\@berkeley.edu"/' solrdatasources/*/*.sh