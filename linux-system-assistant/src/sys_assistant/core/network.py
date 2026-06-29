from __future__ import annotations

import time

import psutil


_prev_counters = None
_prev_time: float | None = None


def _active_counters():
    per_nic = psutil.net_io_counters(pernic=True)
    try:
        nic_stats = psutil.net_if_stats()
    except (OSError, PermissionError):
        nic_stats = {}
    active = []

    for name, counters in per_nic.items():
        lower_name = name.lower()
        stats = nic_stats.get(name)
        if lower_name == "lo" or lower_name.startswith(("docker", "veth", "br-", "virbr")):
            continue
        if stats is not None and not stats.isup:
            continue
        active.append(counters)

    if not active:
        return psutil.net_io_counters()

    fields = active[0]._fields
    values = {field: sum(getattr(item, field) for item in active) for field in fields}
    return type(active[0])(**values)


def get_network_info() -> dict:
    global _prev_counters, _prev_time

    counters = _active_counters()
    now = time.time()

    download_mb_s = 0.0
    upload_mb_s = 0.0

    if _prev_counters is not None and _prev_time is not None:
        elapsed = max(now - _prev_time, 0.001)
        download_mb_s = round(
            (counters.bytes_recv - _prev_counters.bytes_recv) / elapsed / (1024**2),
            2,
        )
        upload_mb_s = round(
            (counters.bytes_sent - _prev_counters.bytes_sent) / elapsed / (1024**2),
            2,
        )

    _prev_counters = counters
    _prev_time = now

    return {
        "download_mb_s": max(download_mb_s, 0.0),
        "upload_mb_s": max(upload_mb_s, 0.0),
        "bytes_recv": counters.bytes_recv,
        "bytes_sent": counters.bytes_sent,
    }
