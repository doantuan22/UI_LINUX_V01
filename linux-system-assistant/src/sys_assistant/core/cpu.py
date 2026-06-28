from __future__ import annotations

import psutil


def get_cpu_usage() -> float:
    return psutil.cpu_percent(interval=None)


def get_cpu_freq_ghz() -> float | None:
    freq = psutil.cpu_freq()
    if freq is None:
        return None
    return round(freq.current / 1000, 2)


def get_cpu_info() -> dict:
    return {
        "usage": round(get_cpu_usage(), 1),
        "freq_ghz": get_cpu_freq_ghz(),
    }
