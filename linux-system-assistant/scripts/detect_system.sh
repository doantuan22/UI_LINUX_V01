#!/usr/bin/env bash
echo "OS: $(uname -s)"
echo "Python: $(python3 --version 2>/dev/null || echo missing)"
command -v powerprofilesctl >/dev/null && echo "powerprofilesctl: yes" || echo "powerprofilesctl: no"
command -v sensors >/dev/null && echo "sensors: yes" || echo "sensors: no"
command -v nvidia-smi >/dev/null && echo "nvidia-smi: yes" || echo "nvidia-smi: no"
