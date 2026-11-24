# airflow-stac-eo-pipeline

The [`argo-stac-eo-pipeline`](https://github.com/lhoupert/argo-stac-eo-pipeline) ingestion ladder, orchestrated with **Apache Airflow** instead of Argo Workflows.

The unit of work is the same Python package (`eo_ingest`, pinned to one commit of the Argo repo), so every difference between the two repos is an orchestration difference. The ladder is built on Airflow 2.11 and its last rung upgrades the whole repo to Airflow 3.

> **Status: work in progress.** Only the data services exist so far; Airflow arrives in the next step.

## Quick start

Needs Docker (8 GB of memory and 4 CPUs once Airflow is added), docker compose v2 and [uv](https://docs.astral.sh/uv/).

```bash
make check   # tools present?
make up      # S3 store, pgSTAC, STAC API, stac-browser, and the asset bucket
make seed    # two synthetic missions with deliberate gaps
curl -s 'localhost:8081/collections/synthetic-aurora-veil/items?limit=100' | jq '.features | length'   # 11
```

Then open stac-browser at http://localhost:8082. `make clean` clears the catalog and the bucket, `make down` removes everything.

| Service | URL | Notes |
|---|---|---|
| STAC API | http://localhost:8081 | stac-fastapi-pgstac, transactions enabled |
| stac-browser | http://localhost:8082 | amd64 image (emulated on Apple silicon) |
| S3 store | http://localhost:9100, console http://localhost:9101 | [RustFS](https://github.com/rustfs/rustfs), `minioadmin` / `minioadmin`, local only |

The Argo repo used MinIO, whose community images are no longer published on Docker Hub; RustFS is an S3-compatible, Apache-2.0 replacement on the same ports.

## Ladder (planned)

| Rung | Topic | Argo counterpart |
|---|---|---|
| 00 | First DAG, TaskFlow and classic operators | `stages/00-cron` |
| 01 | Retries, a logbook, timeouts | `stages/01-argo-retries` |
| 02 | Fan-out with a cap (dynamic task mapping, pools) | `stages/02-fanout` |
| 03 | The logbook drives the repair; short-circuit, branching | `stages/03-stac-logbook` |
| 04 | Make the self-correction visible (REST API, callbacks) | `stages/04-observability` |
| 05 | Runs that know their date: data intervals, catchup, backfill | none |
| 06 | Connections, variables, hooks, secrets backend | none |
| 07 | DAGs generated from configuration, DAGs that trigger DAGs | none |
| 08 | Upgrade the repo from Airflow 2.11 to Airflow 3 | none |

## License

Apache-2.0. Synthetic data: CC-BY-4.0 (see `eo_ingest.synthetic`).

Developed with AI assistance (Claude Code); every change reviewed by the author.
