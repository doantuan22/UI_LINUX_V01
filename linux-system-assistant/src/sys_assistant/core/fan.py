from __future__ import annotations

import psutil


def get_fan_speed() -> int | None:
    if not hasattr(psutil, "sensors_fans"):
        return None

    try:
        fans = psutil.sensors_fans()
    except (AttributeError, OSError):
        return None

    if not fans:
        return None

    for entries in fans.values():
        for entry in entries:
            if entry.current is not None and entry.current > 0:
                return int(entry.current)

    return None
