#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "==> Running tests..."
pytest tests/ -v

echo "==> Running linter..."
ruff check .

echo "==> Running type checker..."
mypy src/

echo "==> All checks passed!"
