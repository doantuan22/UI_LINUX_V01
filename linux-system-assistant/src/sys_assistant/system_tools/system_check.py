"""System check: runs whitelisted read-only commands and evaluates system health."""
from __future__ import annotations
import re
from datetime import datetime, timezone
from typing import Any
from sys_assistant.system_tools.safe_command_runner import CommandSpec, SafeCommandRunner
from sys_assistant.system_tools.status import (
    ERROR, OK, UNKNOWN, WARNING, evaluate_threshold, label, merge_status,
)

_COMMANDS: list[CommandSpec] = [
    CommandSpec(id="disk_usage", title="Dung lượng ổ đĩa", command=["df", "-hT"], timeout_seconds=3, section="disk"),
    CommandSpec(id="block_devices", title="Thiết bị lưu trữ", command=["lsblk", "-o", "NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL"], timeout_seconds=3, section="disk"),
    CommandSpec(id="memory", title="RAM và Swap", command=["free", "-h"], timeout_seconds=3, section="ram"),
    CommandSpec(id="uptime_load", title="CPU và tải hệ thống", command=["uptime"], timeout_seconds=3, section="cpu"),
    CommandSpec(id="failed_services", title="Service lỗi", command=["systemctl", "--failed", "--no-pager"], timeout_seconds=5, section="service"),
    CommandSpec(id="critical_logs", title="Log lỗi nghiêm trọng", command=["journalctl", "-p", "3", "-xb", "--no-pager", "-n", "80"], timeout_seconds=8, section="log"),
    CommandSpec(id="pci_devices", title="GPU / Driver / PCI", command=["lspci", "-nnk"], timeout_seconds=5, section="gpu"),
    CommandSpec(id="sensors", title="Nhiệt độ / Cảm biến", command=["sensors"], timeout_seconds=5, required=False, run_if_available="sensors", section="temperature"),
    CommandSpec(id="network_ip", title="Địa chỉ mạng", command=["ip", "-brief", "addr"], timeout_seconds=3, section="network"),
    CommandSpec(id="network_route", title="Gateway mạng", command=["ip", "route"], timeout_seconds=3, section="network"),
    CommandSpec(id="nvidia_gpu", title="GPU NVIDIA", command=["nvidia-smi", "--query-gpu=name,driver_version,utilization.gpu,temperature.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"], timeout_seconds=5, required=False, run_if_available="nvidia-smi", section="gpu"),
]

_OVERALL_LABELS = {OK: "Hệ thống tốt", WARNING: "Có cảnh báo", ERROR: "Có lỗi", UNKNOWN: "Không đủ dữ liệu"}
_SECTION_TITLES = {"cpu": "CPU", "gpu": "GPU", "disk": "Ổ đĩa", "ram": "RAM", "service": "Service", "log": "Log", "network": "Mạng", "temperature": "Nhiệt độ"}


class SystemChecker:
    def __init__(self) -> None:
        self._runner = SafeCommandRunner()

    def run_system_check(self) -> dict[str, Any]:
        raw: dict[str, Any] = {}
        for spec in _COMMANDS:
            raw[spec.id] = self._runner.run(spec)
        evaluators = [
            ("disk", self._eval_disk), ("ram", self._eval_ram), ("cpu", self._eval_cpu),
            ("service", self._eval_services), ("log", self._eval_logs), ("gpu", self._eval_gpu),
            ("network", self._eval_network), ("temperature", self._eval_temperature),
        ]
        sections = []
        section_statuses: dict[str, str] = {}
        for key, fn in evaluators:
            s, sec = fn(raw)
            sections.append(sec)
            section_statuses[key] = s
        overall = merge_status(*section_statuses.values())
        ui_summary = []
        for key, title in _SECTION_TITLES.items():
            s = section_statuses.get(key, UNKNOWN)
            ui_summary.append({"id": key, "label": title, "status": s, "status_label": label(s), "text": f"{title}: {label(s)}"})
        return {"overall_status": overall, "overall_label": _OVERALL_LABELS.get(overall, ""), "checked_at": datetime.now(timezone.utc).isoformat(), "ui_summary": ui_summary, "sections": sections}

    def _eval_disk(self, r: dict) -> tuple[str, dict]:
        dr = r.get("disk_usage")
        raw = dr.stdout if dr and dr.status == OK else ""
        items, worst = [], OK
        if raw:
            for line in raw.strip().splitlines()[1:]:
                parts = line.split()
                if len(parts) < 6:
                    continue
                mount, use_str = parts[-1], parts[-2].rstrip("%")
                try:
                    pct = int(use_str)
                except ValueError:
                    continue
                s = evaluate_threshold(pct, 85, (85, 94), 94) if mount == "/tmp" else evaluate_threshold(pct, 80, (80, 90), 90)
                worst = merge_status(worst, s)
                items.append({"mount": mount, "usage_percent": pct, "status": s, "line": line.strip()})
        else:
            worst = ERROR if (dr and dr.status == ERROR) else UNKNOWN
        br = r.get("block_devices")
        block_raw = br.stdout if br and br.status == OK else ""
        return worst, {"id": "disk", "title": "Ổ đĩa", "status": worst, "summary": f"{len(items)} phân vùng" if items else "Không có dữ liệu", "items": items, "raw_output": (raw + "\n\n" + block_raw).strip()[:3000], "suggestion": "Ổ đĩa gần đầy!" if worst == ERROR else ""}

    def _eval_ram(self, r: dict) -> tuple[str, dict]:
        mr = r.get("memory")
        raw = mr.stdout if mr and mr.status == OK else ""
        items, worst = [], OK
        if raw:
            for line in raw.strip().splitlines():
                lw = line.lower()
                if lw.startswith("mem:"):
                    p = line.split()
                    if len(p) >= 3:
                        t, u = self._pmv(p[1]), self._pmv(p[2])
                        if t > 0:
                            pct = round(u / t * 100)
                            s = evaluate_threshold(pct, 80, (80, 90), 90)
                            worst = merge_status(worst, s)
                            items.append({"label": "RAM", "usage_percent": pct, "status": s, "detail": f"{p[2]} / {p[1]}"})
                elif lw.startswith("swap:"):
                    p = line.split()
                    if len(p) >= 3:
                        t, u = self._pmv(p[1]), self._pmv(p[2])
                        if t > 0:
                            pct = round(u / t * 100)
                            s = evaluate_threshold(pct, 50, (50, 80), 80)
                            worst = merge_status(worst, s)
                            items.append({"label": "Swap", "usage_percent": pct, "status": s, "detail": f"{p[2]} / {p[1]}"})
        else:
            worst = ERROR if (mr and mr.status == ERROR) else UNKNOWN
        return worst, {"id": "ram", "title": "RAM", "status": worst, "summary": "; ".join(f"{i['label']}: {i['usage_percent']}%" for i in items) if items else "Không có dữ liệu", "items": items, "raw_output": raw[:2000], "suggestion": ""}

    def _eval_cpu(self, r: dict) -> tuple[str, dict]:
        ur = r.get("uptime_load")
        raw = ur.stdout.strip() if ur and ur.status == OK else ""
        s = OK if raw else (ERROR if (ur and ur.status == ERROR) else UNKNOWN)
        return s, {"id": "cpu", "title": "CPU", "status": s, "summary": raw[:120] if raw else "Không có dữ liệu", "items": [], "raw_output": raw[:2000], "suggestion": ""}

    def _eval_services(self, r: dict) -> tuple[str, dict]:
        sr = r.get("failed_services")
        stdout = sr.stdout if sr else ""
        lines = [l for l in stdout.splitlines() if l.strip() and not l.strip().startswith("UNIT") and not l.startswith("0 loaded") and "loaded" in l.lower()]
        count = len(lines)
        s = OK if count == 0 else (WARNING if count <= 2 else ERROR)
        if not sr or (sr.status not in (OK, ERROR) and not stdout):
            s = UNKNOWN
        return s, {"id": "service", "title": "Service", "status": s, "summary": f"{count} service lỗi", "items": [{"failed_count": count}], "raw_output": stdout[:2000], "suggestion": "Kiểm tra service lỗi." if count > 0 else ""}

    def _eval_logs(self, r: dict) -> tuple[str, dict]:
        lr = r.get("critical_logs")
        stdout = lr.stdout if lr else ""
        lines = [l for l in stdout.splitlines() if l.strip()]
        count = len(lines)
        if not lr or (lr.status not in (OK, ERROR) and not stdout):
            s = UNKNOWN
        elif count == 0:
            s = OK
        elif count <= 10:
            s = WARNING
        else:
            s = ERROR
        return s, {"id": "log", "title": "Log", "status": s, "summary": f"{count} log nghiêm trọng", "items": [{"critical_count": count}], "raw_output": stdout[:3000], "suggestion": ""}

    def _eval_gpu(self, r: dict) -> tuple[str, dict]:
        pci_r, nv_r = r.get("pci_devices"), r.get("nvidia_gpu")
        s, summary, items, raws = UNKNOWN, "Không khả dụng", [], []
        if nv_r and nv_r.status == OK and nv_r.stdout.strip():
            parts = [p.strip() for p in nv_r.stdout.strip().split(",")]
            if len(parts) >= 6:
                summary = f"{parts[0]} (Driver: {parts[1]})"
                s = OK
                items.append({"name": parts[0], "driver": parts[1], "utilization": parts[2] + "%", "temperature": parts[3] + "°C", "memory": f"{parts[4]}/{parts[5]} MiB"})
            raws.append(nv_r.stdout)
        if pci_r and pci_r.status == OK:
            gpu_lines = [l.strip() for l in pci_r.stdout.splitlines() if any(k in l.lower() for k in ("vga", "3d", "display"))]
            if gpu_lines and s == UNKNOWN:
                summary = gpu_lines[0][:100]
                s = WARNING
            raws.append(pci_r.stdout)
        return s, {"id": "gpu", "title": "GPU", "status": s, "summary": summary, "items": items, "raw_output": "\n".join(raws)[:3000], "suggestion": ""}

    def _eval_network(self, r: dict) -> tuple[str, dict]:
        ip_r, rt_r = r.get("network_ip"), r.get("network_route")
        has_ip = has_route = False
        if ip_r and ip_r.status == OK:
            has_ip = any(len(l.split()) >= 3 and l.split()[1] == "UP" for l in ip_r.stdout.splitlines())
        if rt_r and rt_r.status == OK:
            has_route = any(l.startswith("default") for l in rt_r.stdout.splitlines())
        if has_ip and has_route:
            s = OK
        elif has_ip:
            s = WARNING
        elif ip_r and ip_r.status == OK:
            s = ERROR
        else:
            s = UNKNOWN
        raw = (ip_r.stdout if ip_r else "") + "\n\n" + (rt_r.stdout if rt_r else "")
        parts = []
        if has_ip: parts.append("Có IP")
        if has_route: parts.append("Có gateway")
        return s, {"id": "network", "title": "Mạng", "status": s, "summary": ", ".join(parts) if parts else "Không kết nối", "items": [], "raw_output": raw.strip()[:2000], "suggestion": ""}

    def _eval_temperature(self, r: dict) -> tuple[str, dict]:
        sr = r.get("sensors")
        if sr and sr.status == UNKNOWN:
            return UNKNOWN, {"id": "temperature", "title": "Nhiệt độ", "status": UNKNOWN, "summary": "Chưa cài lm-sensors", "items": [], "raw_output": "", "suggestion": "Cài lm-sensors."}
        raw = sr.stdout if sr and sr.status == OK else ""
        items, max_t = [], 0.0
        if raw:
            pat = re.compile(r"[+\-]?(\d+\.?\d*)\s*°C")
            for line in raw.splitlines():
                m = pat.search(line)
                if m:
                    try:
                        t = float(m.group(1))
                        if t > max_t: max_t = t
                        items.append({"line": line.strip()[:100], "temp": t})
                    except ValueError:
                        pass
        s = evaluate_threshold(max_t, 75, (75, 85), 85) if items else UNKNOWN
        return s, {"id": "temperature", "title": "Nhiệt độ", "status": s, "summary": f"Cao nhất: {max_t:.0f}°C" if items else "Không có dữ liệu", "items": items, "raw_output": raw[:2000], "suggestion": "Nhiệt cao!" if s in (WARNING, ERROR) else ""}

    @staticmethod
    def _pmv(val: str) -> float:
        val = val.strip()
        for sfx, m in [("Gi", 1024**3), ("Ti", 1024**4), ("Mi", 1024**2), ("Ki", 1024), ("G", 1024**3), ("T", 1024**4), ("M", 1024**2), ("K", 1024)]:
            if val.endswith(sfx):
                try: return float(val[:-len(sfx)]) * m
                except ValueError: return 0
        try: return float(val)
        except ValueError: return 0
