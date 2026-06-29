"""Hardware info collector using psutil and optional read-only commands."""
from __future__ import annotations
import platform
from datetime import datetime, timezone
from typing import Any
import psutil
from sys_assistant.system_tools.safe_command_runner import CommandSpec, SafeCommandRunner
from sys_assistant.system_tools.status import ERROR, OK, UNKNOWN, WARNING, evaluate_threshold, label
from sys_assistant.system_tools.size_utils import human_size

_NVIDIA_SPEC = CommandSpec(id="gpu_nvidia", title="GPU NVIDIA", command=["nvidia-smi", "--query-gpu=name,driver_version,utilization.gpu,temperature.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"], timeout_seconds=5, required=False, run_if_available="nvidia-smi")
_LSPCI_SPEC = CommandSpec(id="gpu_detect", title="Detect GPU", command=["lspci"], timeout_seconds=5, required=False)
_SENSORS_SPEC = CommandSpec(id="temperature", title="Sensors", command=["sensors"], timeout_seconds=5, required=False, run_if_available="sensors")


class HardwareInfoCollector:
    def __init__(self) -> None:
        self._runner = SafeCommandRunner()
        self._prev_net = None
        self._prev_net_time: float | None = None

    def get_hardware_info(self) -> dict[str, Any]:
        hw: dict[str, Any] = {}
        hw["cpu"] = self._get_cpu()
        hw["gpu"] = self._get_gpu()
        hw["ram"] = self._get_ram()
        hw["swap"] = self._get_swap()
        hw["disk"] = self._get_disk()
        hw["network"] = self._get_network()
        hw["battery"] = self._get_battery()
        overall = OK
        for v in hw.values():
            if isinstance(v, dict) and v.get("status") in (WARNING, ERROR):
                if v["status"] == ERROR:
                    overall = ERROR
                elif overall != ERROR:
                    overall = WARNING
        return {"status": overall, "checked_at": datetime.now(timezone.utc).isoformat(), "summary": "Đã lấy thông tin phần cứng.", "hardware": hw}

    def _get_cpu(self) -> dict[str, Any]:
        try:
            cores = psutil.cpu_count(logical=False) or 0
            threads = psutil.cpu_count(logical=True) or 0
            name = platform.processor() or "CPU"
            try:
                with open("/proc/cpuinfo", "r") as f:
                    for line in f:
                        if line.startswith("model name"):
                            name = line.split(":", 1)[1].strip()
                            break
            except (OSError, PermissionError):
                pass
            ui = f"{name[:60]} ({cores} Cores / {threads} Threads)"
            return {"status": OK, "name": name[:100], "cores": cores, "threads": threads, "ui_text": ui}
        except Exception:
            return {"status": UNKNOWN, "name": "", "cores": 0, "threads": 0, "ui_text": "CPU: Không khả dụng"}

    def _get_gpu(self) -> dict[str, Any]:
        nv = self._runner.run(_NVIDIA_SPEC)
        if nv.status == OK and nv.stdout.strip():
            parts = [p.strip() for p in nv.stdout.strip().split(",")]
            if len(parts) >= 6:
                name = parts[0]
                driver = parts[1]
                mem_total = int(float(parts[5]))
                mem_gb = round(mem_total / 1024, 1)
                ui = f"{name} (VRAM: {mem_gb} GB, Driver: {driver})"
                return {"status": OK, "name": name, "driver": driver, "memory_total_mb": mem_total, "ui_text": ui}
        
        # Fallback: lspci
        lspci = self._runner.run(_LSPCI_SPEC)
        if lspci.status == OK:
            for line in lspci.stdout.splitlines():
                lw = line.lower()
                if "vga" in lw or "3d" in lw or "display" in lw:
                    name = line.split(": ", 1)[1].strip()[:80] if ": " in line else line.strip()[:80]
                    return {"status": OK, "name": name, "ui_text": name}
        return {"status": UNKNOWN, "name": "Không khả dụng", "ui_text": "GPU: Không tìm thấy"}

    def _get_ram(self) -> dict[str, Any]:
        try:
            m = psutil.virtual_memory()
            total = round(m.total / (1024**3), 1)
            
            return {"status": OK, "total_gb": total, "ui_text": f"RAM: {total} GB"}
        except Exception:
            return {"status": UNKNOWN, "total_gb": 0, "ui_text": "RAM: Không khả dụng"}

    def _get_swap(self) -> dict[str, Any]:
        try:
            sw = psutil.swap_memory()
            total_gb = round(sw.total / (1024**3), 1)
            used_gb = round(sw.used / (1024**3), 1)
            if sw.total <= 0:
                return {
                    "status": UNKNOWN,
                    "available": False,
                    "total_gb": 0,
                    "used_gb": 0,
                    "percent": 0,
                    "ui_text": "Swap: Không có swap",
                }
            return {
                "status": OK,
                "available": True,
                "total_gb": total_gb,
                "used_gb": used_gb,
                "percent": round(sw.percent, 1),
                "ui_text": f"Swap: {used_gb} / {total_gb} GB ({round(sw.percent)}%)",
            }
        except Exception:
            return {"status": UNKNOWN, "available": False, "total_gb": 0, "used_gb": 0, "percent": 0, "ui_text": "Swap: Không khả dụng"}

    def _get_disk(self) -> dict[str, Any]:
        try:
            total_bytes = 0
            count = 0
            for part in psutil.disk_partitions(all=False):
                try:
                    u = psutil.disk_usage(part.mountpoint)
                    total_bytes += u.total
                    count += 1
                except (OSError, PermissionError):
                    pass
            if total_bytes == 0:
                return {"status": UNKNOWN, "ui_text": "Disk: Không khả dụng"}
            
            total_gb = round(total_bytes / (1024**3), 1)
            return {"status": OK, "total_gb": total_gb, "count": count, "ui_text": f"Tổng dung lượng: {total_gb} GB ({count} phân vùng)"}
        except Exception:
            return {"status": UNKNOWN, "ui_text": "Disk: Không khả dụng"}

    def _get_network(self) -> dict[str, Any]:
        try:
            interfaces = psutil.net_if_addrs()
            valid_ifs = []
            for name, addrs in interfaces.items():
                if name == "lo" or name.startswith("docker") or name.startswith("veth") or name.startswith("br-"):
                    continue
                valid_ifs.append(name)
            
            if not valid_ifs:
                return {"status": OK, "ui_text": "Card mạng: Không có hoặc chỉ có loopback"}
                
            return {"status": OK, "ui_text": f"Card mạng: {', '.join(valid_ifs)}"}
        except Exception:
            return {"status": UNKNOWN, "ui_text": "Card mạng: Không khả dụng"}

    def _get_battery(self) -> dict[str, Any]:
        try:
            battery = psutil.sensors_battery()
            if battery is None:
                return {
                    "status": UNKNOWN,
                    "available": False,
                    "percent": None,
                    "plugged": False,
                    "ui_text": "Pin: Không có pin hoặc không đọc được",
                }
            plugged = bool(battery.power_plugged)
            status = "Đang sạc" if plugged else "Dùng pin"
            return {
                "status": OK,
                "available": True,
                "percent": round(battery.percent, 1),
                "plugged": plugged,
                "ui_text": f"Pin: {round(battery.percent)}% - {status}",
            }
        except Exception:
            return {"status": UNKNOWN, "available": False, "percent": None, "plugged": False, "ui_text": "Pin: Không khả dụng"}
