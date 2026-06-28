from __future__ import annotations

import psutil


def get_disk_info() -> dict:
    usage = psutil.disk_usage("/")
    total_gb = round(usage.total / (1024**3), 1)
    used_gb = round(usage.used / (1024**3), 1)
    return {
        "usage": round(usage.percent, 1),
        "used_gb": used_gb,
        "total_gb": total_gb,
    }
