#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/linux-system-assistant.desktop"

mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Linux System Assistant
Comment=Floating system monitor and control widget
Exec=$ROOT/run.sh
Icon=utilities-system-monitor
Terminal=false
Categories=Utility;System;
StartupNotify=false
EOF

chmod +x "$ROOT/run.sh"
echo "Created $DESKTOP_FILE"
