#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$ROOT/.venv"

if [[ ! -d "$VENV" ]]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -r "$ROOT/requirements.txt"
fi

export PYTHONPATH="$ROOT/src${PYTHONPATH:+:$PYTHONPATH}"

# Do not force a Qt backend globally: Wayland sessions and systems without
# xcb-cursor fail before QML can load. Qt will pick the native backend when
# QT_QPA_PLATFORM is unset, and explicit overrides remain respected.

exec "$VENV/bin/python" -m sys_assistant.main "$@"
