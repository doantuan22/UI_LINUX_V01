from __future__ import annotations

import psutil


def get_battery_info() -> dict | None:
    if not hasattr(psutil, "sensors_battery"):
        return None

    try:
        battery = psutil.sensors_battery()
    except (AttributeError, OSError):
        return None

    if battery is None:
        return None

    return {
        "percent": round(battery.percent, 1),
        "plugged": battery.power_plugged,
    }
