"""Safe size calculation utilities."""

from __future__ import annotations

from pathlib import Path


def human_size(num_bytes: int) -> str:
    """Format bytes into human-readable string."""
    if num_bytes < 0:
        num_bytes = 0
    units = ["B", "KB", "MB", "GB", "TB"]
    size = float(num_bytes)
    for unit in units:
        if size < 1024 or unit == units[-1]:
            if unit == "B":
                return f"{int(size)} {unit}"
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{num_bytes} B"


def dir_size_safe(path: Path) -> tuple[int, int]:
    """Calculate total size and file count of a directory without following symlinks.

    Returns:
        (total_bytes, file_count)
    """
    total = 0
    count = 0
    if not path.is_dir():
        return 0, 0

    import os

    try:
        def scan_dir_recursive(dir_path: str):
            nonlocal total, count
            try:
                with os.scandir(dir_path) as it:
                    for entry in it:
                        try:
                            if entry.is_symlink():
                                continue
                            if entry.is_dir(follow_symlinks=False):
                                scan_dir_recursive(entry.path)
                            elif entry.is_file(follow_symlinks=False):
                                total += entry.stat().st_size
                                count += 1
                        except (OSError, PermissionError):
                            pass
            except (OSError, PermissionError):
                pass
        
        scan_dir_recursive(str(path))
    except Exception:
        pass

    return total, count
