"""Unified status constants, labels, and helpers for system tools."""

from __future__ import annotations

# --- Status constants ---
OK = "ok"
WARNING = "warning"
ERROR = "error"
UNKNOWN = "unknown"
TIMEOUT = "timeout"
EMPTY = "empty"
CLEANED = "cleaned"
SKIPPED = "skipped"

# --- Vietnamese labels ---
STATUS_LABELS: dict[str, str] = {
    OK: "Tốt",
    WARNING: "Cảnh báo",
    ERROR: "Lỗi",
    UNKNOWN: "Không khả dụng",
    TIMEOUT: "Quá thời gian",
    EMPTY: "Trống",
    CLEANED: "Đã dọn",
    SKIPPED: "Đã bỏ qua",
}

# --- Severity order (higher index = more severe) ---
_SEVERITY: list[str] = [OK, UNKNOWN, TIMEOUT, WARNING, ERROR]


def label(status: str) -> str:
    """Return Vietnamese label for a status code."""
    return STATUS_LABELS.get(status, status)


def merge_status(*statuses: str) -> str:
    """Return the most severe status from a collection."""
    worst = OK
    worst_idx = 0
    for s in statuses:
        try:
            idx = _SEVERITY.index(s)
        except ValueError:
            idx = 0
        if idx > worst_idx:
            worst_idx = idx
            worst = s
    return worst


def evaluate_threshold(
    value: float,
    ok_below: float,
    warning_range: tuple[float, float],
    error_above: float,
) -> str:
    """Evaluate a numeric value against thresholds."""
    if value < ok_below:
        return OK
    if warning_range[0] <= value <= warning_range[1]:
        return WARNING
    if value > error_above:
        return ERROR
    return WARNING  # fallback for edge
