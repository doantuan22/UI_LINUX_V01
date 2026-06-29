#!/usr/bin/env bash
# Read-only Linux system audit helper.
# This script collects system information and logs into a local report folder.
# It does not delete, modify, install, disable, enable, or restart anything.

set -u

TS="$(date +%Y%m%d_%H%M%S)"
OUT_DIR="reports/system_audit_${TS}"
mkdir -p "$OUT_DIR"

run_check() {
  local name="$1"
  shift
  local file="$OUT_DIR/${name}.txt"
  {
    echo "# $name"
    echo "# Command: $*"
    echo "# Time: $(date -Is)"
    echo
    "$@"
  } > "$file" 2>&1 || true
}

run_shell_check() {
  local name="$1"
  local cmd="$2"
  local file="$OUT_DIR/${name}.txt"
  {
    echo "# $name"
    echo "# Command: $cmd"
    echo "# Time: $(date -Is)"
    echo
    bash -lc "$cmd"
  } > "$file" 2>&1 || true
}

run_check "os_uname" uname -a
run_shell_check "os_release" "cat /etc/os-release 2>/dev/null || true"
run_check "hostnamectl" hostnamectl
run_check "uptime" uptime
run_check "cpu_lscpu" lscpu
run_check "memory_free" free -h
run_check "vmstat" vmstat 1 5
run_check "disk_df" df -hT
run_shell_check "lsblk" "lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,MODEL 2>/dev/null || lsblk"
run_check "findmnt" findmnt
run_shell_check "systemd_failed" "systemctl --failed --no-pager 2>/dev/null || true"
run_shell_check "journal_errors" "journalctl -p 3 -xb --no-pager -n 200 2>/dev/null || true"
run_shell_check "journal_warnings" "journalctl -p warning -xb --no-pager -n 200 2>/dev/null || true"
run_shell_check "gpu_lspci" "lspci -k 2>/dev/null | grep -EA3 'VGA|3D|Display' || true"
run_shell_check "opengl" "glxinfo -B 2>/dev/null || true"
run_shell_check "vulkan" "vulkaninfo --summary 2>/dev/null || true"
run_shell_check "sensors" "sensors 2>/dev/null || true"
run_shell_check "thermal_zones" "for f in /sys/class/thermal/thermal_zone*/temp; do [ -f \"$f\" ] && echo \"$f: $(cat \"$f\")\"; done 2>/dev/null || true"
run_check "ip_addr" ip addr
run_check "ip_route" ip route
run_shell_check "dns" "resolvectl status 2>/dev/null || systemd-resolve --status 2>/dev/null || true"

cat > "$OUT_DIR/README.txt" <<EOF
System audit report generated at: $(date -Is)
Folder: $OUT_DIR

Review the txt files and classify each area as:
Good / Warning / High / Critical / Unknown

This script is read-only and intentionally does not fix anything.
EOF

echo "Read-only system audit completed: $OUT_DIR"
