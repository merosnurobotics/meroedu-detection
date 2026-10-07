# 패키징 검증 · 2026-10-08

- 포함 Python 소스 구문 검사와 Bash 문법 검사 통과.
- 교육용 단일 worker 런처의 dry-run으로 0–119 장면 번호와 seed/meta_v2 옵션 전달 확인.
- 120개 fixture 메타데이터에서 split 스크립트 실제 실행: train 96/val 12/test 12, 동일 seed 재실행 시 동일 manifest.
- 정답 파일을 하나 제거한 fixture의 분리 실행이 오류로 중단되는 것 확인.
- fixture는 인자와 분리 동작 검증용이며 실제 렌더 이미지나 학습 성능 결과가 아님.
- 전체 120장 Blender 렌더, 새 가상환경 설치와 YOLO 학습은 이번 패키징에서 실행하지 않음.
- datasets/runs/가상환경/가중치는 커밋하지 않음.
