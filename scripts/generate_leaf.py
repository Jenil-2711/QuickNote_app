#!/usr/bin/env python3
"""Generates the transparent maple-leaf PNG used by the quick-capture popup.

Usage:  python3 scripts/generate_leaf.py
Needs:  pip install pillow numpy
Output: Sources/CozyQuickNoteDesk/Resources/leaf.png
"""
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

SS = 2                      # supersampling factor for smooth edges
W, H = 1000, 1000
CX, CY, R = 500, 730, 640   # leaf base point and outer radius

# (angle from vertical in degrees, radius fraction): lobes and notches
CTRL = [(0, 1.0), (11, 0.74), (22, 0.46), (36, 0.70), (50, 0.94), (64, 0.62),
        (78, 0.46), (96, 0.62), (110, 0.70), (126, 0.50), (142, 0.30), (180, 0.10)]


def radius(theta):
    t = abs(theta)
    for (a0, r0), (a1, r1) in zip(CTRL, CTRL[1:]):
        if a0 <= t <= a1:
            return r0 + (r1 - r0) * (t - a0) / (a1 - a0)
    return CTRL[-1][1]


def pt(theta, r):
    a = math.radians(theta)
    return (CX + r * R * math.sin(a), CY - r * R * math.cos(a))


def serrate(points, period=40.0, amp=15.0):
    """Offset each point along its outward normal with a sawtooth of arc length (pointed teeth)."""
    out, dist, n = [], 0.0, len(points)
    for i, (x, y) in enumerate(points):
        px, py = points[i - 1]
        nx, ny = points[(i + 1) % n]
        tx, ty = nx - px, ny - py
        ln = math.hypot(tx, ty) or 1.0
        ox, oy = ty / ln, -tx / ln
        if i:
            dist += math.hypot(x - px, y - py)
        k = min(1.0, max(0.0, (math.hypot(x - CX, y - CY) - 120) / 120))   # no teeth near the stem
        saw = ((dist / period) % 1.0) - 0.3
        out.append((x + ox * amp * saw * k, y + oy * amp * saw * k))
    return out


outline = serrate([pt(t / 4.0, radius(t / 4.0)) for t in range(-720, 721)])
mask = Image.new("L", (W * SS, H * SS), 0)
ImageDraw.Draw(mask).polygon([(x * SS, y * SS) for x, y in outline], fill=255)

# colour: green crown -> golden body -> amber base
yy, xx = np.mgrid[0:H * SS, 0:W * SS].astype(np.float32)
yy /= SS
xx /= SS
t = np.clip((yy - (CY - R)) / R, 0, 1)[..., None]
green = np.array([150, 170, 58], np.float32)
gold = np.array([235, 190, 60], np.float32)
amber = np.array([226, 160, 52], np.float32)
col = np.where(t < 0.35, green + (gold - green) * (t / 0.35), gold + (amber - gold) * ((t - 0.35) / 0.65))


def blob(cx, cy, s):
    return np.exp(-(((xx - cx) ** 2 + (yy - cy) ** 2) / (2 * s * s)))[..., None]


col = col + (green - col) * 0.75 * blob(640, 640, 70)
col = col + (green - col) * 0.55 * blob(500, 150, 90)
img = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

# veins
d = ImageDraw.Draw(img)
vein = (190, 96, 44, 255)


def line(p0, p1, w):
    d.line([(p0[0] * SS, p0[1] * SS), (p1[0] * SS, p1[1] * SS)], fill=vein, width=int(w * SS))


base = (CX, CY)
for sign in (-1, 1):
    for ang, frac, w in [(0, 0.93, 9), (50, 0.88, 8), (110, 0.64, 7)]:
        tip = pt(sign * ang, frac)
        line(base, tip, w)
        for k in (0.35, 0.55, 0.75):
            sx = base[0] + (tip[0] - base[0]) * k
            sy = base[1] + (tip[1] - base[1]) * k
            for off in (-34, 34):
                ex = sx + math.sin(math.radians(sign * ang + off)) * 80 * (1.1 - k)
                ey = sy - math.cos(math.radians(sign * ang + off)) * 80 * (1.1 - k)
                line((sx, sy), (ex, ey), 3.5)

# soft pale glow over the writing area so text stays legible on top of the veins
arr = np.array(img).astype(np.float32)
a = (np.exp(-(((xx - CX) ** 2) / (2 * 120 ** 2) + ((yy - 470) ** 2) / (2 * 120 ** 2))) * 0.92)[..., None]
arr[..., :3] = arr[..., :3] * (1 - a) + np.array([252, 236, 160], np.float32) * a
img = Image.fromarray(arr.astype(np.uint8), "RGBA")
d = ImageDraw.Draw(img)

# stem
stem_pts = [((CX - 7) * SS, (CY - 6) * SS), ((CX + 7) * SS, (CY - 6) * SS),
            ((CX + 3) * SS, 960 * SS), ((CX - 1) * SS, 960 * SS)]
d.polygon(stem_pts, fill=(176, 62, 44, 255))
stem = Image.new("L", mask.size, 0)
ImageDraw.Draw(stem).polygon(stem_pts, fill=255)
img.putalpha(Image.fromarray(np.maximum(np.array(mask), np.array(stem))))
img = img.resize((W, H), Image.LANCZOS)
img = img.crop(img.getbbox())

out = Path(__file__).resolve().parent.parent / "Sources/CozyQuickNoteDesk/Resources/leaf.png"
out.parent.mkdir(parents=True, exist_ok=True)
img.save(out)
print("saved", out, img.size)
