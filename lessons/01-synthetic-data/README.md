# 01 · 합성 데이터로 시작하는 객체인식

사진 속 물체의 형태와 과일 면을 알아내는 두 모델을 만들면서 데이터 생성→정답 확인→분리→학습→평가 흐름을 배웁니다.

## 먼저 이해할 것

- Classification은 이미지가 무엇인지, detection은 무엇이 어디에 있는지, instance segmentation은 각 물체의 픽셀 영역을 묻습니다. 이 실습은 YOLO segmentation 모델을 사용합니다.
- 지도학습에는 이미지와 라벨(정답)이 함께 필요합니다. 합성 데이터는 Blender에서 이미지와 보이는 물체의 경계를 함께 계산해 만듭니다.
- 배경·회전·조명 등을 바꾸는 도메인 랜덤화는 우연한 배경 단서에 의존하지 않도록 돕습니다. 실제 카메라에서 잘 작동하는지는 별도 사진으로 확인해야 합니다.
- A1은 전체 사진에서 큐브형/정팔면체/정십이면체/정이십면체를 찾습니다. 면 모델은 큐브 크롭에서 apple/orange/banana/pineapple/plain을 찾습니다. 클래스 순서를 바꾸지 않습니다.
- train은 공부할 문제, val은 모델 선택용 문제, test는 마지막 시험입니다. 같은 장면의 크롭을 서로 다른 분할에 넣지 않습니다.

## 환경

Linux 또는 WSL, Git, Python 3.11, 인터넷 연결. CPU 첫 실습은 120장/1 epoch입니다. 정확한 모델을 완성하는 설정이 아니라 실행 연결 확인용입니다. CPU 렌더링·학습은 시간이 걸립니다.

모든 명령은 아래처럼 **같은 터미널에서 순서대로** 실행합니다. `source`가 필요한 이유는 환경 활성화와 작업 폴더 변경을 다음 단계까지 유지하기 위해서입니다.

```bash
# 이 README가 있는 lessons/01-synthetic-data 폴더에서 시작
source steps/01-environment.sh
source steps/02-assets.sh
# 이제 perception/generation 폴더
source ../../steps/03-render.sh
```

`datasets/smoke120/images/train`, `labels/train`, `_meta/train`에서 사진·라벨·JSON이 완전한 세트인지 확인합니다. 랜덤 사진 여러 장과 경계를 비교하세요. 빈 라벨 파일은 목표 물체가 없는 정상 예시일 수 있습니다. 오류/누락이 있으면 해결한 뒤 다음 단계로 넘어갑니다.

```bash
# 계속 perception/generation에서 실행
source ../../steps/04-split.sh
source ../../steps/05-export.sh
source ../../steps/06-train.sh
source ../../steps/07-evaluate.sh
# 마지막 단계는 회차 루트로 돌아옵니다
```

## 각 단계의 코드와 예상 출력

| 단계 | 핵심 소스 | 출력 |
|---|---|---|
| 재료 | `perception/generation/prepare_assets.py` | 공개 Fruits-360 일부, 해시·출처 manifest |
| 렌더 | `scripts/generate_yolo_coco_composite.py` | `datasets/smoke120` 사진·라벨·메타데이터 |
| 분리 | `scripts/split_meta_v2_dataset.py` | `split.json`, 장면별 80/10/10 분리 |
| 내보내기 | `scripts/export_meta_v2*_dataset*.py` | `smoke120_models/a1_objectseg`, `smoke120_face` |
| 학습 | `perception/training/train_segmentation.py` | 회차 루트 `runs/perception/smoke120_{a1,face}/weights/best.pt`, `recipe.json` |
| 평가 | `yolo segment val` | test split의 box/mask 점수 |

원시 렌더 폴더의 호환용 data.yaml로 바로 학습하지 않습니다. 내보낸 YAML의 클래스 순서와 train/val/test 경로를 확인합니다. 같은 run 이름은 재사용할 수 없으므로 재학습은 `--name`을 바꾸고 평가 경로도 맞춥니다.

Epoch는 학습 데이터를 한 바퀴 보는 단위, batch는 한 번에 묶는 이미지 수입니다. 새 가중치에서 1 epoch만 학습하므로 낮은 점수는 자연스럽습니다. 손실이 줄었다는 것만으로 실제 인식 성능이 좋아졌다고 판단하지 않습니다.

## 실제 사진 추론

회차 루트에 직접 찍은 `my-photo.jpg`를 놓습니다.

```bash
yolo segment predict model=runs/perception/smoke120_a1/weights/best.pt source=my-photo.jpg imgsz=640 device=cpu
```

이 명령은 형태만 찾습니다. 과일은 큐브 영역을 잘라 면 모델에 `imgsz=224`로 넣어야 합니다. OpenCV numpy 입력은 BGR 순서입니다. PIL에서 얻은 RGB 배열은 먼저 BGR로 바꿉니다.

## 입력 사진과 segmentation 예측 비교하기

학습한 면 모델과 큐브 크롭 사진을 준비한 후 회차 루트에서 실행합니다.

```bash
python scripts/predict_examples.py \
  --model runs/perception/smoke120_face/weights/best.pt \
  --source crop-apple.jpg crop-orange.jpg crop-banana.jpg \
  --output runs/prediction-examples --imgsz 224 --device cpu
```

각 사진마다 입력 사진과 예측 mask를 나란히 저장합니다. 하단 숫자는 면별 confidence입니다. `inference-examples.json`에는 가중치·입력 파일의 SHA256과 실행 설정, 예측 좌표를 기록합니다. 형태 모델이라면 `--model`을 A1 가중치로, `--imgsz`를 640으로 바꿉니다.

[MERO 강의자료의 네 가지 예시](https://mero-website-one.vercel.app/education/object-recognition/synthetic-data#evaluate)는 미리 학습된 면 가중치로 실제 카메라 크롭에 직접 추론한 결과입니다. 첫 실습의 120장·1 epoch 가중치로 만든 결과는 아닙니다.

## 확장

이 회차는 한 Blender worker만 지원합니다. `steps/full-render.sh`는 GPU/50,000장/샘플16 설정이며 장시간 작업입니다. GPU Torch 환경과 저장공간을 확인한 후 사용하세요. 출력 이름이 `public_fruits360_arena_v1`로 바뀌므로 split/export/train/evaluate 경로도 모두 맞춥니다. 전체 학습 설정과 분리·내보내기·학습·평가 명령은 [FULL_RECIPE.md](FULL_RECIPE.md)에 있습니다.

기본 레시피는 방 형태의 배경(`arena_background_ratio=1.0`)을 생성합니다. COCO 실험은 `download_coco2017_backgrounds.py --split val2017`로 준비한 JPG 폴더를 사용하고 ratio를 0.0으로 바꾸며, 새로운 seed와 출력 폴더로 별도 평가합니다.

데이터 장수는 고정된 정답이 아닙니다. 실제 그림 크기, 반사, 흐림과 클래스 분포를 확인하고, 학습에 사용하지 않은 실제 사진에서 성능을 평가합니다.

## 출처·변경·검증 범위

- [전체 학습 설정과 실행 순서](FULL_RECIPE.md)
- `UPSTREAM.json`에 원본 파일의 커밋과 SHA256을 기록했습니다.
- 교육용 런처는 이메일/감시/멀티 worker 코드를 제거하고 렌더러에 옵션을 전달합니다. 원본 렌더러·분리·내보내기·학습 계산은 그대로 유지합니다. 첫 실습은 CPU/120장/1 epoch/batch4로 축소했습니다. 보조 classifier 데이터는 만들지 않습니다.
- 코드 컴파일, 셸 문법, 인자 전달과 분리 manifest를 검증합니다. 전체 120장 렌더와 학습을 이 패키징 과정에서 새로 실행한 것은 아닙니다.
- 원본 소스 MIT. Ultralytics 및 파생 가중치 AGPL-3.0. 다운로드되는 Fruits-360 CC BY-SA 4.0 출처 파일을 데이터와 함께 유지합니다. [원본 라이선스](../../LICENSE).
