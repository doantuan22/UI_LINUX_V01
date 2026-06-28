from __future__ import annotations

from sys_assistant.core import cpu, disk, memory
from sys_assistant.core.monitor import SystemMonitor


def test_cpu_usage_range():
    usage = cpu.get_cpu_usage()
    assert 0 <= usage <= 100


def test_memory_info_keys():
    info = memory.get_memory_info()
    assert "usage" in info
    assert "used_gb" in info
    assert "total_gb" in info
    assert info["total_gb"] > 0


def test_disk_info_keys():
    info = disk.get_disk_info()
    assert "usage" in info
    assert info["total_gb"] > 0


from unittest.mock import patch, MagicMock

@patch("sys_assistant.core.gpu.CommandManager.run_action")
def test_monitor_collect_all(mock_run):
    mock_run.return_value = MagicMock(ok=False)
    monitor = SystemMonitor()
    stats = monitor.collect_all()
    assert isinstance(stats, dict)
    
    assert "cpu" in stats
    assert "ram" in stats
    assert "disk" in stats
    assert "network" in stats
    assert "gpu" in stats
