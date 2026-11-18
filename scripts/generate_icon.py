#!/usr/bin/env python3
"""Draws the app icon: the maple leaf on warm cork, in the macOS rounded-square shape.

Usage:  python3 scripts/generate_icon.py
Needs:  pip install pillow numpy
Output: assets/AppIcon-1024.png   (scripts/build_app.sh turns it into AppIcon.icns)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
from studio_lib import cork, wood  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
S, BODY = 1024, 824                  # canvas and icon body (Apple's grid leaves a transparent margin)
RADIUS = int(BODY * 0.225)
off = (S - BODY) // 2

canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))

# body shape
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([off, off, off + BODY, off + BODY], radius=RADIUS, fill=255)

# soft shadow under the icon
shadow = Image.new("RGBA", (S, S), (40, 24, 10, 0))
shadow.putalpha(mask.filter(ImageFilter.GaussianBlur(22)).point(lambda v: int(v * 0.45)))
canvas.alpha_composite(shadow, (0, 14))

# cork face with a warm glow in the middle
face = cork(BODY, BODY, seed=12).convert("RGBA")
yy, xx = np.mgrid[0:BODY, 0:BODY].astype(np.float32)
d = np.sqrt((xx - BODY / 2) ** 2 + (yy - BODY * 0.45) ** 2) / (BODY * 0.7)
glow = np.clip(1 - d, 0, 1) ** 1.6
arr = np.asarray(face).astype(np.float32)
arr[..., :3] = arr[..., :3] * (0.78 + 0.34 * glow[..., None]) + np.array([40, 24, 6], np.float32) * glow[..., None]
face = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")

# wooden frame ring
frame = wood(BODY, BODY, seed=5, base=(118, 78, 46), ring=22, dark=0.36).convert("RGBA")
inner = Image.new("L", (BODY, BODY), 0)
ImageDraw.Draw(inner).rounded_rectangle([26, 26, BODY - 26, BODY - 26], radius=RADIUS - 26, fill=255)
body = Image.composite(face, frame, inner)
edge = ImageChops.subtract(inner, inner.filter(ImageFilter.MinFilter(9)))
shade = Image.new("RGBA", (BODY, BODY), (30, 16, 6, 255))
shade.putalpha(edge.point(lambda v: int(v * 0.55)))
body.alpha_composite(shade)

# the leaf
leaf = Image.open(ROOT / "Sources/CozyQuickNoteDesk/Resources/leaf.png").convert("RGBA")
target_h = int(BODY * 0.70)
leaf = leaf.resize((int(leaf.width * target_h / leaf.height), target_h), Image.LANCZOS).rotate(-8, Image.BICUBIC, expand=True)
lx, ly = (BODY - leaf.width) // 2, (BODY - leaf.height) // 2 - 6
lshadow = Image.new("RGBA", body.size, (30, 16, 6, 0))
la = Image.new("L", body.size, 0)
la.paste(leaf.getchannel("A"), (lx + 10, ly + 18))
lshadow.putalpha(la.filter(ImageFilter.GaussianBlur(14)).point(lambda v: int(v * 0.5)))
body.alpha_composite(lshadow)
body.alpha_composite(leaf, (lx, ly))

# push-pin at the top of the leaf
px, py = BODY // 2 + 28, ly + 62
pin = Image.new("RGBA", body.size, (0, 0, 0, 0))
pd = ImageDraw.Draw(pin)
pd.ellipse([px - 34 + 8, py - 34 + 12, px + 34 + 8, py + 34 + 12], fill=(0, 0, 0, 90))
pin = pin.filter(ImageFilter.GaussianBlur(6))
pd = ImageDraw.Draw(pin)
pd.ellipse([px - 34, py - 34, px + 34, py + 34], fill=(188, 44, 40, 255))
pd.ellipse([px - 34, py - 34, px + 34, py + 34], outline=(120, 24, 24, 255), width=4)
pd.ellipse([px - 18, py - 20, px - 2, py - 6], fill=(255, 190, 180, 255))
body.alpha_composite(pin)

body.putalpha(ImageChops.multiply(body.getchannel("A"), mask.crop((off, off, off + BODY, off + BODY))))
canvas.alpha_composite(body, (off, off))

out = ROOT / "assets" / "AppIcon-1024.png"
out.parent.mkdir(exist_ok=True)
canvas.save(out)
print("saved", out)
