#!/usr/bin/env bash
# Preflight for `make up`: fail early, with a clear message, if a tool is missing.
set -u
ok=0
if ! docker info >/dev/null 2>&1; then echo "✗ Docker is not running (or not installed)"; ok=1; else echo "✓ docker"; fi
if ! docker compose version >/dev/null 2>&1; then echo "✗ docker compose v2 not found"; ok=1; else echo "✓ docker compose"; fi
if ! command -v uv >/dev/null 2>&1; then echo "✗ uv not found: https://docs.astral.sh/uv/"; ok=1; else echo "✓ uv"; fi
exit $ok
