from __future__ import annotations

import time

import psutil


_prev_counters = None
_prev_time: float | None = None


def get_network_info() -> dict:
    global _prev_counters, _prev_time

    counters = psutil.net_io_counters()
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
    }
