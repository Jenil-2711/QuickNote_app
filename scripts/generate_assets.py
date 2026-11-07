#!/usr/bin/env python3
"""Renders every visual asset of the virtual study room from scratch (no photos, no downloads).

Usage:  python3 scripts/generate_assets.py
Needs:  pip install pillow numpy
Output: Sources/CozyQuickNoteDesk/Resources/room.jpg      the room (shelves, plants, desk, cork board)
        Sources/CozyQuickNoteDesk/Resources/wood.jpg      wood texture for bars and frames in the UI
        Sources/CozyQuickNoteDesk/Resources/paper.jpg     paper texture for cards and sticky notes
        Sources/CozyQuickNoteDesk/Views/Room/RoomLayout.swift       where the cork board is in the room image
        Sources/CozyQuickNoteDesk/Views/Room/FairyLightPoints.swift where the bulbs are (for the twinkle)
"""
import math
import random
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
from studio_lib import *  # noqa: E402,F401,F403

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "Sources/CozyQuickNoteDesk/Resources"
ROOM_DIR = ROOT / "Sources/CozyQuickNoteDesk/Views/Room"
RES.mkdir(parents=True, exist_ok=True)
ROOM_DIR.mkdir(parents=True, exist_ok=True)

W, H = 2400, 1500
rnd = random.Random(11)

# cork area (inside the frame), in image pixels
CORK = (420, 330, 1980, 1110)
FRAME = 30
DESK_Y = 1165

C = plaster(W, H).convert("RGBA")

# soft warm light from the middle top
glow(C, 1200, 280, 1100, (60, 44, 20), 0.9)

# ------------------------------------------------------------ desk surface
desk = wood(W, H - DESK_Y, seed=4, base=(168, 118, 74), plank=118, ring=40).convert("RGBA")
C.alpha_composite(desk, (0, DESK_Y))
# contact shadow where the wall meets the desk, and a lit front
ao = gradient_rect(W, 46, (0, 0, 0), (0, 0, 0)).convert("RGBA")
a = np.linspace(150, 0, 46, dtype=np.float32)[:, None] * np.ones((1, W), np.float32)
ao.putalpha(Image.fromarray(a.astype(np.uint8)))
C.alpha_composite(ao, (0, DESK_Y))
d = ImageDraw.Draw(C)
d.line([(0, DESK_Y), (W, DESK_Y)], fill=(70, 44, 24, 255), width=3)

# ------------------------------------------------------------ ivy behind everything
for x, ln in [(40, 640), (140, 420), (250, 760), (350, 380), (2060, 420), (2160, 700),
              (2270, 460), (2350, 800), (30, 300), (200, 560), (300, 250), (2110, 330), (2320, 380),
              (470, 230), (610, 190), (760, 250), (900, 150), (1050, 230), (1200, 170), (1350, 240),
              (1500, 170), (1650, 230), (1800, 210), (1930, 250)]:
    ivy_strand(C, x, -20, ln, rnd, size=52, sway=24)

# ------------------------------------------------------------ cork board with wooden frame
bx0, by0, bx1, by1 = CORK
frame_img = wood(bx1 - bx0 + FRAME * 2, by1 - by0 + FRAME * 2, seed=8, base=(150, 104, 64), ring=18).convert("RGBA")
put(C, frame_img, (bx0 - FRAME, by0 - FRAME), shadow=(10, 18, 24, 0.55))
cork_img = cork(bx1 - bx0, by1 - by0).convert("RGBA")
# inner shadow from the frame (light comes from upper left)
ia = np.zeros((by1 - by0, bx1 - bx0), np.float32)
yy, xx = np.mgrid[0:ia.shape[0], 0:ia.shape[1]].astype(np.float32)
ia += np.clip(1 - xx / 26, 0, 1) * 0.55 + np.clip(1 - yy / 30, 0, 1) * 0.65
ia += np.clip(1 - (ia.shape[1] - xx) / 14, 0, 1) * 0.18 + np.clip(1 - (ia.shape[0] - yy) / 14, 0, 1) * 0.15
inner = Image.new("RGBA", cork_img.size, (30, 16, 6, 0))
inner.putalpha(Image.fromarray((np.clip(ia, 0, 1) * 170).astype(np.uint8)))
cork_img.alpha_composite(inner)
C.alpha_composite(cork_img, (bx0, by0))
d = ImageDraw.Draw(C)
d.rectangle((bx0 - FRAME, by0 - FRAME, bx1 + FRAME, by1 + FRAME), outline=(52, 32, 16, 255), width=3)
d.rectangle((bx0 - 1, by0 - 1, bx1 + 1, by1 + 1), outline=(60, 36, 18, 255), width=2)


# ------------------------------------------------------------ shelves
def shelf(x0, x1, y):
    w = x1 - x0
    top = wood(w, 16, seed=rnd.randint(0, 99), base=(206, 160, 110), ring=7).convert("RGBA")
    front = wood(w, 26, seed=rnd.randint(0, 99), base=(176, 128, 82), ring=9).convert("RGBA")
    lay = rgba(w, 42)
    lay.alpha_composite(top, (0, 0))
    lay.alpha_composite(front, (0, 16))
    ImageDraw.Draw(lay).line([(0, 16), (w, 16)], fill=(70, 44, 24, 255), width=2)
    put(C, lay, (x0, y - 16), shadow=(0, 26, 22, 0.5))


shelf(24, 392, 470)
shelf(24, 392, 800)
shelf(2008, 2376, 440)
shelf(2008, 2376, 780)

# left shelf 1: trailing pothos + stacked books
put(C, pot(112, 92, (236, 231, 220)), (70, 470 - 92 - 8), shadow=(5, 6, 8, 0.5))
cluster(C, 126, 392, 26, 70, 62, "pothos", rnd, tones=("deep", "mid", "mid", "fresh"))
ivy_strand(C, 90, 440, 150, rnd, size=44, sway=10)
y = flat_books(C, 250, 470 - 6, rnd, n=3, w=118)
put(C, pot(54, 46, (206, 150, 120)), (292, y - 52), shadow=(3, 4, 5, 0.5))
cluster(C, 319, y - 40, 9, 60, 26, "round", rnd, tones=("mid", "fresh"))

# left shelf 2: framed print + succulent
fr = frame(150, 196, rnd)
put(C, fr.rotate(2, Image.BICUBIC, expand=True), (46, 800 - 196 - 4), shadow=(6, 8, 10, 0.5))
put(C, pot(72, 60, (232, 226, 214)), (232, 800 - 60 - 8), shadow=(4, 5, 6, 0.5))
cluster(C, 268, 800 - 62, 12, 70, 32, "round", rnd, tones=("mid", "fresh"))
put(C, pot(54, 46, (190, 120, 92)), (320, 800 - 46 - 8), shadow=(3, 4, 5, 0.5))
cluster(C, 347, 800 - 48, 8, 60, 22, "narrow", rnd, tones=("mid", "fresh"))

# right shelf 1: row of books + small plant
book_row(C, 2030, 440 - 4, 11, rnd, max_w=230, hmin=130, hmax=190)
put(C, pot(78, 66, (236, 231, 220)), (2292, 440 - 66 - 8), shadow=(4, 5, 7, 0.5))
cluster(C, 2331, 440 - 66, 14, 70, 36, "pothos", rnd)

# right shelf 2: glowing lantern + framed print
lantern = rgba(90, 130)
ld = ImageDraw.Draw(lantern)
ld.rectangle((12, 20, 78, 122), fill=(255, 224, 150, 235), outline=(64, 46, 30, 255), width=4)
ld.polygon([(8, 22), (82, 22), (62, 2), (28, 2)], fill=(64, 46, 30, 255))
ld.line([(45, 20), (45, 122)], fill=(64, 46, 30, 255), width=2)
ld.rectangle((10, 120, 80, 128), fill=(64, 46, 30, 255))
put(C, lantern, (2040, 780 - 130 - 6), shadow=(4, 5, 6, 0.5))
glow(C, 2085, 780 - 80, 150, (255, 190, 90), 0.55)
fr2 = frame(138, 176, rnd)
put(C, fr2.rotate(-2, Image.BICUBIC, expand=True), (2180, 780 - 176 - 4), shadow=(6, 8, 10, 0.5))
put(C, pot(54, 46, (206, 150, 120)), (2330, 780 - 46 - 8), shadow=(3, 4, 5, 0.5))
cluster(C, 2357, 780 - 48, 8, 60, 22, "round", rnd, tones=("mid", "fresh"))

# ------------------------------------------------------------ desk props
# lamp (left)
lamp = rgba(560, 460)
ld = ImageDraw.Draw(lamp)
base_pt, joint, pivot = (110, 400), (215, 170), (350, 90)
ld.ellipse((20, 372, 200, 424), fill=(220, 216, 206, 255), outline=(120, 114, 104, 255), width=3)
ld.ellipse((50, 360, 170, 396), fill=(238, 234, 224, 255))
for p0, p1 in ((base_pt, joint), (joint, pivot)):
    ld.line([p0, p1], fill=(120, 114, 104, 255), width=16)
    ld.line([p0, p1], fill=(236, 232, 222, 255), width=11)
    ld.line([(p0[0] - 3, p0[1]), (p1[0] - 3, p1[1])], fill=(255, 255, 250, 255), width=3)
ld.ellipse((joint[0] - 12, joint[1] - 12, joint[0] + 12, joint[1] + 12), fill=(150, 144, 134, 255))
head = rgba(190, 170)
hd = ImageDraw.Draw(head)
shade_poly = [(70, 14), (120, 14), (176, 134), (14, 134)]
cone = gradient_rect(190, 170, (252, 250, 244), (150, 146, 136)).convert("RGBA")
cm = Image.new("L", (190, 170), 0)
ImageDraw.Draw(cm).polygon(shade_poly, fill=255)
cone.putalpha(cm)
head.alpha_composite(cone)
hd.ellipse((14, 120, 176, 150), fill=(255, 232, 168, 255), outline=(170, 132, 70, 255))
hd.ellipse((38, 126, 152, 146), fill=(255, 246, 214, 255))
hd.line([(70, 14), (14, 134)], fill=(120, 114, 104, 255), width=2)
hd.line([(120, 14), (176, 134)], fill=(120, 114, 104, 255), width=2)
hd.ellipse((78, 4, 112, 22), fill=(176, 170, 160, 255))
head = head.rotate(32, Image.BICUBIC, expand=True)
lamp.alpha_composite(head, (pivot[0] - 75, pivot[1] - 40))
put(C, lamp, (90, 1330 - 400 - 40 + 40 - 0), shadow=(10, 14, 14, 0.5))
lamp_head_c = (90 + pivot[0] + 20, 1330 - 400 + pivot[1] + 60)
glow(C, lamp_head_c[0] + 70, lamp_head_c[1] + 90, 520, (255, 196, 110), 0.6)

# pencil cup + pencils
cx, cy = 700, 1300
pens = [((220, 90, 80), -14), ((236, 196, 70), -4), ((90, 140, 110), 8), ((70, 90, 150), 16), ((240, 240, 230), -22),
        ((196, 120, 150), 3)]
pl = rgba(260, 260)
pd = ImageDraw.Draw(pl)
for col, ang in pens:
    a = math.radians(ang - 90)
    L = rnd.randint(96, 132)
    x0, y0 = 130, 200
    x1, y1 = x0 + math.cos(a) * L, y0 + math.sin(a) * L
    pd.line([(x0, y0), (x1, y1)], fill=col + (255,), width=8)
    pd.line([(x0 - 2, y0), (x1 - 2, y1)], fill=tuple(min(255, c + 40) for c in col) + (255,), width=2)
    tx, ty = x1 + math.cos(a) * 14, y1 + math.sin(a) * 14
    pd.polygon([(x1 + math.cos(a + 1.57) * 4, y1 + math.sin(a + 1.57) * 4),
                (x1 + math.cos(a - 1.57) * 4, y1 + math.sin(a - 1.57) * 4), (tx, ty)], fill=(222, 186, 140, 255))
put(C, pl, (cx - 130, cy - 200 + 12), shadow=(4, 6, 6, 0.4))
put(C, pot(100, 124, (226, 218, 202), taper=0.94), (cx - 50, cy - 40), shadow=(8, 10, 12, 0.5))

# mug
mug = rgba(150, 110)
md = ImageDraw.Draw(mug)
md.ellipse((98, 18, 142, 78), outline=(206, 150, 140, 255), width=11)
mug.alpha_composite(pot(96, 88, (218, 168, 158), taper=0.97), (0, 10))
put(C, mug, (830, 1300 - 78), shadow=(8, 10, 10, 0.5))

# books + small succulent on the right of the desk
y = flat_books(C, 1700, 1325, rnd, n=3, w=210)
put(C, pot(70, 58, (232, 226, 214)), (1745, y - 60), shadow=(4, 5, 6, 0.5))
cluster(C, 1780, y - 52, 12, 70, 34, "round", rnd, tones=("mid", "fresh"))

# notebook + pen in front
nb = rgba(560, 170)
nd = ImageDraw.Draw(nb)
nd.rounded_rectangle((0, 0, 559, 169), radius=10, fill=(206, 164, 154, 255), outline=(120, 88, 80, 255), width=3)
nd.rectangle((24, 22, 538, 146), fill=(232, 192, 182, 255), outline=(180, 140, 130, 255))
for i in range(11):
    nd.ellipse((8, 14 + i * 14, 24, 28 + i * 14), fill=(70, 62, 56, 255))
for i in range(4):
    nd.line([(70, 52 + i * 26), (500, 52 + i * 26)], fill=(206, 168, 158, 255), width=2)
nb = nb.rotate(2.0, Image.BICUBIC, expand=True)
put(C, nb, (1030, 1318), shadow=(8, 12, 14, 0.5))
pen = rgba(260, 24)
pnd = ImageDraw.Draw(pen)
pnd.rounded_rectangle((0, 4, 250, 18), radius=6, fill=(46, 46, 52, 255))
pnd.line([(10, 8), (240, 8)], fill=(120, 120, 130, 255), width=2)
pnd.polygon([(250, 6), (260, 11), (250, 16)], fill=(200, 200, 205, 255))
put(C, pen.rotate(8, Image.BICUBIC, expand=True), (1620, 1380), shadow=(5, 7, 6, 0.5))

# tall plant (right)
put(C, pot(160, 130, (186, 116, 84), taper=0.80), (2160, 1250), shadow=(10, 12, 14, 0.5))
for (px, py, sz, n) in [(2238, 1262, 84, 26), (2225, 1120, 82, 22), (2255, 990, 76, 18), (2236, 880, 68, 14)]:
    cluster(C, px, py, n, 58, sz, "narrow", rnd, tones=("deep", "mid", "mid", "fresh"))

# ------------------------------------------------------------ fairy lights
bulbs = []
for p0, p1, sag in [((-40, 52), (600, 70), 50), ((600, 70), (1200, 58), 66), ((1200, 58), (1800, 70), 66),
                    ((1800, 70), (2440, 50), 50)]:
    bulbs += fairy_string(C, p0, p1, sag, rnd)
for x0v, x1v, yend in [(110, 120, 880), (290, 280, 760), (2090, 2100, 820), (2270, 2262, 900)]:
    bulbs += fairy_string(C, (x0v, 60), (x1v, yend), 8, rnd, spacing=44)
for (x, y) in bulbs:
    glow(C, x, y, 44, (255, 206, 120), 0.75)
d = ImageDraw.Draw(C)
for (x, y) in bulbs:
    d.ellipse((x - 5, y - 5, x + 5, y + 7), fill=(255, 246, 214, 255))

# ------------------------------------------------------------ grading
rgb = np.asarray(C.convert("RGB")).astype(np.float32)
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
dd = np.sqrt(((xx - W / 2) / (W / 2)) ** 2 + ((yy - H * 0.46) / (H / 2)) ** 2)
vig = 1.0 - 0.36 * np.clip(dd - 0.35, 0, 1.2) ** 1.5
rgb *= vig[..., None]
rgb *= np.array([1.03, 0.995, 0.93], np.float32)                      # warm grade
lum = rgb.mean(-1)
bright = np.clip(lum - 215, 0, 60) / 60.0
bloom = np.asarray(Image.fromarray((bright * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(26))).astype(np.float32) / 255
rgb += bloom[..., None] * np.array([70, 52, 24], np.float32)
rgb += np.random.RandomState(5).normal(0, 2.4, (H, W, 1))              # film grain
room = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").filter(ImageFilter.GaussianBlur(0.6))
room.save(RES / "room.jpg", quality=90)

# ------------------------------------------------------------ UI textures
wood(1400, 260, seed=31, base=(104, 68, 40), ring=22, dark=0.38).save(RES / "wood.jpg", quality=90)
paper_tile(512).save(RES / "paper.jpg", quality=92)

# ------------------------------------------------------------ Swift constants
(x0, y0, x1, y1) = CORK
(ROOM_DIR / "RoomLayout.swift").write_text(f"""import CoreGraphics

/// Where things are inside room.jpg. Generated by scripts/generate_assets.py.
enum RoomLayout {{
    /// Size of room.jpg in pixels.
    static let imageSize = CGSize(width: {W}, height: {H})

    /// The cork board's writing surface, as fractions (0...1) of the room image.
    static let board = CGRect(x: {x0 / W:.5f}, y: {y0 / H:.5f}, width: {(x1 - x0) / W:.5f}, height: {(y1 - y0) / H:.5f})

    /// Width divided by height of the cork surface in pixels.
    static let boardAspect: Double = {(x1 - x0) / (y1 - y0):.5f}
}}
""")
pts = [(x / W, y / H) for x, y in bulbs if 0.005 < x / W < 0.995]
rows = ",\n".join(f"        ({px:.4f}, {py:.4f})" for px, py in pts)
(ROOM_DIR / "FairyLightPoints.swift").write_text(f"""/// Positions of the fairy-light bulbs in room.jpg, as fractions (0...1) of the image.
/// Generated by scripts/generate_assets.py.
enum FairyLightPoints {{
    static let all: [(x: Double, y: Double)] = [
{rows}
    ]
}}
""")
print("done", room.size, len(pts), "bulbs")
