# Linux System Assistant

Floating glass widget for Linux that shows real system stats and provides safe actions: process management, power profile switching, system checks, and thumbnail cache cleanup.

## Requirements

- Python 3.11+
- Kubuntu/Ubuntu/Debian desktop with Qt support
- Optional: `lm-sensors`, `powerprofilesctl`, NVIDIA driver for GPU stats

## Quick start

```bash
chmod +x run.sh scripts/*.sh
./scripts/install.sh
./run.sh
```

Create a menu shortcut:

```bash
./scripts/create_desktop_file.sh
```

## Architecture

```text
QML UI → Python Bridge → Core (read-only) + Managers (actions) → psutil / whitelisted commands
```

All shell commands go through `CommandManager` with `shell=False` and a YAML whitelist in `src/sys_assistant/config/safe_commands.yaml`.

## Config paths

- Settings: `~/.config/linux-system-assistant/config.json`
- Logs: `~/.local/state/linux-system-assistant/app.log`

## Tests

```bash
cd linux-system-assistant
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt pytest
PYTHONPATH=src .venv/bin/pytest tests/ -q
```

## Uninstall

```bash
./scripts/uninstall.sh
rm -rf ~/.config/linux-system-assistant ~/.local/state/linux-system-assistant
```

## Safety

- No free-form shell commands from UI
- No sudo by default
- Process kill requires confirmation and respects protected list
- Cleanup limited to `~/.cache/thumbnails`
