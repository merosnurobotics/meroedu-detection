#!/usr/bin/env bash
# MERO 객체인식 입문: perception/generation에서 시작
# Source: YenCho/ddonggae @ d85758c752e6cd3244e16d9ea4a3d2831da225b4
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
python scripts/split_meta_v2_dataset.py \
  --dataset datasets/smoke120 \
  --out datasets/smoke120/split.json --seed 20261006 \
  --val-ratio 0.10 --test-ratio 0.10
