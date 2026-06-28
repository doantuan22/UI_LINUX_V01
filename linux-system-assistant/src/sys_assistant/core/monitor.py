from __future__ import annotations

from sys_assistant.core import battery, cpu, disk, fan, gpu, memory, network, temperature


class SystemMonitor:
    """Aggregates read-only system statistics."""

    def __init__(self) -> None:
        self._power_profile: str = "unknown"

    def set_power_profile(self, profile: str) -> None:
        self._power_profile = profile

    def collect_all(self) -> dict:
        cpu_info = cpu.get_cpu_info()
        cpu_temp = temperature.get_cpu_temperature()
        gpu_info = gpu.get_gpu_info()
        fan_speed = fan.get_fan_speed()

        return {
            "cpu": {
                "usage": cpu_info["usage"],
                "temp": cpu_temp,
                "freq_ghz": cpu_info.get("freq_ghz"),
            },
            "gpu": gpu_info,
            "ram": memory.get_memory_info(),
            "disk": disk.get_disk_info(),
            "network": network.get_network_info(),
            "fan": {"speed_rpm": fan_speed},
            "battery": battery.get_battery_info(),
            "power_profile": self._power_profile,
        }
