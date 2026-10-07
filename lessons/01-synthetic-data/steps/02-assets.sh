#!/usr/bin/env bash
# MERO 객체인식 입문: 저장소 루트에서 시작
# 코드 출처·사용 조건: 별도 출처 기록 및 LICENSE
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
cd perception/generation
python prepare_assets.py --out datasets/fruit_textures/public_fruits360_256 --per-class 256
python scripts/make_polyhedron_objs.py --out assets/generated --size 0.08
