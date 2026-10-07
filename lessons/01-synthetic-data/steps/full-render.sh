#!/usr/bin/env bash
# perception/generation에서 실행; GPU 및 충분한 저장공간 필요
set -e
python scripts/run_yolo_parallel.py \
  --num_images 50000 --workers 1 --worker_start_delay 0 \
  --asset_dir assets/generated \
  --fruit_texture_dir datasets/fruit_textures/public_fruits360_256 \
  --background_dir datasets/backgrounds/unused \
  --arena_background_ratio 1.0 --output datasets/public_fruits360_arena_v1 \
  --width 640 --height 640 --samples 16 --cpu_threads 1 \
  --seed 31000000 --min_objects 1 --max_objects 4 \
  --scale_min 0.40 --scale_max 2.45 --negative_ratio 0.18 \
  --label_format segment --seg_contour_mode largest \
  --seg_contour_epsilon_ratio 0.01 --min_object_visible_ratio 0.10 \
  --min_fruit_visible_ratio 0.22 --min_fruit_face_pixels 1800 \
  --single_object_min_projected_area 2600 \
  --single_object_min_fruit_face_pixels 2200 --min_fruit_face_side 36 \
  --fruit_visibility_easy_weight 0.50 --fruit_visibility_mid_weight 0.45 \
  --fruit_visibility_hard_weight 0.05 --hard_min_fruit_visible_ratio 0.10 \
  --hard_min_fruit_face_pixels 900 --lighting_mode soft_overhead \
  --fruit_texture_aug strong --fruit_texture_layout mixed \
  --fruit_texture_collage_prob 0.35 --canonical_fruit_textures \
  --allow_mixed_fruit_classes_per_image --allow_multiple_fruit_textures_per_cube \
  --ideal_visibility --ideal_visibility_max_attempts 80 --meta_v2 --render_device gpu
