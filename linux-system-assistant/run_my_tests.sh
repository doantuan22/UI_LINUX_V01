#!/usr/bin/env bash
source .venv/bin/activate
export QT_QPA_PLATFORM=offscreen
export PYTHONPATH=$PWD/src
pytest -v tests/ > pytest_output.txt 2>&1
pyright > pyright_output.txt 2>&1
