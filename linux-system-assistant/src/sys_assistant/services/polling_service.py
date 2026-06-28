from __future__ import annotations

from PySide6.QtCore import QObject, QTimer, Signal

from sys_assistant.core.monitor import SystemMonitor


class PollingService(QObject):
    statsUpdated = Signal(dict)

    def __init__(
        self,
        monitor: SystemMonitor,
        interval_ms: int = 1000,
        parent: QObject | None = None,
    ) -> None:
        super().__init__(parent)
        self.monitor = monitor
        self.interval_ms = interval_ms
        self._timer = QTimer(self)
        self._timer.timeout.connect(self._poll)

    def start(self) -> None:
        self._poll()
        self._timer.start(self.interval_ms)

    def stop(self) -> None:
        self._timer.stop()

    def set_interval(self, interval_ms: int) -> None:
        self.interval_ms = interval_ms
        if self._timer.isActive():
            self._timer.start(interval_ms)

    def _poll(self) -> None:
        stats = self.monitor.collect_all()
        self.statsUpdated.emit(stats)
