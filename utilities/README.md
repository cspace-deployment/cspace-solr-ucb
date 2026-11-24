## Solr helpers for UCB CSpace webapps

Tools (mainly shell scripts) to:

* deploy solr on Unix-like systems (Mac, Linux, perhaps even Unix).
* load the existing UCB solr datastores into the solr8 deployment.
* start and stop the solr service.
* run the Solr ETL pipelines (but the pipeline scripts themselves are not here: see museum repos)

Currently there are 7 tools, some mature, but mostly unripe, raw, and needy:

* scp4solr.sh -- attempts to scp (copy via ssh) the available nightly solr extracts. CAUTION: includes the `internal` extracts!
* curl4solr.sh --  attempts to cURL the available nightly solr public extracts from the Production server.
* wget4solr.sh --  attempts to `wget` the available nightly solr public extracts from the Production server.
* make_curls.sh -- script to extract the latest cURL commands from the Solr ETL logs to do the POSTing to
  Solr. Creates `allcurls.sh`. MUST BE RUN ON AND RTL SERVER where `~APP_USER/logs exists`!
* allcurls.sh -- (EXAMPLE ONLY!) clears out and refreshes all UCB solr cores (provide you have the input files!)
* checkstatus.sh -- *on UCB managed servers only* this script checks the ETL logs and counts records in all the solr cores
* checkcores.sh -- pings the admin interface (via cURL and HTTP) to obtain counts for all the solr cores
  on localhost:8983.
* countSolr8.sh -- if your Solr8 server is running, this script will count the records in the UCB cores.
* tS.py -- a toy script to test your "solrpy" module and connectivity to Solr.
  you'll have to read it to figure out how to use it.

#### Suggestions for "local installs" of Solr

e.g. on your Macbook or Ubuntu laptop, for development. Sorry, no help for Windows here!

(for installs on RTL servers, consult Ops.)

The essence:

* Install Solr8 (either the "bonehead" easy way, or as a service)
* Start the Solr8 server
* Configure for UCB solr datastores using the scripts provided
* (Obtain the latest data extracts from UCB servers; unzip and load the extracts)
* (Or regenerate from scratch via the pipelines)
* Verify Solr8 server works

NB: in general, you won't be running the _Solr ETL pipelines_ themselves locally, that's why we copy the
'extracts' that are published on webapps.cspace.berkeley.edu. Only the public extracts are available.
If you want to have the *-internal cores populated, you'll need to scp them from webapps.cspace.b.e or
otherwise arrange to obtain them. Inasmuch as there is sensitive info in those internal cores, caution
should be exercised in hosting them on your local system; in general it should not be necessary since
you can get access to them by tunneling to one of the RTL servers.

NB: if solr is *already* running, you'll need to
kill or stop it in order to start it again so it will see the new cores.
here's one way to do it:
```bash
ps aux | grep solr
kill <thatsolrprocess>
```
or, if you have already started solr in a way similar to what is suggested here:
```bash
cd ~/solr8
bin/solr stop
```
...But there are others. consult your friendly solr operator to find out how best to stop
and eventually get rid of an existing solr server.

It is possible that you'll need to co-exist with existing solr operations; such
co-existence is feasible, probably not even that hard, but is beyond the scope of
these instructions.

```bash
# 1. Obtain the code need (mainly bash scripts) from GitHub
#
# (you'll need to clone the repo with all the tools in it...)
#
# let's assume that for now you'll put the solr8 data in your home directory.
cd ~
git clone https://github.com/cspace-deployment/cspace-solr-ucb

# 2. Get solr8 (google 'install solr8')
wget ....
gunzip ...
# the rest of the instructions assume you've moved or symlinked the
# solr directory to 'solr8'
mv solr8-.... ~/solr8

# try it out
cd ~/solr8
bin/solr start

# 3. You should now be able to see the Solr8 admin console in your browser:
#
#    visit http://localhost:8983/solr/
#
# 4. update the cores and schema for ucb
#
# NB: clone the cspace-solr-ucb repo if you haven't already
#
cd ~
git clone https://github.com/cspace-deployment/cspace-solr-ucb
cd ~/cspace-solr-ucb/solr-cores/utilities
# IMPORTANT! you'll need to edit the SOLR_CMD in makesolrcores.sh to match where you put solr
vi makesolrcores.sh
# now run it. may take a minute or two.
./makesolrcores.sh
#
#    visit http://localhost:8983/solr/
#
#    You should have a bunch of empty solr cores named things like "bampfa-public", "pahma-internal", etc.
#
#    You can also check the contents of the solr server using the countSolr8.sh script:
#
~/cspace-solr-ucb/utilities/countSolr8.sh
#
# 5. if you want to populate your cores using 'nightly exracts', then...
#
# first, make a directory to keep things neat and tidy:
mkdir ~/4solr
cd ~/4solr
#
# then, there are several ways to get the files:
#
# to get a subset of the dumps (i.e. the public ones), you can download them via HTTP:
~/cspace-solr-ucb/utilities/curl4solr.sh
# or
~/cspace-solr-ucb/utilities/wget4solr.sh
# or, if you have ssh access to either Dev or Prod, you can scp them:
~/cspace-solr-ucb/utilities/scp4solr.sh mylogin@webapps.cspace.berkeley.edu
#
# NB: this last script makes *a lot* of assumptions!
# * You must be able to connect to the CSpace production or development servers,
#   webapps-(prod,dev).cspace.berkeley.edu
#   via secure connection, i.e. ssh.
#   to check if you can get in, try "ssh mylogin@cspace-prod.cspace.berkeley.edu". if this does not
#   work, debug that issue first before proceeding.
# * If you're off-campus, you will probably need a VPN connection. The only evidence of this
#   might be that invoking the script does nothing -- just hangs.
#   You don't need to use the script. You can simply try the following:
#       scp <your-prod-login>@webapps.cspace.berkeley.edu:/tmp/4solr*.gz .
# * You may not have credentials for Prod. In this case, try:
#       scp <your-dev-login>@webapps-dev.cspace.berkeley.edu:/tmp/4solr*.gz .
#   (this will get you whatever is on Dev, which may not be the latest versions)
# * In any case, if you have to do the scp by hand, you'll also need to uncompress the files by hand:
#       gunzip -f 4solr*.gz
# * Be patient: it may take a while -- 10-20 minutes -- to download all the files. They're a bit big.
#
# 6. execute the script to load all the .csv dump files
#
#    this script cleans out each solr core and then loads the dump file.
#    all the work is done via HTTP
#
# IMPORTANT!! the specifics of the cURLs to refresh the solr cores change frequently
# make sure you get the right ones -- you may need to recreate the allcurls.sh
# script on Production using the make_curls.sh script...
# the script in GitHub is only an example of the recent setup.
#
cp ~/cspace-solr-ucb/utilities/allcurls.sh.example .
nohup time allcurls.sh
# (takes a while, sometimes even an hour ...some biggish datasources! ergo the nohup...)
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

#### Differences between Dev, QA and Prod environments on RTL servers

The Solr pipelines need to be configured to point to the appropriate CSpace
and Solr servers for each environment.

There are only a few parameters that need to be changed in the 
pipeline scripts themselves:

* The postgres server used (e.g. "dba-postgres-[dev,prod]-45.ist.berkeley.edu")
* The port number for the postgres server (e.g. 5117)
* The email address for email reports

These are current set in a config file in the home directory of the
user running the pipelines. The file is `pipeline-config.sh`

In the GitHub repo, there are three versions of this file, one for each
environment. Configuring the pipelines there consists of
copying the appropriate file to create `pipeline-config.sh`, e.g.
```
cd
cp pipeline-config-prod.sh pipeline-config.sh
```
Alas,

the CineFiles pipeline has a 'legacy' component that denormalizes the CSpace
database content into table in the utils scheme. This Rube Goldberg apparatus
is keep in the Solr repo in `cinefiles/scripts` and is deployed with the
rest of the pipelines. However, since it needs to write to the utils schema
it needs its own Posgres role (current `miponca`) and therefore entry in `.pgpass`.
This pipeline therefore has its own config files `cinefiles-config*.sh`
which work just like the config for the rest of the pipelines: just copy
the right version of the file into home directory (from repo
`cspace-solr-ucb/cinefiles`).

#### Serena token file (PAHMA, CSW-1027)

After PAHMA's public refresh, `oj.pahma.sh` runs `common/serena-refresh.sh`, which hands PAHMA's
servable list to Serena, the new ImageServer. It runs only when all three are true; otherwise it logs
`Serena pahma: skipped (...)` and exits without error:

* `SERENA_BASE_URL` is set in `pipeline-config.sh` (set in `pipeline-config-qa.sh` and
  `pipeline-config-prod.sh`, empty in `pipeline-config-dev.sh`; changing it is a change to the repo
  and a new release, since `redeploy-etl.sh` overwrites `~/pipeline-config.sh`). In production the
  token file is what switches the step on: until it is installed, the step skips.
* `SERENA_TOKEN_DIR` is set (`${HOME}/.serena` in every `pipeline-config-*.sh`; nothing to change)
* the token file `${SERENA_TOKEN_DIR}/pahma.token` exists

The token is a secret. It is never put in the repo, in `pipeline-config.sh`, in a command line, an
email or a chat. Serena's team makes it (`./serena aws etl-token pahma --show`) and hands it over
with a one-time secret link, or reads it to you on a call.

Installing it, as the ETL user (`app_cspace`) on the ETL server:

```
cd
mkdir -p ~/.serena
chmod 700 ~/.serena
(umask 077; cat > ~/.serena/pahma.token)
```

Paste the token, press Return, then Ctrl-D (this keeps it out of the shell history). Then check:

```
chmod 600 ~/.serena/pahma.token
ls -l ~/.serena
```

Expected: one line, `-rw-------  1 app_cspace ...  pahma.token`, and a size of about the token's
length. Don't `cat` the file to check it.

`redeploy-etl.sh` doesn't touch `~/.serena`, so the token survives redeploys.

Checking it worked, after the next nightly run:

```
grep 'Serena pahma' /cspace/solr_logs/pahma.serena.log | tail -3
```

(`/cspace/solr_logs` is `SOLR_LOG_DIR` for `app_cspace`, set by `set_platform.sh`.)

Expected: no `skipped` line for that night, and no failure email to `SERENA_CONTACT`. Serena's
admin app shows PAHMA's refresh.

Rotating the token: Serena's team runs `./serena aws etl-token pahma --show`; the old token keeps
working until the next rotation. Replace the file's contents the same way (the `cat >` line
overwrites it).

Removing it (stops the Serena step at once): `rm ~/.serena/pahma.token`.

The token file is the only way the ETL reads its token today. Reading it from AWS Secrets Manager
with the server's instance role (Serena's `ETL_READER_ROLE_ARNS`) would need a change to
`common/serena_refresh.py` first.

#### Installing solr8 as a service on UCB VMs

Check with Ops

#### Additional first time installation considerations

- UCBG needs the gbif pickle file and 'requests'. get a copy from prod
```
pip3 install requests
cd ~/solrddatasource/botgarden/gbif
# a usuable though perhaps outdated pickle file is kept on prod
wget https://webapps.cspace.berkeley.edu/names.pickle
```
- run the 'nightly solr refresh' (i.e. pipelines) manually
```
nohup ${HOME}/one_job.sh >> ${HOME}/refresh.log &
```
- to refresh the dev cores from recent production extracts (this creates
a bash script that `cURL`s the various '4solr.*' extracts to the system
on which it is executed. NB: there is a relatively recent
version of all the public extracts kept in a web-accessible directory
on the server the Solr pipelines.)
```
# make a home for these files if one does not exist
mkdir ~/4solr/
cd ~/4solr/
# cURL the public extracts
./curl4solr.sh

# fetch the current version of the script that POSTs the extracts
# to the local Solr instance. Which better be configured and running
curl -O https://webapps.cspace.berkeley.edu/allcurls.sh
chmod +x allcurls.sh
gunzip *.gz &
nohup time ./allcurls.sh
```
- perhaps the following, too? (if solr is to run as a systemd service)
```
less bin/solr.cmd
less bin/init.d/solr
ulimit -n
cat /etc/security/limits.d/solr.conf
apt install haveged
man haveged
sysctl kernel.random.entropy_avail
cat /etc/security/limits.d/solr.conf
```

####  Testing Solr queries

Certain search terms are supposed to handled specially. For example:

* singulars and plurals should produce the same search results.
* Same for terms that do (or do not) contain special characters, such as terms with diacritics.
* The English possesive 's should be handled correctly.

There's a script and a test file for that! Here's how it works:

```
$ python3 query-test-cases.py https://webapps-dev.cspace.berkeley.edu/solr/pahma-public query-test-cases.pahma.txt
# test cases for Solr stemming, character and case folding, and synonyms
# format: data as it appears in the database, a tab, query term that should match it.
# accented characters and ligatures
Métraux vs Metraux: 980 OK
Luiseño vs Luiseno: 380 OK
Diegueño vs Diegueno: 518 OK
Kantō vs Kanto: 275 OK
Kyūshū vs Kyushu: 77 OK
Kończyce vs Konczyce: 1 OK
Vértesszőlős vs Vertesszolos: 1 OK
Gårslev vs Garslev: 2 OK
Røros vs Roros: 1 OK
Appliqué vs Applique: 785 OK
Æ vs AE: 3579 OK
# plurals and singulars
Basket vs Baskets: 14692 OK
Femur vs Femurs: 1336 OK
Filipino vs Filipinos: 2720 OK
Comb vs Combs: 608 OK
# cases which probably have to be handled as special cases (i.e. synonyms)
ox vs oxen: 74 does not equal 39
fox vs vixen: 322 does not equal 0
cañon vs canon: 238 OK
cañon vs canyon: 238 does not equal 8122
# other spelling variations (handled using Solr synonyms filter)
MacKinley vs McKinley: 0 does not equal 792
Eskimo vs Eskimaux: 6102 does not equal 0
Humerus vs Humeri: 1196 does not equal 162

End of run. Pairs tested: 22, successes 16, failures 6
```

