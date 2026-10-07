# 객체인식 · 전체 학습 설정과 실행 순서

작성자: 조연우 · yencho929@snu.ac.kr

이 문서는 교육 저장소만 clone한 상태에서 데이터 생성부터 두 모델의 평가까지 연결하는 Bash 안내입니다. 원본 프로젝트의 폴더나 별도 코드를 받을 필요가 없습니다. 먼저 웹 강의의 CPU 120장 실습으로 사진·정답·메타데이터가 생성되는지 확인한 뒤 확장합니다. 50,000장과 학습 epoch는 실행 예시이며 모든 문제에 필요한 최소 설정은 아닙니다.

## 1. 환경과 시작 경로

Linux 또는 Windows WSL, Git, Python 3.11, NVIDIA GPU와 드라이버, 인터넷 및 충분한 저장공간이 필요합니다. 모든 명령은 같은 Bash 터미널에서 순서대로 실행합니다. 생성·학습에는 오랜 시간이 걸릴 수 있습니다. 데이터 장수·batch·worker는 장비에 맞게 조정하고 설정을 기록합니다.

```bash
cd ~
git clone https://github.com/merosnurobotics/meroedu-detection.git
cd meroedu-detection/lessons/01-synthetic-data
python3.11 -m venv .venv-perception
source .venv-perception/bin/activate
python -m pip install --upgrade pip
python -m pip install torch==2.10.0 torchvision==0.25.0 --index-url https://download.pytorch.org/whl/cu128
python -m pip install -r perception/generation/requirements.txt
python -c 'import torch; print(torch.__version__, torch.cuda.is_available())'
nvidia-smi
```

이미 clone했다면 그 저장소에서 `git pull --ff-only` 후 강의 폴더로 이동합니다. 위 Torch wheel은 CUDA 12.8 환경의 예시입니다. 장비와 호환되지 않으면 [PyTorch 공식 설치 안내](https://pytorch.org/get-started/locally/)에서 환경에 맞는 wheel을 선택합니다. `torch.cuda.is_available()`이 True인지 확인하고 `python -m pip freeze`와 드라이버 정보를 기록합니다. 모델은 `yolo26s-seg.yaml` 아키텍처에서 시작하며 이 강의의 기존 가중치를 다운로드할 필요가 없습니다.

## 2. 재료 준비와 렌더

아래 첫 명령은 강의 폴더에서 시작해 재료를 준비하고 `perception/generation`으로 이동합니다. Fruits-360의 해시와 출처 manifest를 데이터와 함께 유지합니다.

```bash
source steps/02-assets.sh
# 현재 경로: lessons/01-synthetic-data/perception/generation
source ../../steps/full-render.sh
```

`datasets/public_fruits360_arena_v1/images/train`, `labels/train`, `_meta/train`의 사진·정답·메타데이터를 비교합니다. 이미지와 라벨이 어긋나거나 누락되면 다음 단계로 진행하지 않습니다. 목표 물체가 없는 사진의 빈 라벨은 정상일 수 있습니다. 렌더 옵션은 `steps/full-render.sh`에 모두 들어 있습니다. 처음에는 worker 하나를 사용합니다.

## 3. 장면별 분리

계속 `perception/generation`에서 실행합니다. 같은 장면에서 나온 여러 크롭이 서로 다른 split으로 가지 않도록 먼저 장면 단위 manifest를 만듭니다.

```bash
python scripts/split_meta_v2_dataset.py \
  --dataset datasets/public_fruits360_arena_v1 \
  --out datasets/public_fruits360_arena_v1/split.json --seed 20261006 \
  --val-ratio 0.10 --test-ratio 0.10
```

## 4. 두 모델의 데이터셋 내보내기

A1은 전체 장면에서 형태를 찾고, face 모델은 큐브 크롭의 과일 면을 찾습니다. 클래스 순서는 내보낸 YAML 그대로 사용합니다.

```bash
python scripts/export_meta_v2_model_datasets.py \
  --source_dataset datasets/public_fruits360_arena_v1 \
  --output_root datasets/public_fruits360_arena_v1_models \
  --split_manifest datasets/public_fruits360_arena_v1/split.json \
  --splits train --tasks a1 --copy_mode hardlink --reset

python scripts/export_meta_v2_cube_face_unified_dataset.py \
  --source_dataset datasets/public_fruits360_arena_v1 \
  --output_root datasets/public_fruits360_arena_v1_face \
  --source_split train \
  --split_manifest datasets/public_fruits360_arena_v1/split.json \
  --seed 20261006 --crop_size 224 --crop_pad 0.18 --reset
```

A1 결과는 `datasets/public_fruits360_arena_v1_models/a1_objectseg`, face 결과는 `datasets/public_fruits360_arena_v1_face`입니다. YAML의 train/val/test 경로를 열어 확인합니다. `--reset`은 해당 export 출력 폴더를 다시 만드는 옵션이므로 처음 실행하거나 재생성할 폴더를 확인한 상태에서 사용합니다.

## 5. 학습

계속 `perception/generation`에서 실행합니다. A1은 140 epoch, face는 120 epoch의 예시입니다. GPU 메모리가 부족하면 batch를 줄입니다. 같은 run 이름은 재사용하지 않으므로 다시 학습할 때는 `--name`과 아래 평가의 model 경로를 함께 바꿉니다.

```bash
python ../training/train_segmentation.py \
  --task a1 \
  --data datasets/public_fruits360_arena_v1_models/a1_objectseg/data.yaml \
  --init yolo26s-seg.yaml --epochs 140 --batch 32 --workers 4 \
  --device 0 --seed 31000000 --lr 0.001 \
  --project ../../runs/perception --name public_fruits360_arena_v1_a1

python ../training/train_segmentation.py \
  --task face \
  --data datasets/public_fruits360_arena_v1_face/data.yaml \
  --init yolo26s-seg.yaml --epochs 120 --batch 32 --workers 4 \
  --device 0 --seed 31000000 --lr 0.001 --hsv-h 0 \
  --project ../../runs/perception --name public_fruits360_arena_v1_face
```

가중치는 강의 폴더의 `runs/perception/public_fruits360_arena_v1_a1/weights/best.pt`와 `public_fruits360_arena_v1_face/weights/best.pt`에 저장됩니다. Epoch는 데이터를 한 바퀴 보는 단위입니다. Training loss만으로 실제 카메라 성능을 판단하지 않습니다.

## 6. 학습에 쓰지 않은 split으로 평가

첫 명령으로 강의 폴더로 돌아온 후 평가합니다.

```bash
cd ../..
yolo segment val model=runs/perception/public_fruits360_arena_v1_a1/weights/best.pt data=perception/generation/datasets/public_fruits360_arena_v1_models/a1_objectseg/data.yaml imgsz=640 split=test device=0
yolo segment val model=runs/perception/public_fruits360_arena_v1_face/weights/best.pt data=perception/generation/datasets/public_fruits360_arena_v1_face/data.yaml imgsz=224 split=test device=0
```

합성 test 점수와 실제 사진 결과를 함께 봅니다. 실제 큐브 크롭이 준비되면 `scripts/predict_examples.py --model runs/perception/public_fruits360_arena_v1_face/weights/best.pt --source my-crop.jpg --output runs/my-predictions --imgsz 224 --device 0`으로 입력과 mask를 비교할 수 있습니다. 이 문서의 명령은 전체 렌더와 학습을 새로 완료했다는 결과 보고가 아닙니다.

## 7. COCO 배경으로 변경

기본 예시는 방 형태 배경을 생성합니다. COCO 사진으로 바꾸려면 `perception/generation`에서 준비합니다.

```bash
python scripts/download_coco2017_backgrounds.py --split val2017 --output datasets/backgrounds/coco2017
```

`steps/full-render.sh`를 별도 실험용으로 복사해 `--background_dir`을 `datasets/backgrounds/coco2017/val2017`, `--arena_background_ratio`를 `0.0`으로 바꿉니다. 새 seed와 출력 폴더를 사용하고, 이 문서의 split/export/train/evaluate 경로도 새 출력 이름으로 일관되게 바꿉니다. 사진 배경의 원래 사물은 목표 클래스 라벨로 사용하지 않습니다.

코드 출처·사용 조건은 저장소의 `UPSTREAM.json`과 `LICENSE`, 다운로드된 데이터의 attribution manifest에 기록돼 있습니다.
