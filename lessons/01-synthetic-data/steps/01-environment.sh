#!/usr/bin/env bash
# MERO 객체인식 입문: 저장소 루트에서 시작
# Source: YenCho/ddonggae @ d85758c752e6cd3244e16d9ea4a3d2831da225b4
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
python3.11 -m venv .venv-perception
source .venv-perception/bin/activate
python -m pip install --upgrade pip
python -m pip install torch==2.10.0 torchvision==0.25.0 --index-url https://download.pytorch.org/whl/cpu
python -m pip install -r perception/generation/requirements.txt
python -c 'import torch, torchvision, blenderproc, bpy, ultralytics; print(torch.__version__, torchvision.__version__, ultralytics.__version__, bpy.app.version_string)'
