#!/usr/bin/env bash
# MERO 객체인식 입문: perception/generation에서 시작
# Source: YenCho/ddonggae @ d85758c752e6cd3244e16d9ea4a3d2831da225b4
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
