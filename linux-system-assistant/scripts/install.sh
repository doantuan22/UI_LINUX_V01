#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$ROOT/.venv"

if [[ ! -d "$VENV" ]]; then
    python3 -m venv "$VENV"
fi

"$VENV/bin/pip" install -r "$ROOT/requirements.txt"
echo "Dependencies installed. Run: $ROOT/run.sh"
