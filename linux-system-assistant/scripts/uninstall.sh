#!/usr/bin/env bash
set -euo pipefail

AUTOSTART="$HOME/.config/autostart/linux-system-assistant.desktop"
DESKTOP="$HOME/.local/share/applications/linux-system-assistant.desktop"

rm -f "$AUTOSTART" "$DESKTOP"
echo "Removed autostart and desktop shortcuts (if present)."
