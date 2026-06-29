from __future__ import annotations

from PySide6.QtCore import QObject, QRunnable, QThreadPool, QTimer, Signal, Slot

from sys_assistant.core.monitor import SystemMonitor


class _PollSignals(QObject):
    finished = Signal(dict)


class _PollTask(QRunnable):
    def __init__(self, monitor: SystemMonitor, signal_parent: QObject | None = None) -> None:
        super().__init__()
        self.setAutoDelete(False)
        self.monitor = monitor
        self.signals = _PollSignals(signal_parent)

    def run(self) -> None:
        stats = self.monitor.collect_all()
        try:
            self.signals.finished.emit(stats)
        except RuntimeError:
            # The polling service may have been destroyed during shutdown.
            return


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
        self._thread_pool = QThreadPool.globalInstance()
        self._busy = False
        self._current_task: _PollTask | None = None

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
        if self._busy:
            return
        self._busy = True
        task = _PollTask(self.monitor, signal_parent=self)
        self._current_task = task
        task.signals.finished.connect(self._on_poll_finished)
        self._thread_pool.start(task)

    @Slot(dict)
    def _on_poll_finished(self, stats: dict) -> None:
        self._busy = False
        self._current_task = None
        self.statsUpdated.emit(stats)
