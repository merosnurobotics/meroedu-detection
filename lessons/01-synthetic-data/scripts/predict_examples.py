"""Save input/prediction figures and a record of a trained model's inference."""
import argparse
import hashlib
import json
from pathlib import Path

import cv2
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from ultralytics import YOLO, __version__


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--source", type=Path, nargs="+", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--imgsz", type=int, default=224)
    parser.add_argument("--device", default="cpu")
    parser.add_argument("--conf", type=float, default=0.25)
    args = parser.parse_args()
    model = YOLO(str(args.model))
    args.output.mkdir(parents=True, exist_ok=True)
    records = []
    for source in args.source:
        result = model.predict(str(source), imgsz=args.imgsz, device=args.device,
                               conf=args.conf, verbose=False)[0]
        predictions = result.summary()
        image = args.output / f"prediction-{source.stem}.jpg"
        fig, axes = plt.subplots(1, 2, figsize=(8, 5), dpi=120)
        axes[0].imshow(cv2.cvtColor(result.orig_img, cv2.COLOR_BGR2RGB))
        axes[0].set_title("Input photo", fontsize=13)
        overlay = result.plot(labels=False, boxes=False)
        axes[1].imshow(cv2.cvtColor(overlay, cv2.COLOR_BGR2RGB))
        axes[1].set_title("Predicted segmentation", fontsize=13)
        for axis in axes:
            axis.axis("off")
        scores = " / ".join(f"{p['name']} {p['confidence']:.3f}" for p in predictions)
        fig.text(0.5, 0.055, scores or "No detections above threshold", ha="center", fontsize=10)
        fig.subplots_adjust(left=.025, right=.975, top=.92, bottom=.14, wspace=.08)
        fig.savefig(image, facecolor="white")
        plt.close(fig)
        records.append({"image": image.name, "source": source.name,
                        "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                        "size": [960, 600], "predictions": predictions})
        print(source.name, scores, flush=True)
    record = {"weights": args.model.name,
              "weights_sha256": hashlib.sha256(args.model.read_bytes()).hexdigest(),
              "ultralytics": __version__, "imgsz": args.imgsz,
              "device": args.device, "conf": args.conf, "examples": records}
    (args.output / "inference-examples.json").write_text(json.dumps(record, indent=2) + "\n")


if __name__ == "__main__":
    main()
