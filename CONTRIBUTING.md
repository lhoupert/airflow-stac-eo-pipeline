# Contributing

- Python dependencies go through `uv`; `uv.lock` is committed and CI installs with `uv sync --locked`.
- `stages/` holds orchestration only: the work itself lives in `eo_ingest`, pinned to one commit of the Argo repo.
- Every step in a README or a pull request names the command that proves it is done.
- No `from __future__ import annotations` unless a file needs it.
- Commit messages: a Conventional Commits subject, then at most two short sentences on why.
- This repo is generic: no reference to any employer, client or production system, in code, docs, commits or issues.
