#!/usr/bin/env bash
# MERO 객체인식 입문: perception/generation에서 시작
# 코드 출처·사용 조건: 별도 출처 기록 및 LICENSE
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
python ../training/train_segmentation.py \
  --task a1 \
  --data datasets/smoke120_models/a1_objectseg/data.yaml \
  --init yolo26s-seg.yaml --epochs 1 --batch 4 --workers 0 \
  --device cpu --seed 31000000 --lr 0.001 \
  --project ../../runs/perception --name smoke120_a1

python ../training/train_segmentation.py \
  --task face \
  --data datasets/smoke120_face/data.yaml \
  --init yolo26s-seg.yaml --epochs 1 --batch 4 --workers 0 \
  --device cpu --seed 31000000 --lr 0.001 --hsv-h 0 \
  --project ../../runs/perception --name smoke120_face
