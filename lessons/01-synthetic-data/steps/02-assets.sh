#!/usr/bin/env bash
# MERO 객체인식 입문: 저장소 루트에서 시작
# Source: YenCho/ddonggae @ d85758c752e6cd3244e16d9ea4a3d2831da225b4
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
cd perception/generation
python prepare_assets.py --out datasets/fruit_textures/public_fruits360_256 --per-class 256
python scripts/make_polyhedron_objs.py --out assets/generated --size 0.08
