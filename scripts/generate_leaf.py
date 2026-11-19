#!/usr/bin/env python3
"""Draws the quick-capture leaf: a translucent, backlit green leaf with a fine vein network.

The artwork is semi-transparent on purpose. Whatever is behind the leaf (the window you were just
using) shows through it, like light passing through a real leaf, while the veins stay solid.
A pale, calmer patch in the middle is where you write.

Usage:  python3 scripts/generate_leaf.py
Needs:  pip install pillow numpy
Output: Sources/CozyQuickNoteDesk/Resources/leaf.png
        Sources/CozyQuickNoteDesk/Views/Shared/LeafLayout.swift   (where the text goes on the leaf)
"""
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SS = 2                                   # supersampling for smooth edges
W, H = 1000, 1180                        # canvas before supersampling
BASE_Y, LENGTH, HALF_W = 1075, 985, 405
CX0 = 500


# ---------------------------------------------------------------- leaf geometry
def _bw(t, a=0.72, b=1.22):
    """Half-width profile: rounded base, widest about 37% up, long pointed tip."""
    t = min(max(t, 0.0), 1.0)
    peak = (a / (a + b)) ** a * (b / (a + b)) ** b
    return (t ** a) * ((1 - t) ** b) / peak


def cx(t):
    return CX0 + 34 * math.sin(math.pi * t)          # the midrib bends a little, like the real leaf


def cy(t):
    return BASE_Y - t * LENGTH


def half_width(t):
    return HALF_W * _bw(t)


def side_points(sign, n=420):
    return [(cx(i / n) + sign * half_width(i / n), cy(i / n)) for i in range(n + 1)]


def serrate(points, period, amp, sign):
    """Sawtooth teeth along the margin (normal offset by arc length), fading out at base and tip."""
    out, dist, n = [], 0.0, len(points)
    for i, (x, y) in enumerate(points):
        if i:
            dist += math.hypot(x - points[i - 1][0], y - points[i - 1][1])
        px, py = points[max(i - 1, 0)]
        nx, ny = points[min(i + 1, n - 1)]
        tx, ty = nx - px, ny - py
        ln = math.hypot(tx, ty) or 1.0
        ox, oy = sign * ty / ln, -sign * tx / ln
        t = i / (n - 1)
        k = min(1.0, t / 0.10) * min(1.0, (1 - t) / 0.06)
        saw = ((dist / period) % 1.0) - 0.35
        out.append((x + ox * amp * saw * k, y + oy * amp * saw * k))
    return out


right = serrate(serrate(side_points(1), 40, 15, 1), 17, 5, 1)
left = serrate(serrate(side_points(-1), 40, 15, -1), 17, 5, -1)
outline = right + left[::-1]

mask = Image.new("L", (W * SS, H * SS), 0)
ImageDraw.Draw(mask).polygon([(x * SS, y * SS) for x, y in outline], fill=255)
m = np.asarray(mask).astype(np.float32) / 255.0
mask_blur = np.asarray(mask.filter(ImageFilter.GaussianBlur(34 * SS))).astype(np.float32) / 255.0


# ---------------------------------------------------------------- veins
def bezier(p0, p1, p2, n=48):
    return [((1 - u) ** 2 * p0[0] + 2 * (1 - u) * u * p1[0] + u * u * p2[0],
             (1 - u) ** 2 * p0[1] + 2 * (1 - u) * u * p1[1] + u * u * p2[1]) for u in (i / n for i in range(n + 1))]


def taper(draw, pts, w0, w1):
    n = len(pts) - 1
    for i in range(n):
        w = w0 + (w1 - w0) * i / n
        draw.line([(pts[i][0] * SS, pts[i][1] * SS), (pts[i + 1][0] * SS, pts[i + 1][1] * SS)],
                  fill=255, width=max(1, int(w * SS)))


veins = Image.new("L", mask.size, 0)
vd = ImageDraw.Draw(veins)
taper(vd, [(cx(i / 200), cy(i / 200)) for i in range(0, 196)], 13, 2.5)          # midrib

for sign in (-1, 1):
    for i in range(11):
        t0 = 0.08 + i * 0.078 + (0.035 if sign > 0 else 0.0)
        t1 = min(0.97, t0 + 0.17 + 0.05 * (1 - i / 11))
        start = (cx(t0), cy(t0))
        end = (cx(t1) + sign * (half_width(t1) - 16), cy(t1))
        ctrl = (start[0] + sign * abs(end[0] - start[0]) * 0.92, start[1] + (end[1] - start[1]) * 0.30)
        pts = bezier(start, ctrl, end)
        taper(vd, pts, 7.0 - i * 0.2, 1.6)
        # small branches from each secondary vein toward the margin
        for k in (0.35, 0.6, 0.82):
            bx, by = pts[int(k * 48)]
            ex, ey = bx + sign * 46, by - 38
            taper(vd, bezier((bx, by), (bx + sign * 30, by - 12), (ex, ey), 14), 2.6, 1.0)

veins_main = np.asarray(veins.filter(ImageFilter.GaussianBlur(0.6 * SS))).astype(np.float32) / 255.0


def worley_edges(w, h, cell, seed):
    """Cell borders of a Worley (cellular) noise: looks like the fine net of a real leaf."""
    rs = np.random.RandomState(seed)
    gx, gy = w // cell + 4, h // cell + 4
    px = (np.arange(gx)[None, :] + rs.rand(gy, gx)) * cell
    py = (np.arange(gy)[:, None] + rs.rand(gy, gx)) * cell
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    ci = (xx // cell).astype(np.int32) + 1
    cj = (yy // cell).astype(np.int32) + 1
    f1 = np.full((h, w), 1e9, np.float32)
    f2 = np.full((h, w), 1e9, np.float32)
    for dj in (-1, 0, 1):
        for di in (-1, 0, 1):
            nx = px[cj + dj, ci + di].astype(np.float32)
            ny = py[cj + dj, ci + di].astype(np.float32)
            d = np.sqrt((xx - nx) ** 2 + (yy - ny) ** 2)
            f2 = np.minimum(f2, np.maximum(f1, d))
            f1 = np.minimum(f1, d)
    return np.clip(1 - (f2 - f1) / (cell * 0.16), 0, 1)


net_coarse = worley_edges(W * SS, H * SS, 21 * SS, 3)
net_fine = worley_edges(W * SS, H * SS, 10 * SS, 8)
net = np.clip(net_coarse * 0.85 + net_fine * 0.40, 0, 1)

# ---------------------------------------------------------------- colour and light
yy, xx = np.mgrid[0:H * SS, 0:W * SS].astype(np.float32)
fx, fy = xx / (W * SS), yy / (H * SS)


def blob(x, y, rx, ry):
    return np.exp(-(((fx - x) / rx) ** 2 + ((fy - y) / ry) ** 2))


tpos = np.clip((BASE_Y - yy / SS) / LENGTH, 0, 1)[..., None]
dark = np.array([58, 128, 44], np.float32)
mid = np.array([124, 186, 66], np.float32)
light = np.array([176, 214, 104], np.float32)
cell_col = np.where(tpos < 0.5, dark + (mid - dark) * (tpos / 0.5), mid + (light - mid) * ((tpos - 0.5) / 0.5))

rs = np.random.RandomState(4)
patch = Image.fromarray((rs.rand(H // 40, W // 40) * 255).astype(np.uint8)).resize((W * SS, H * SS), Image.BICUBIC)
cell_col = cell_col * (0.90 + 0.18 * (np.asarray(patch).astype(np.float32) / 255.0))[..., None]

flare = blob(0.64, 0.52, 0.17, 0.12)[..., None]                       # sunlight coming through
cell_col = cell_col * (1 - 0.55 * flare) + np.array([250, 244, 186], np.float32) * 0.55 * flare

# the calm, pale patch where the text goes
zone = blob(0.50, 0.57, 0.24, 0.155)
zone = np.clip(zone * 1.25, 0, 1) ** 0.8
v = np.clip(np.maximum(veins_main, net * 0.62), 0, 1) * (1 - 0.82 * zone)
cell_col = cell_col * (1 - 0.74 * zone[..., None]) + np.array([244, 250, 216], np.float32) * 0.74 * zone[..., None]

vein_col = np.array([34, 92, 34], np.float32)
color = cell_col * (1 - v[..., None]) + vein_col * v[..., None]
rim = np.clip(mask_blur / 0.80, 0, 1)
color *= (0.66 + 0.34 * rim)[..., None]

alpha = 0.56 + 0.34 * v + 0.14 * (1 - rim) + 0.38 * zone
alpha = np.maximum(alpha, 0.96 * zone ** 0.7)       # the writing patch stays readable over busy windows
alpha = np.clip(alpha, 0, 0.97) * m

img = Image.fromarray(np.dstack([np.clip(color, 0, 255), alpha * 255]).astype(np.uint8), "RGBA")

# stem
stem = Image.new("RGBA", img.size, (0, 0, 0, 0))
sd = ImageDraw.Draw(stem)
sd.polygon([((CX0 - 9) * SS, (BASE_Y - 10) * SS), ((CX0 + 9) * SS, (BASE_Y - 10) * SS),
            ((CX0 + 5) * SS, (BASE_Y + 78) * SS), ((CX0 - 3) * SS, (BASE_Y + 78) * SS)], fill=(70, 96, 40, 245))
img.alpha_composite(stem)

img = img.resize((W, H), Image.LANCZOS)
box = img.getbbox()
pad = 14
img = img.crop((box[0] - pad, box[1] - pad, box[2] + pad, box[3] + pad))

out = ROOT / "Sources/CozyQuickNoteDesk/Resources/leaf.png"
out.parent.mkdir(parents=True, exist_ok=True)
img.save(out)

# where the writing goes, as fractions of the final image
cw, ch = img.size
zx0, zx1 = (0.50 - 0.215) * W, (0.50 + 0.215) * W
zy0, zy1 = (0.57 - 0.135) * H, (0.57 + 0.135) * H
tx, ty = (zx0 - (box[0] - pad)) / cw, (zy0 - (box[1] - pad)) / ch
tw, th = (zx1 - zx0) / cw, (zy1 - zy0) / ch
layout = ROOT / "Sources/CozyQuickNoteDesk/Views/Shared/LeafLayout.swift"
layout.write_text(f"""import CoreGraphics

/// Where text is written on leaf.png, as fractions of the image, and its shape.
/// Generated by scripts/generate_leaf.py.
enum LeafLayout {{
    static let writingArea = CGRect(x: {tx:.3f}, y: {ty:.3f}, width: {tw:.3f}, height: {th:.3f})
    /// Width divided by height of leaf.png.
    static let aspect: Double = {cw / ch:.4f}
}}
""")
print("saved", out, img.size)
print(layout.read_text())
