from __future__ import annotations

import shutil
from sys_assistant.managers.command_manager import CommandManager

_gpu_mode = None  # 'pynvml', 'nvidia_smi', 'lspci', or 'none'
_cmd_manager = None
_cached_lspci_name = None
_retry_counter = 0

def _get_cmd_manager() -> CommandManager:
    global _cmd_manager
    if _cmd_manager is None:
        _cmd_manager = CommandManager()
    return _cmd_manager

def _detect_gpu_name_lspci() -> str | None:
    """Try to detect GPU name via lspci for AMD/Intel GPUs using CommandManager."""
    global _cached_lspci_name
    if _cached_lspci_name is not None:
        return _cached_lspci_name

    result = _get_cmd_manager().run_action("check_hardware_gpu")
    if not result.ok:
        return None
    for line in result.stdout.splitlines():
        lower = line.lower()
        if "vga" in lower or "3d" in lower or "display" in lower:
            parts = line.split(": ", 1)
            if len(parts) >= 2:
                _cached_lspci_name = parts[1].strip()[:60]
                return _cached_lspci_name
    return None

def get_gpu_info() -> dict:
    """Return GPU info with status: 'available', 'unsupported', or 'unavailable'."""
    global _gpu_mode
    info: dict = {
        "usage": None,
        "temp": None,
        "name": "unavailable",
        "available": False,
        "status": "unavailable",
    }

    if _gpu_mode in (None, "pynvml"):
        try:
            import pynvml
            pynvml.nvmlInit()
            handle = pynvml.nvmlDeviceGetHandleByIndex(0)
            name = pynvml.nvmlDeviceGetName(handle)
            if isinstance(name, bytes):
                name = name.decode("utf-8", errors="replace")
            util = pynvml.nvmlDeviceGetUtilizationRates(handle)
            temp = pynvml.nvmlDeviceGetTemperature(handle, pynvml.NVML_TEMPERATURE_GPU)
            info.update({
                "usage": util.gpu,
                "temp": temp,
                "name": name,
                "available": True,
                "status": "available",
            })
            pynvml.nvmlShutdown()
            _gpu_mode = "pynvml"
            return info
        except Exception:
            if _gpu_mode == "pynvml":
                _gpu_mode = None

    if _gpu_mode in (None, "nvidia_smi"):
        result = _get_cmd_manager().run_action("nvidia_smi")
        if result.ok and result.stdout.strip():
            parts = [p.strip() for p in result.stdout.strip().split(",")]
            if len(parts) >= 3:
                try:
                    info.update({
                        "usage": int(float(parts[0])),
                        "temp": int(float(parts[1])),
                        "name": parts[2],
                        "available": True,
                        "status": "available",
                    })
                    _gpu_mode = "nvidia_smi"
                    return info
                except ValueError:
                    pass
        if _gpu_mode == "nvidia_smi":
            _gpu_mode = None

    # AMD/Intel fallback: detect GPU name via lspci but usage unsupported
    if _gpu_mode in (None, "lspci"):
        lspci_name = _detect_gpu_name_lspci()
        if lspci_name:
            info["name"] = lspci_name
            info["status"] = "unsupported"
            _gpu_mode = "lspci"
            return info
        if _gpu_mode == "lspci":
            _gpu_mode = None

    if _gpu_mode == "none":
        global _retry_counter
        _retry_counter += 1
        if _retry_counter >= 60:
            _retry_counter = 0
            _gpu_mode = None
        return info

    _gpu_mode = "none"
    return info
