from __future__ import annotations

import shutil
import subprocess


def get_gpu_info() -> dict:
    info: dict = {
        "usage": None,
        "temp": None,
        "name": "unavailable",
        "available": False,
    }

    try:
        import pynvml

        pynvml.nvmlInit()
        handle = pynvml.nvmlDeviceGetHandleByIndex(0)
        name = pynvml.nvmlDeviceGetName(handle)
        if isinstance(name, bytes):
            name = name.decode("utf-8", errors="replace")
        util = pynvml.nvmlDeviceGetUtilizationRates(handle)
        temp = pynvml.nvmlDeviceGetTemperature(handle, pynvml.NVML_TEMPERATURE_GPU)
        info.update(
            {
                "usage": util.gpu,
                "temp": temp,
                "name": name,
                "available": True,
            }
        )
        pynvml.nvmlShutdown()
        return info
    except Exception:
        pass

    if shutil.which("nvidia-smi"):
        try:
            result = subprocess.run(
                [
                    "nvidia-smi",
                    "--query-gpu=utilization.gpu,temperature.gpu,name",
                    "--format=csv,noheader,nounits",
                ],
                shell=False,
                capture_output=True,
                text=True,
                timeout=5,
                check=False,
            )
            if result.returncode == 0 and result.stdout.strip():
                parts = [p.strip() for p in result.stdout.strip().split(",")]
                if len(parts) >= 3:
                    info.update(
                        {
                            "usage": int(float(parts[0])),
                            "temp": int(float(parts[1])),
                            "name": parts[2],
                            "available": True,
                        }
                    )
        except (OSError, subprocess.TimeoutExpired, ValueError):
            pass

    return info
