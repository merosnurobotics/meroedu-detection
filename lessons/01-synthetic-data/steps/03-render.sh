#!/usr/bin/env bash
# MERO 객체인식 입문: perception/generation에서 시작
# 코드 출처·사용 조건: 별도 출처 기록 및 LICENSE
# 같은 터미널에서 01부터 순서대로 source 명령으로 실행
set -e
python scripts/run_yolo_parallel.py \
  --num_images 120 --workers 1 --worker_start_delay 0 \
  --asset_dir assets/generated \
  --fruit_texture_dir datasets/fruit_textures/public_fruits360_256 \
  --background_dir datasets/backgrounds/unused \
  --arena_background_ratio 1.0 --output datasets/smoke120 \
  --width 640 --height 640 --samples 4 --cpu_threads 1 \
  --seed 31000000 --min_objects 1 --max_objects 4 \
  --scale_min 0.40 --scale_max 2.45 --negative_ratio 0.18 \
  --label_format segment --seg_contour_mode largest \
  --seg_contour_epsilon_ratio 0.01 --lighting_mode soft_overhead \
  --fruit_texture_aug strong --fruit_texture_layout mixed \
  --fruit_texture_collage_prob 0.35 --canonical_fruit_textures \
  --allow_mixed_fruit_classes_per_image --allow_multiple_fruit_textures_per_cube \
  --ideal_visibility --ideal_visibility_max_attempts 80 --meta_v2 --render_device cpu
