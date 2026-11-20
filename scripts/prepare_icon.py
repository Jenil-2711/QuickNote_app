#!/usr/bin/env python3
"""Turns a picture of an app icon (a rounded square on a plain background) into the app icon.

It finds the rounded square, throws away the background, shadow and any corner watermark,
places the square on Apple's icon grid (an 824 px body inside a 1024 px canvas) and adds a soft shadow.

Usage:  python3 scripts/prepare_icon.py path/to/icon-picture.png
Needs:  pip install pillow numpy scipy
Output: assets/AppIcon-1024.png        (scripts/build_app.sh turns it into AppIcon.icns)
        assets/social-preview.png      (1280x640 card for GitHub: Settings > General > Social preview)

The shipped icon was created with an AI image tool (Gemini) from the author's idea and prepared with this script.
The earlier cork-and-leaf icon is still drawn by scripts/generate_icon.py.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from scipy import ndimage

ROOT = Path(__file__).resolve().parent.parent
src = Path(sys.argv[1])

img = Image.open(src).convert("RGB")
rgb = np.asarray(img).astype(np.float32)
lum = rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114

# 1. the icon is the biggest bright blob; the dark background, its shadow and a small corner watermark are not
bright = lum > 150
labels, count = ndimage.label(bright)
sizes = ndimage.sum(bright, labels, range(1, count + 1))
body = labels == (int(np.argmax(sizes)) + 1)
body = ndimage.binary_fill_holes(body)                      # the pen and leaf are darker than the paper: keep them

# 2. soft, fringe-free edge
body = ndimage.binary_erosion(body, iterations=2)
alpha = Image.fromarray((body * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.6))

ys, xs = np.nonzero(body)
box = (xs.min() - 4, ys.min() - 4, xs.max() + 5, ys.max() + 5)
face = img.crop(box).convert("RGBA")
face.putalpha(alpha.crop(box))
side = max(face.size)
square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
square.alpha_composite(face, ((side - face.width) // 2, (side - face.height) // 2))

# 3. Apple's grid: 824 px body centred in a 1024 px canvas, with a soft shadow
S, BODY = 1024, 824
off = (S - BODY) // 2
body_img = square.resize((BODY, BODY), Image.LANCZOS)
canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
shadow = Image.new("RGBA", (S, S), (40, 24, 10, 0))
sa = Image.new("L", (S, S), 0)
sa.paste(body_img.getchannel("A"), (off, off))
shadow.putalpha(sa.filter(ImageFilter.GaussianBlur(22)).point(lambda v: int(v * 0.40)))
canvas.alpha_composite(shadow, (0, 14))
canvas.alpha_composite(body_img, (off, off))
out = ROOT / "assets" / "AppIcon-1024.png"
out.parent.mkdir(exist_ok=True)
canvas.save(out)
print("saved", out)

# 4. GitHub social preview card (upload it by hand in the repository settings)
card = Image.new("RGB", (1280, 640), (243, 232, 211))
rs = np.random.RandomState(3)
grain = rs.normal(0, 2.2, (640, 1280, 1))
card = Image.fromarray(np.clip(np.asarray(card).astype(np.float32) + grain, 0, 255).astype(np.uint8))
icon = canvas.resize((420, 420), Image.LANCZOS)
card = card.convert("RGBA")
card.alpha_composite(icon, (110, 110))


def font(size, bold=False):
    for name in ("DejaVuSerif-Bold.ttf" if bold else "DejaVuSerif.ttf", "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"):
        for folder in ("/usr/share/fonts/truetype/dejavu", "/System/Library/Fonts/Supplemental", "/Library/Fonts"):
            p = Path(folder) / name
            if p.exists():
                return ImageFont.truetype(str(p), size)
    return ImageFont.load_default()


d = ImageDraw.Draw(card)
d.text((590, 205), "Cozy Quick-Note", font=font(64, True), fill=(78, 52, 34))
d.text((590, 283), "Desk", font=font(64, True), fill=(78, 52, 34))
d.text((592, 385), "Press a shortcut, write on a leaf,", font=font(30), fill=(120, 92, 70))
d.text((592, 429), "pin it to your cork board.", font=font(30), fill=(120, 92, 70))
d.text((592, 500), "A native macOS app", font=font(24), fill=(150, 124, 98))
card.convert("RGB").save(ROOT / "assets" / "social-preview.png")
print("saved", ROOT / "assets" / "social-preview.png")
