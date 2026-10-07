#!/usr/bin/env bash
# MERO 객체인식 입문: perception/generation에서 시작
# 코드 출처·사용 조건: 별도 출처 기록 및 LICENSE
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
python scripts/export_meta_v2_model_datasets.py \
  --source_dataset datasets/smoke120 \
  --output_root datasets/smoke120_models \
  --split_manifest datasets/smoke120/split.json \
  --splits train --tasks a1 --copy_mode hardlink --reset

python scripts/export_meta_v2_cube_face_unified_dataset.py \
  --source_dataset datasets/smoke120 \
  --output_root datasets/smoke120_face \
  --source_split train \
  --split_manifest datasets/smoke120/split.json \
  --seed 20261006 --crop_size 224 --crop_pad 0.18 --reset
