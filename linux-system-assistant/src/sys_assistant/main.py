from __future__ import annotations

from sys_assistant.app import run


import os
import sys

def main() -> None:
    if hasattr(os, "geteuid") and os.geteuid() == 0:
        sys.exit("Error: Do not run Linux System Assistant as root!")
    raise SystemExit(run())


if __name__ == "__main__":
    main()
