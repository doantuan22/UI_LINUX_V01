from __future__ import annotations

import psutil


def get_memory_info() -> dict:
    mem = psutil.virtual_memory()
    total_gb = round(mem.total / (1024**3), 1)
    used_gb = round(mem.used / (1024**3), 1)
    return {
        "usage": round(mem.percent, 1),
        "used_gb": used_gb,
        "total_gb": total_gb,
    }
