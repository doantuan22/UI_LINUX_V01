from __future__ import annotations

from collections import namedtuple
from unittest.mock import MagicMock, patch

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
    assert "available_gb" in info
    assert info["total_gb"] > 0


def test_memory_used_matches_available():
    mem = MagicMock()
    mem.total = 8 * 1024**3
    mem.available = 5 * 1024**3
    mem.percent = 37.5

    with patch("sys_assistant.core.memory.psutil.virtual_memory", return_value=mem):
        info = memory.get_memory_info()

    assert info["usage"] == 37.5
    assert info["used_gb"] == 3.0
    assert info["available_gb"] == 5.0


def test_disk_info_keys():
    info = disk.get_disk_info()
    assert "usage" in info
    assert info["total_gb"] > 0


def test_network_uses_active_non_loopback_interfaces():
    from sys_assistant.core import network

    counter = namedtuple(
        "snetio",
        "bytes_sent bytes_recv packets_sent packets_recv errin errout dropin dropout",
    )
    stats = namedtuple("snicstats", "isup duplex speed mtu")

    with patch(
        "sys_assistant.core.network.psutil.net_io_counters",
        side_effect=[
            {
                "lo": counter(1000, 2000, 0, 0, 0, 0, 0, 0),
                "wlan0": counter(3 * 1024**2, 7 * 1024**2, 0, 0, 0, 0, 0, 0),
            },
            {
                "lo": counter(2000, 3000, 0, 0, 0, 0, 0, 0),
                "wlan0": counter(5 * 1024**2, 9 * 1024**2, 0, 0, 0, 0, 0, 0),
            },
        ],
    ), patch(
        "sys_assistant.core.network.psutil.net_if_stats",
        return_value={
            "lo": stats(True, 0, 0, 1500),
            "wlan0": stats(True, 0, 1000, 1500),
        },
    ), patch("sys_assistant.core.network.time.time", side_effect=[100.0, 101.0]):
        network._prev_counters = None
        network._prev_time = None
        first = network.get_network_info()
        second = network.get_network_info()

    assert first["bytes_recv"] == 7 * 1024**2
    assert first["bytes_sent"] == 3 * 1024**2
    assert second["bytes_recv"] == 9 * 1024**2
    assert second["bytes_sent"] == 5 * 1024**2
    assert second["download_mb_s"] > 0
    assert second["upload_mb_s"] > 0



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
