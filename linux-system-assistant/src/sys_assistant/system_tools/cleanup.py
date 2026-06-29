"""Cleanup scanner and runner: safely scan and clean whitelisted cache directories."""
from __future__ import annotations
import shutil
from pathlib import Path
from typing import Any
from sys_assistant.system_tools.size_utils import dir_size_safe, human_size
from sys_assistant.system_tools.status import CLEANED, EMPTY, ERROR, OK, SKIPPED, UNKNOWN, WARNING, label

_PERSONAL_DIRS = frozenset({"Documents", "Downloads", "Desktop", "Pictures", "Videos", "Music"})

_TARGETS = [
    {"id": "thumbnail_cache", "title": "Thumbnail cache", "path": "~/.cache/thumbnails", "safe_level": "safe", "default_selected": True, "description": "Cache ảnh thu nhỏ, có thể xóa an toàn."},
    {"id": "fontconfig_cache", "title": "Fontconfig cache", "path": "~/.cache/fontconfig", "safe_level": "safe", "default_selected": False, "description": "Cache font, có thể được tạo lại."},
    {"id": "gstreamer_cache", "title": "GStreamer cache", "path": "~/.cache/gstreamer-1.0", "safe_level": "safe", "default_selected": False, "description": "Cache multimedia, có thể được tạo lại."},
    {"id": "pip_cache", "title": "pip cache", "path": "~/.cache/pip", "safe_level": "safe", "default_selected": False, "description": "Cache package Python."},
    {"id": "npm_cache", "title": "npm cache", "path": "~/.npm/_cacache", "safe_level": "safe", "default_selected": False, "description": "Cache package npm."},
    {"id": "trash", "title": "Thùng rác", "path": "~/.local/share/Trash", "safe_level": "confirm", "default_selected": False, "description": "Dữ liệu trong thùng rác. Cần xác nhận riêng."},
]


class CleanupScanner:
    def __init__(self) -> None:
        self._home = Path.home().resolve()

    def scan(self) -> dict[str, Any]:
        targets = []
        total_bytes = 0
        for tgt in _TARGETS:
            resolved = self._resolve_safe(tgt["path"])
            if resolved is None:
                targets.append({"id": tgt["id"], "title": tgt["title"], "path": tgt["path"], "exists": False, "size_bytes": 0, "size_label": "0 B", "item_count": 0, "safe_level": tgt["safe_level"], "default_selected": tgt["default_selected"], "description": tgt["description"], "status": UNKNOWN, "status_label": "Không tìm thấy"})
                continue
            if not resolved.exists():
                targets.append({"id": tgt["id"], "title": tgt["title"], "path": str(resolved), "exists": False, "size_bytes": 0, "size_label": "0 B", "item_count": 0, "safe_level": tgt["safe_level"], "default_selected": False, "description": tgt["description"], "status": EMPTY, "status_label": label(EMPTY)})
                continue
            sz, cnt = dir_size_safe(resolved)
            total_bytes += sz
            st = OK if sz > 0 else EMPTY
            sl = WARNING if tgt["safe_level"] == "confirm" and sz > 0 else label(st)
            targets.append({"id": tgt["id"], "title": tgt["title"], "path": str(resolved), "exists": True, "size_bytes": sz, "size_label": human_size(sz), "item_count": cnt, "safe_level": tgt["safe_level"], "default_selected": tgt["default_selected"] if sz > 0 else False, "description": tgt["description"], "status": st if tgt["safe_level"] != "confirm" else (WARNING if sz > 0 else EMPTY), "status_label": sl})
        return {"status": OK, "summary": f"Tìm thấy {len([t for t in targets if t['size_bytes'] > 0])} mục có thể dọn.", "total_cleanable_bytes": total_bytes, "total_cleanable_label": human_size(total_bytes), "targets": targets}

    def run_cleanup(self, selected_ids: list[str], confirm_trash: bool = False) -> dict[str, Any]:
        valid_ids = {t["id"] for t in _TARGETS}
        cleaned_targets = []
        errors = []
        total_cleaned = 0
        for tid in selected_ids:
            if tid not in valid_ids:
                errors.append({"id": tid, "error": "ID không hợp lệ."})
                continue
            tgt = next(t for t in _TARGETS if t["id"] == tid)
            if tgt["safe_level"] == "confirm" and not confirm_trash:
                cleaned_targets.append({"id": tid, "title": tgt["title"], "status": SKIPPED, "cleaned_bytes": 0, "cleaned_label": "0 B", "message": "Cần xác nhận riêng cho thùng rác."})
                continue
            resolved = self._resolve_safe(tgt["path"])
            if resolved is None or not resolved.exists():
                cleaned_targets.append({"id": tid, "title": tgt["title"], "status": SKIPPED, "cleaned_bytes": 0, "cleaned_label": "0 B", "message": "Không tồn tại."})
                continue
            sz_before, _ = dir_size_safe(resolved)
            failed = self._delete_contents(resolved)
            sz_after, _ = dir_size_safe(resolved)
            freed = max(sz_before - sz_after, 0)
            total_cleaned += freed
            st = CLEANED if not failed else WARNING
            if failed:
                errors.extend(failed)
            cleaned_targets.append({"id": tid, "title": tgt["title"], "status": st, "cleaned_bytes": freed, "cleaned_label": human_size(freed), "message": f"Đã dọn {human_size(freed)}" + (f" ({len(failed)} lỗi)" if failed else "")})
        return {"status": OK if not errors else WARNING, "summary": f"Đã dọn {human_size(total_cleaned)}.", "cleaned_bytes": total_cleaned, "cleaned_label": human_size(total_cleaned), "cleaned_targets": cleaned_targets, "errors": errors}

    def _resolve_safe(self, raw_path: str) -> Path | None:
        expanded = Path(raw_path).expanduser()
        if expanded.is_symlink():
            return None
        resolved = expanded.resolve()
        try:
            resolved.relative_to(self._home)
        except ValueError:
            return None
        for part in resolved.parts:
            if part in _PERSONAL_DIRS and resolved.parent == self._home:
                return None
        return resolved

    @staticmethod
    def _delete_contents(path: Path) -> list[dict[str, str]]:
        failed = []
        try:
            for child in list(path.iterdir()):
                try:
                    if child.is_symlink():
                        child.unlink()
                    elif child.is_file():
                        child.unlink()
                    elif child.is_dir():
                        shutil.rmtree(child)
                except (OSError, PermissionError) as e:
                    failed.append({"path": str(child), "error": str(e)})
        except (OSError, PermissionError) as e:
            failed.append({"path": str(path), "error": str(e)})
        return failed
