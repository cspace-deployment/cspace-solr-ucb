## Solr8 helpers for UCB CSpace webapps

Tools (mainly shell scripts) to:

* deploy solr8 on Unix-like systems (Mac, Linux, perhaps even Unix).
* load the existing UCB solr datastores into the solr8 deployment.
* start and stop the solr service.

Currently there are 7 tools, some mature, but mostly unripe, raw, and needy:

* scp4solr.sh -- attempts to scp (copy via ssh) the available nightly solr extracts
* curl4solr.sh --  attempts to cURL the available nightly solr public extracts from the Production server
* make_curls.sh -- script to extract the latest cURL commands to do the POSTing to Solr. creates allcurls.sh
* allcurls.sh -- (EXAMPLE ONLY!) clears out and refreshes all UCB solr cores (provide you have the input files!)
* checkstatus.sh -- *on UCB managed servers only* this script checks the ETL logs and counts records in all the solr cores
* countSolr8.sh -- if your Solr8 server is running, this script will count the records in the UCB cores
* tS.py -- a script to test your "solrpy" module and connectivity to Solr

#### Suggestions for "local installs" of Solr

e.g. on your Macbook or Ubuntu labtop, for development. Sorry, no help for Windows here!

(for installs on RTL servers, consult Ops.)

The essence:

* Install Solr8
* Start the Solr8 server
* Configure for UCB solr datastores using the scripts provided.
* Obtain the latest data extracts from UCB servers
* Unzip and load the extracts
* Verify Solr8 server works

If you want to install the ETL pipelines and refresh from the database 

```bash
#
# NB: if solr is *already* running, you'll need to
#     kill it in order to start it again so it will see the new cores.

# ps aux | grep solr
# kill <thatsolrprocess>
#
# 1. Obtain the code need (mainly bash scripts) from GitHub
#
# (you'll need to clone the repo with all the tools in it...)
#
# let's assume that for now you'll put the solr8 data in your home directory.
cd ~
git clone https://github.com/cspace-deployment/cspace-solr-ucb

# 2. Get solr8
wget ....
gunzip ...
mv solr8-.... solr8

# try it out
cd ~/solr8
bin/solr start

# 3. You should now be able to see the Solr8 admin console in your browser:
#
#    http://localhost:8983/solr/
#
# 4. update the cores and schema for ucb
#
# NB: Assumes you have cloned the cspace-solr-ucb repo...use the full path please
#
cd ~/cspace-solr-ucb/solr-cores
# you'll need to edit the SOLR_CMD in makesolrcores.sh to match where you put solr
./makesolrcores.sh ~/cspace-solr-ucb
#
#
# 5. Restart solr and check to see your cores are there.
cd ~/solr8
bin/solr stop
bin/solr start
#
#    http://localhost:8983/solr/
#
#    You should have a bunch of empty solr cores named things like "bampfa-public", "pahma-internal", etc.
#
#    You can also check the contents of the solr server using the countSolr8.sh script:
#
~/cspace-solr-ucb/utilities/countSolr8.sh
#
# 6. if you want to populate your cores using 'nightly exracts', then...
#
# first, make a directory to keep things neat and tidy:
cd ~
mkdir 4solr
cd 4solr
#
# then, there are several ways to get the files:
#
# to get a subset of the dumps (i.e. the public ones), you can download them via HTTP:
~/cspace-solr-ucb/utilities/curl4solr.sh
~/cspace-solr-ucb/utilities/wget4solr.sh
#
# or, if you have ssh access to either Dev or Prod, you can scp them:
~/cspace-solr-ucb/utilities/scp4solr.sh mylogin@cspace-prod.cspace.berkeley.edu
#
# NB: this script makes *a lot* of assumptions!
# * You must be able to connect to the CSpace production or development servers,
#   cspace-(prod,dev).cspace.berkeley.edu
#   via secure connection, i.e. ssh.
#   to check if you can get in, try "ssh mylogin@cspace-prod.cspace.berkeley.edu". if this does not
#   work, debug that issue first before proceeding.
# * If you're off-campus, you will probably need a VPN connection. The only evidence of this
#   might be that invoking the script does nothing -- just hangs.
#   You don't need to use the script. You can simply try the following:
#       scp <your-dev-login>@cspace-prod.cspace.berkeley.edu:/tmp/4solr*.gz .
# * You may not have credentials for Prod (only dev). In this case, try:
#       scp <your-dev-login>@cspace-dev.cspace.berkeley.edu:/tmp/4solr*.gz .
#   (this will get you whatever is on Dev, which may not be the latest versions)
# * In any case, if you have to do the scp by hand, you'll also need to uncompress the files by hand:
#       gunzip -f 4solr*.gz
# * Be patient: it may take a while -- 10-20 minutes -- to download all the files. They're a bit big.
#
# 7. execute the script to load all the .csv dump files (take 15 mins or so...some biggish datasources!)
#
#    this script cleans out each solr core and then loads the dump file.
#    all the work is done via HTTP
#
# IMPORTANT!! the specifics of the cURLs to refresh the solr cores change frequently
# make sure you get the right ones -- you may need to recreate the allcurls.sh
# script on Production using the make_curls.sh script...
#
nohup ~/cspace-solr-ucb/utilities/allcurls.sh
# (takes a while, well over an hour. ergo the nohup...)
#
#    as noted above, you can check the contents of your Solr cores in the admin console or via
#    a script, as described in 4. above.
#
# 7. Clean up, if you wish
#
rm -rf ~/4solr
#
# You should now have some "live data" in Solr8! Enjoy!
#
```

#### Initial Installation of ETL pipelines on RTL VMs (Ubuntu)

To install the pipelines on RTL VMs, from scratch, or to completely update the solr datastores,the following seems to work.
Note that this procedure is a complete ground up rebuild of the Solr ETL pipelines, and during the time
this is being executed the cores will be down.

```bash
# ssh to a server
ssh cspace-prod.cspace.berkeley.edu
sudo su - app_solr

# assumes that Solr is up and running, see above
# set up the solr etl

git clone https://github.com/cspace-deployment/cspace-solr-ucb

mkdir solrdatasources
cspace-solr-ucb/utilities/redeploy-etl.sh

# hmmm... the script expects to save an existing dir, remove it if we don't care.
rm -rf solrdatasources.180409/
#
# OPTIONAL STEPS:
#
# To make the prod scripts into dev scripts:
# ymmv! the following used to work (July 2019), but port number and hostnames are prone to change
cd ~
perl -i -pe 's/prod\-42.ist.berkeley.edu port=53/dev-42.ist.berkeley.edu port=51/' solrdatasources/*/*.sh
perl -i -pe 's/prod\-42.ist.berkeley.edu port=53/dev-42.ist.berkeley.edu port=51/' solrdatasources/*/*.sh
perl -i -pe 's/CONTACT=.*/CONTACT="jblowe\@berkeley.edu"/' solrdatasources/*/*.sh
perl -i -pe 's/=5113/=5114/' solrdatasources/*/*.sh
perl -i -pe 's/=5107/=5117/' solrdatasources/*/*.sh
perl -i -pe 's/=5110/=5119/' solrdatasources/*/*.sh

# setup pgpass, if it is not already set up.
cat > .pgpass
vi .pgpass
chmod u+rw .pgpass
ls -ltr .pgpass
# try reloading a couple of cores. the small ones.
nohup /home/app_solr/solrdatasources/bampfa/solrETL-public.sh bampfa >> /home/app_solr/logs/bampfa.solr_extract_public.log 2>&1 &
nohup /home/app_solr/solrdatasources/botgarden/solrETL-public.sh botgarden >> /home/app_solr/logs/botgarden.solr_extract_public.log &
wait
# did they work?
./checkstatus.sh -v

# now load the solr cores; couple ways to do this:
# Provided you have access to the Postgres server, you can run the refresh job (takes a couple hours):
nohup one_job.sh >> /home/app_solr/refresh.log &
#
```

#### Finding stuff in your Solr cores"

Often it is useful to be able to check for stuff in one of the Solr cores.

Locally, the "Solr admin panel" is a great tool. If solr is running locally, it should be available at:

http://localhost:8983/solr/

You can tunnel to it elsewhere, e.g.:

ssh -L 10000:localhost:8983 me@blacklight-dev.ets.berkeley.edu

and you will be able to see it at:

http://localhost:10000/solr/

If you want to see if your Solr cores are available and you have the Python Solr module
properly installed, you can use `tS.py`. Try:

`
python tS.py
`

in this very directory and debug from there.

For example, if you would like to run check to see if a list of PAHMA museum numbers actually exist, you 
could make a file of the museum numbers, one per line, and try:

`
python tS.py pahma-public http://localhost:8983 'objmusno_s:"%s"' < /tmp/objmusno_s.txt > objmusno_s.txt 
`

Caveats:

* You should read and understand these scripts before using them!
* Mostly these expect the "standard" Ubuntu OS infrastructure at RTL
* But they will mostly run on your Mac or local VM, perhaps with some tweaking.


#### Differences between Dev and Prod deployments

There are only a few differences between the "pipeline code" as deployed on Dev and as deployed on Prod. (The
files committed on GitHub are set up for Production; they need some minor edits when deployed on Dev.)

* The Postgres servers of course are different (hostname and port numbers).
* Several of the scripts send email. On Dev, these emails addresses should be changed to something appropriate: no
need to bug everyone with Dev output!
* Usually I keep the Dev Solr cores updated with data from Production. This way, the Dev portals more
closely resemble their production counterparts. Therefore, in app_solr's home directory there is a subdirectory
`/4solr` that contains the refresh files from Prod, along with a script to fetch them from Prod (via wget) and to POST
them to Solr. However, when testing changes to the pipelines, one should run the pipeline on Dev and check results.
Later it may be prudent to put the production data back...
* There is no need (in general) to run the Solr refresh scripts nightly: nothing changes much on Dev! Therefore, the
cron job to run the refreshes (`one_job.sh`) is commented out in the `crontab`

Here are the diffs one can expect between the pipeline files as committed to GitHub and as deployed on Dev.

```
diff -r ~/cspace-solr-ucb solrdatasources | grep -v Only > diffs

diff -r /home/app_solr/cspace-solr-ucb/bampfa/bampfa_collectionitems_vw.sh solrdatasources/bampfa/bampfa_collectionitems_vw.sh
8c8
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
20c20
< mail -a ${TENANT}_collectionitems_vw.tab.gz -s "${TENANT}_collectionitems_vw.csv.gz" -- osanchez@berkeley.edu < /dev/null
---
> mail -a ${TENANT}_collectionitems_vw.tab.gz -s "${TENANT}_collectionitems_vw.csv.gz" -- jblowe@berkeley.edu < /dev/null
diff -r /home/app_solr/cspace-solr-ucb/bampfa/bampfa_website_extract.sh solrdatasources/bampfa/bampfa_website_extract.sh
7c7
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
37c37
< echo "https://webapps.cspace.berkeley.edu/${TENANT}_website_objects_extract.tab" | mail -s "new ${TENANT} website extract available" -- aharris@berkeley.edu
---
> echo "https://webapps.cspace.berkeley.edu/${TENANT}_website_objects_extract.tab" | mail -s "new ${TENANT} website extract available" -- jblowe@berkeley.edu
diff -r /home/app_solr/cspace-solr-ucb/bampfa/piction_extract.sh solrdatasources/bampfa/piction_extract.sh
8c8
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5415 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5415 sslmode=prefer"
15c15
< #time psql -A -d "host=dba-postgres-prod-42.ist.berkeley.edu dbname=piction_transit port=5415 sslmode=prefer" -U "piction"  -c "select * from piction.bampfa_metadata_mv" -o ${TENANT}_pictionview_vw.tab
---
> #time psql -A -d "host=dba-postgres-dev-42.ist.berkeley.edu dbname=piction_transit port=5415 sslmode=prefer" -U "piction"  -c "select * from piction.bampfa_metadata_mv" -o ${TENANT}_pictionview_vw.tab
21c21
< mail -a ${TENANT}_pictionview_vw.tab.gz -s "${TENANT}_pictionview_vw.csv.gz" -- cspace-piction-view@lists.berkeley.edu < /dev/null
---
> mail -a ${TENANT}_pictionview_vw.tab.gz -s "${TENANT}_pictionview_vw.csv.gz" -- jblowe@berkeley.edu < /dev/null
diff -r /home/app_solr/cspace-solr-ucb/bampfa/solrETL-internal.sh solrdatasources/bampfa/solrETL-internal.sh
10c10
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/bampfa/solrETL-public.sh solrdatasources/bampfa/solrETL-public.sh
20c20
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/botgarden/solrETL-internal.sh solrdatasources/botgarden/solrETL-internal.sh
19c19
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/botgarden/solrETL-propagations.sh solrdatasources/botgarden/solrETL-propagations.sh
19c19
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/botgarden/solrETL-public.sh solrdatasources/botgarden/solrETL-public.sh
19c19
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/cinefiles/solrETL-public.sh solrdatasources/cinefiles/solrETL-public.sh
17c17
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5313 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5114 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/pahma/solrETL-locations.sh solrdatasources/pahma/solrETL-locations.sh
25c25
< HOSTNAME="dba-postgres-prod-42.ist.berkeley.edu port=5307 sslmode=prefer"
---
> HOSTNAME="dba-postgres-dev-42.ist.berkeley.edu port=5117 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/pahma/solrETL-osteology.sh solrdatasources/pahma/solrETL-osteology.sh
15c15
< HOSTNAME="dba-postgres-prod-42.ist.berkeley.edu port=5307 sslmode=prefer"
---
> HOSTNAME="dba-postgres-dev-42.ist.berkeley.edu port=5117 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/pahma/solrETL-public.sh solrdatasources/pahma/solrETL-public.sh
24c24
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5307 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5117 sslmode=prefer"
28c28
< CONTACT="mtblack@berkeley.edu"
---
> CONTACT="jblowe@berkeley.edu"
diff -r /home/app_solr/cspace-solr-ucb/ucjeps/solrETL-media.sh solrdatasources/ucjeps/solrETL-media.sh
10c10
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5310 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5119 sslmode=prefer"
diff -r /home/app_solr/cspace-solr-ucb/ucjeps/solrETL-public.sh solrdatasources/ucjeps/solrETL-public.sh
19c19
< SERVER="dba-postgres-prod-42.ist.berkeley.edu port=5310 sslmode=prefer"
---
> SERVER="dba-postgres-dev-42.ist.berkeley.edu port=5119 sslmode=prefer"
23c23
< CONTACT="ucjeps-it@berkeley.edu"
---
> CONTACT="jblowe@berkeley.edu"
```


#### Installing solr8 as a service on UCB VMs

Check with Ops

####  Testing queries

Certain search terms are supposed to handled specially. For example:

* singulars and plurals should produce the same search results.
* Same for terms that do (or do not) contain special characters, such as terms with diacritics.
* The English possesive 's should be handled correctly.

There's a script and a test file for that! Here's how it works:

```
$ python query-test-cases.py https://webapps-dev.cspace.berkeley.edu/solr/pahma-public query-test-cases.pahma.txt 
Métraux vs Metraux: 886 OK
Luiseño vs Luiseno: 377 OK
Diegueño vs Diegueno: 486 OK
Kantō vs Kanto: 255 OK
Kyūshū vs Kyushu: 78 OK
Kończyce vs Konczyce: 1 OK
Vértesszőlős vs Vertesszolos: 1 OK
Gårslev vs Garslev: 2 OK
Røros vs Roros: 1 OK
Appliqué vs Applique: 765 OK
Æ vs AE: 3570 OK
Basket vs Baskets: 14273 OK
Femur vs Femurs: 1365 OK
Filipino vs Filipinos: 2527 OK
Comb vs Combs: 601 OK
MacKinley vs McKinley: 0 does not equal 605
Eskimo vs Eskimaux: 6054 does not equal 0
Humerus vs Humeri: 1282 OK
```

