from __future__ import annotations

import psutil


def get_cpu_temperature() -> float | None:
    if not hasattr(psutil, "sensors_temperatures"):
        return None

    try:
        temps = psutil.sensors_temperatures()
    except (AttributeError, OSError):
        return None

    if not temps:
        return None

    for name in ("coretemp", "k10temp", "cpu_thermal", "acpitz"):
        if name in temps and temps[name]:
            return round(temps[name][0].current, 1)

    for entries in temps.values():
        if entries:
            return round(entries[0].current, 1)

    return None
