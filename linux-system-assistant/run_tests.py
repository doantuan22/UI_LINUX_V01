import pytest
import sys

if __name__ == "__main__":
    with open("pytest_output.txt", "w") as f:
        sys.stdout = f
        sys.stderr = f
        exit_code = pytest.main(["-v", "tests/"])
        f.write(f"\nExit code: {exit_code}\n")
    sys.exit(0)
