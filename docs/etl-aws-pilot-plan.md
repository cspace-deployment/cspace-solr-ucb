# Plan: independent per-museum ETL on AWS, starting with a PAHMA pilot

Status: **preliminary plan, as of October 16, 2026.** Expect it to change as we begin deploying and testing the PAHMA pilot; decisions marked open below, and others we haven't yet found, will be settled along the way. Written against `main` at commit 610e50c.

## Why

The nightly Solr ETL runs every museum from one shell script, `utilities/one_job.sh`, on one EC2 instance that also hosts Solr. Since CSW-865 (May 2023) the five museums run one after another. The change was made to reduce peak memory use on that shared instance, at a cost of about 40 minutes a night. It also introduced a new failure mode, noted in the issue's comments: one hung pipeline blocks every museum after it.

The single linear chain couples the museums in ways that have nothing to do with their data:

- A failure, hang or slow night in one museum delays or blocks the others.
- All museums share one box, one Solr, one deployment of the code and one set of configuration files.
- Pipelines of the same museum must run in sequence partly because they share a working folder: `common/post_to_solr.sh` ends with `mv *.csv` into the cache, which would move another pipeline's files.
- There are no time limits, and errors don't stop a run: a failed query or an HTTP error from Solr is reported only afterwards, by email, if at all.

The priorities for this work are correctness, maintainability and resiliency. Cost and speed are secondary.

## The rollout context

The new Bulk Media Uploader (BMU) and the new ImageServer (Serena) will be tested on a single museum first, most likely PAHMA. For the testing period a separate ETL instance, with its own Solr, will be set up for PAHMA only. That is the natural place to build the new structure, because nothing else depends on it yet. The existing production ETL keeps running unchanged during the pilot.

## Principle: one museum, one independent workflow

Each museum becomes its own scheduled workflow with:

- its own container and working space;
- its own timeouts, retries and alerts;
- its own version of the code (a container image tagged with a git commit).

A museum's failure, hang or rerun affects no other museum. Running museums in parallel stops being a special mode: independent workflows simply run when they are scheduled. Pipelines of the same museum that don't depend on each other (for example PAHMA public and PAHMA locations) can also run in parallel once each has its own working space.

## Components

All infrastructure is defined in Terraform.

### Solr

- Runs on its own small EC2 instance, sized for serving searches, not for building cores.
- Sits in a private subnet. Its security group admits only the ETL tasks, the portals and Serena's servable list script.
- Each public core has a staging twin. A load goes into the staging core, is validated, and is then swapped in (Solr CoreAdmin `SWAP`). Readers never see an empty or half-loaded core. This is the "staging core, then a swap" step that CSW-1027 plans for after Serena's first version, done from the start.

### The ETL container

- Built from this repository by CI, pushed to ECR and tagged with the git commit.
- Deploying means pointing the task definition at a new image tag. This replaces `utilities/redeploy-etl.sh`, `utilities/set_platform.sh` and the copying of `pipeline-config-*.sh` into the home folder.
- Runs as an ECS Fargate task, sized for that museum's peak memory, and exists only while it runs.
- The same image runs on a laptop against a local Solr, for development and testing.

### Orchestration

- One AWS Step Functions workflow per museum, started by EventBridge Scheduler.
- For PAHMA public, the steps are:
  1. Extract and merge (the existing pipeline logic).
  2. Load into the staging core.
  3. Validate the staging core: row count against a minimum, required fields present, media fields well formed.
  4. Swap the staging core into place.
  5. Make the servable list and hand it to Serena (CSW-1027).
- Each step has its own timeout and retry rule. A failure in steps 1 to 3 stops before the swap and sends an alert; the live core keeps the previous day's data.
- The Serena steps run after the swap and can't undo it, as CSW-1027 requires. They report their outcome without failing the museum's refresh.

### State between nights

- S3, with versioning and expiry rules, holds the previous good extract (the fallback), counts reports and servable lists.
- This replaces `SOLR_CACHE_DIR`, the copies to `/var/www/static`, and the emailed attachments.

### Secrets and identity

- AWS Secrets Manager holds the database credentials and Serena's per-museum token. ECS passes them into the task.
- The task gets an IAM role. No keys are stored on disk or in the repository, and nothing secret is written to logs.

### Logs and alerts

- CloudWatch Logs replace the per-core log files.
- Step Functions failure handling with SNS or SES replaces `utilities/checkstatus.sh` and the `mail` calls in the scripts.

## ETL code changes for the PAHMA pilot

These are small and mechanical, and keep the extract and merge logic as it is:

- **Configurable addresses.** The Solr address and the target core name come from the environment. Today `common/post_to_solr.sh` hard-codes `localhost:8983`.
- **Fail properly.** `set -euo pipefail` in the scripts, `ON_ERROR_STOP` for psql, and `curl --fail` for Solr requests, so that a failed step fails the task.
- **Connection settings from the environment.** The dependence on `$HOME`, `.pgpass` and the login-name check in `set_platform.sh` goes away.
- **Cache in S3.** The fallback extract is read from and written to S3 instead of a local folder.
- **Retire duties the workflow takes over:** the copies to `/var/www/static`, the email steps, and the empty-then-load sequence in `post_to_solr.sh` (replaced by staging and swap).
- **Parallel queries inside the container.** PAHMA's public script runs 34 part queries one after another, re-joining the growing output files after each one. They don't depend on each other and can run in parallel, followed by one many-way join.
- **Lower memory use where it is cheap.** psql collects a whole result in memory unless `FETCH_COUNT` is set; setting it streams large results.

The golden-file tests on the `refactor/test-harness` branch (`tests/run_golden.sh`) are the safety net for these changes: the transform helpers must produce byte-for-byte the same output before and after.

## Correctness check during the pilot

Both PAHMA pipelines, old and new, read the same Lyrasis database during the pilot. Each night, compare the new `pahma-public` core with the production one, field by field, over a sorted export of both. The only differences should be:

- the new `blobmedia_ss` field (CSW-1027), and
- changes made in CollectionSpace between the two runs.

This shows that the new infrastructure didn't change what is public before Serena relies on it.

## Rollout

1. Build the PAHMA pilot: Solr instance, container, workflow, S3, secrets, alerts.
2. Run it nightly alongside production and run the correctness check.
3. Add the CSW-1027 work (`blobmedia_ss`, servable list, Serena calls) on the pilot first.
4. Test the new BMU and Serena against the pilot.
5. Add the other museums, one at a time, as their own workflows.
6. Retire `one_job.sh` and the old instance once every museum has moved.

## Open decisions

1. **Database access from the containers.** The current instance reaches the Lyrasis Postgres through `localhost` port 54321. Fargate tasks can't use that. Options: a VPN or PrivateLink to Lyrasis, an allow-listed NAT address with TLS, or a tunnel through a bastion host. To be decided with the operations team and Lyrasis; the rest of the design doesn't depend on the choice.
2. **Which PAHMA cores the pilot builds.** `pahma-public` only (enough for Glimmer and Serena), or `pahma-internal` and `pahma-locations` too, if the internal portal or BMU testing needs them.
3. **Orchestration weight.** Step Functions, as described, or a simpler EventBridge-scheduled ECS task per museum with a timeout. Step Functions makes the validation, swap and Serena polling clearer and safer, and is the recommendation.
4. **Where Solr runs.** EC2 is the simplest choice for Solr's disk-based indexes. Running Solr in containers is possible but needs persistent storage work.

## Out of scope

- Any change to how the ETL decides what is public.
- Changes to Glimmer.
- Moving the other four museums during the pilot.

## References

- CSW-865: Run Solr pipeline consecutively instead of in parallel, to ease peak resource consumption (May 2023).
- CSW-1027: add `blobmedia_ss` to each public core, and hand Serena a daily servable list made from the live public core.
- `tests/README.md`: the golden-file test harness.
