"""Single-worker teaching launcher; renderer options are forwarded unchanged."""
import argparse
import shutil
import subprocess
from pathlib import Path

def main():
    p = argparse.ArgumentParser(allow_abbrev=False)
    p.add_argument('--num_images', type=int, required=True)
    p.add_argument('--workers', type=int, default=1)
    p.add_argument('--worker_start_delay', type=float, default=0)
    p.add_argument('--dry-run', action='store_true')
    args, renderer_args = p.parse_known_args()
    if args.workers != 1 or args.worker_start_delay != 0 or args.num_images < 1:
        p.error('This teaching launcher supports one worker, no start delay, and a positive scene count.')
    renderer = Path(__file__).with_name('generate_yolo_coco_composite.py')
    command = [shutil.which('blenderproc') or 'blenderproc', 'run', str(renderer),
               '--start_id', '0', '--end_id', str(args.num_images - 1), *renderer_args]
    if args.dry_run:
        import json
        print(json.dumps(command))
        return
    if not shutil.which('blenderproc'):
        raise SystemExit('Activate .venv-perception first; blenderproc is missing.')
    subprocess.run(command, check=True)

if __name__ == '__main__':
    main()
