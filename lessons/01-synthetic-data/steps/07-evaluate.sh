#!/usr/bin/env bash
# MERO 객체인식 입문: perception/generation에서 시작
# 코드 출처·사용 조건: 별도 출처 기록 및 LICENSE
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
cd ../..
yolo segment val model=runs/perception/smoke120_a1/weights/best.pt data=perception/generation/datasets/smoke120_models/a1_objectseg/data.yaml imgsz=640 split=test device=cpu
yolo segment val model=runs/perception/smoke120_face/weights/best.pt data=perception/generation/datasets/smoke120_face/data.yaml imgsz=224 split=test device=cpu
