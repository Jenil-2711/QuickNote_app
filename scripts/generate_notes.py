#!/usr/bin/env python3
"""Draws the 8 stationery-style sticky-note designs (paper layer + sticker layer for each).

Usage:  python3 scripts/generate_notes.py
Needs:  pip install pillow numpy
Output: Sources/CozyQuickNoteDesk/Resources/note_<design>_paper.png   near-white paper (tinted by the note colour in the app)
        Sources/CozyQuickNoteDesk/Resources/note_<design>_deco.png    tape, bows, stickers (never tinted)
        Sources/CozyQuickNoteDesk/Models/NoteDesignLayout.swift       where text may be written on each design
"""
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "Sources/CozyQuickNoteDesk/Resources"
MODELS = ROOT / "Sources/CozyQuickNoteDesk/Models"
N, SS = 640, 2
W = N * SS

PAPER = (252, 248, 240)
INK = (126, 102, 86)
LINE = (168, 146, 128)
BROWN = (96, 62, 46)
DARK = (66, 42, 32)


def s(v):
    return v * SS


def layer():
    return Image.new("RGBA", (W, W), (0, 0, 0, 0))


def mask_layer():
    return Image.new("L", (W, W), 0)


def rect(d, box, **kw):
    d.rectangle([s(box[0]), s(box[1]), s(box[2]), s(box[3])], **kw)


def rrect(d, box, r, **kw):
    d.rounded_rectangle([s(box[0]), s(box[1]), s(box[2]), s(box[3])], radius=s(r), **kw)


def ell(d, cx, cy, rx, ry=None, **kw):
    ry = rx if ry is None else ry
    d.ellipse([s(cx - rx), s(cy - ry), s(cx + rx), s(cy + ry)], **kw)


def seg(d, p0, p1, w, fill):
    d.line([(s(p0[0]), s(p0[1])), (s(p1[0]), s(p1[1]))], fill=fill, width=max(1, int(s(w))))


def poly(d, pts, **kw):
    d.polygon([(s(x), s(y)) for x, y in pts], **kw)


# ------------------------------------------------------------------ paper
def finish_paper(mask, ink_layer, seed):
    """Fill the mask with paper, add ink (lines etc.), fibre noise, soft shading and a thin edge."""
    paper = Image.new("RGBA", (W, W), PAPER + (255,))
    paper.alpha_composite(ink_layer)
    arr = np.asarray(paper).astype(np.float32)
    rs = np.random.RandomState(seed)
    small = Image.fromarray((rs.rand(W // 3, W // 3) * 255).astype(np.uint8)).resize((W, W), Image.BICUBIC)
    n = np.asarray(small).astype(np.float32) / 255.0
    yy, xx = np.mgrid[0:W, 0:W].astype(np.float32)
    shade = 1.0 - 0.055 * (xx + yy) / (2 * W)                 # light from the top left
    arr[..., :3] *= (shade * (0.985 + 0.03 * n))[..., None]
    out = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    eroded = mask.filter(ImageFilter.MinFilter(5))
    edge = ImageChops.subtract(mask, eroded)
    edge_img = Image.new("RGBA", (W, W), (176, 154, 132, 255))
    edge_img.putalpha(edge.point(lambda v: int(v * 0.85)))
    out.alpha_composite(edge_img)
    out.putalpha(mask)
    return out


def clipped(ink, mask):
    ink.putalpha(ImageChops.multiply(ink.getchannel("A"), mask))
    return ink


def hlines(d, x0, x1, y0, y1, step, w=3, col=LINE):
    y = y0
    while y <= y1:
        seg(d, (x0, y), (x1, y), w, col + (255,))
        y += step


# ------------------------------------------------------------------ stickers
def outline_sticker(spr, grow=7):
    """White die-cut border and a soft shadow around a sticker sprite."""
    a = spr.getchannel("A")
    dil = a.filter(ImageFilter.MaxFilter(grow * SS * 2 + 1))
    white = Image.new("RGBA", spr.size, (255, 252, 246, 255))
    white.putalpha(dil)
    out = Image.new("RGBA", spr.size, (0, 0, 0, 0))
    sh = Image.new("RGBA", spr.size, (60, 36, 24, 0))
    sh.putalpha(dil.filter(ImageFilter.GaussianBlur(4 * SS)).point(lambda v: int(v * 0.35)))
    out.alpha_composite(sh, (3 * SS, 4 * SS))
    out.alpha_composite(white)
    out.alpha_composite(spr)
    return out


def place(dst, spr, cx, cy, scale=1.0, angle=0):
    sp = spr
    if scale != 1.0:
        sp = sp.resize((int(sp.size[0] * scale), int(sp.size[1] * scale)), Image.LANCZOS)
    if angle:
        sp = sp.rotate(angle, Image.BICUBIC, expand=True)
    dst.alpha_composite(sp, (int(s(cx) - sp.size[0] / 2), int(s(cy) - sp.size[1] / 2)))


def sprite(size=200):
    return Image.new("RGBA", (s(size), s(size)), (0, 0, 0, 0))


def bear(variant="sit", heart=False):
    sp = sprite(200)
    d = ImageDraw.Draw(sp)
    fur, fur_d, light = (176, 128, 92), (146, 100, 70), (236, 212, 182)
    ell(d, 100, 140, 46, 44, fill=fur)                              # body
    ell(d, 100, 146, 28, 30, fill=light)                            # belly
    ell(d, 58, 150, 14, 20, fill=fur_d)                             # arms
    ell(d, 142, 150, 14, 20, fill=fur_d)
    ell(d, 78, 182, 17, 12, fill=fur_d)                             # feet
    ell(d, 122, 182, 17, 12, fill=fur_d)
    ell(d, 62, 52, 20, fill=fur_d)                                  # ears
    ell(d, 138, 52, 20, fill=fur_d)
    ell(d, 62, 52, 11, fill=(214, 168, 136))
    ell(d, 138, 52, 11, fill=(214, 168, 136))
    ell(d, 100, 82, 54, 48, fill=fur)                               # head
    ell(d, 100, 100, 24, 18, fill=light)                            # snout
    ell(d, 100, 95, 8, 6, fill=DARK)                                # nose
    seg(d, (100, 100), (100, 108), 2.5, DARK + (255,))
    ell(d, 80, 76, 5, fill=DARK)                                    # eyes
    ell(d, 120, 76, 5, fill=DARK)
    ell(d, 78, 74, 1.6, fill=(255, 255, 255, 255))
    ell(d, 118, 74, 1.6, fill=(255, 255, 255, 255))
    ell(d, 66, 96, 7, 4, fill=(226, 150, 140, 150))                 # blush
    ell(d, 134, 96, 7, 4, fill=(226, 150, 140, 150))
    if heart:
        for hx in (-9, 9):
            ell(d, 150 + hx, 132, 12, fill=(240, 130, 150))
        poly(d, [(129, 138), (171, 138), (150, 170)], fill=(240, 130, 150))
    return outline_sticker(sp)


def cookie(chips=True, bite=True):
    sp = sprite(180)
    d = ImageDraw.Draw(sp)
    ell(d, 90, 90, 70, fill=(168, 118, 76))
    ell(d, 90, 90, 60, fill=(190, 138, 90))
    rs = random.Random(5)
    if chips:
        for _ in range(11):
            a, r = rs.uniform(0, 6.28), rs.uniform(8, 52)
            ell(d, 90 + math.cos(a) * r, 90 + math.sin(a) * r, rs.uniform(6, 9), rs.uniform(5, 8), fill=(74, 46, 34))
    if bite:
        ell(d, 150, 38, 26, fill=(0, 0, 0, 0))
        sp2 = sp.copy()
        a = Image.new("L", sp.size, 0)
        ImageDraw.Draw(a).ellipse([s(124), s(12), s(176), s(64)], fill=255)
        sp2.putalpha(ImageChops.subtract(sp.getchannel("A"), a))
        sp = sp2
    return outline_sticker(sp)


def gingerbread(dark=False, bow=True):
    sp = sprite(180)
    d = ImageDraw.Draw(sp)
    c = (92, 58, 44) if dark else (186, 118, 76)
    ell(d, 90, 42, 28, fill=c)                                       # head
    rrect(d, (62, 66, 118, 126), 22, fill=c)                         # torso
    rrect(d, (18, 70, 70, 96), 13, fill=c)                           # arms
    rrect(d, (110, 70, 162, 96), 13, fill=c)
    rrect(d, (60, 112, 92, 168), 14, fill=c)                         # legs
    rrect(d, (88, 112, 120, 168), 14, fill=c)
    ic = (246, 230, 210, 255)
    ell(d, 80, 38, 4, fill=ic)
    ell(d, 100, 38, 4, fill=ic)
    d.arc([s(78), s(44), s(102), s(60)], 10, 170, fill=ic, width=s(3))
    for y in (92, 106):
        ell(d, 90, y, 4, fill=ic)
    if bow:
        poly(d, [(90, 66), (68, 58), (68, 76)], fill=(200, 70, 70))
        poly(d, [(90, 66), (112, 58), (112, 76)], fill=(200, 70, 70))
        ell(d, 90, 66, 5, fill=(150, 40, 44))
    seg(d, (24, 96), (40, 96), 3, ic)
    seg(d, (140, 96), (156, 96), 3, ic)
    return outline_sticker(sp, grow=6)


def cupcake():
    sp = sprite(200)
    d = ImageDraw.Draw(sp)
    poly(d, [(46, 108), (154, 108), (138, 184), (62, 184)], fill=(140, 90, 62))         # wrapper
    for x in range(58, 150, 12):
        seg(d, (x, 110), (x + (x - 100) * 0.12, 182), 2.5, (108, 68, 48, 255))
    for cx, cy, rx in ((100, 96, 60), (100, 76, 48), (100, 58, 34), (100, 42, 20)):      # frosting swirl
        ell(d, cx, cy, rx, 22, fill=(84, 52, 40))
        ell(d, cx - rx * 0.25, cy - 6, rx * 0.5, 7, fill=(120, 80, 62, 200))
    rs = random.Random(9)
    for _ in range(14):
        x, y = rs.uniform(60, 140), rs.uniform(50, 100)
        a = rs.uniform(0, 3.14)
        seg(d, (x, y), (x + math.cos(a) * 8, y + math.sin(a) * 8), 3, (248, 232, 212, 255))
    return outline_sticker(sp, grow=6)


def bow():
    sp = sprite(220)
    d = ImageDraw.Draw(sp)
    c, hi = (70, 44, 32), (112, 76, 56)
    poly(d, [(110, 100), (24, 56), (20, 140)], fill=c)
    poly(d, [(110, 100), (196, 56), (200, 140)], fill=c)
    for (x0, x1) in ((30, 98), (122, 190)):
        seg(d, (x0, 74), (x1, 98), 3, hi + (255,))
        seg(d, (x0, 122), (x1, 104), 3, hi + (255,))
    ell(d, 110, 100, 22, 26, fill=c)
    ell(d, 106, 92, 10, 12, fill=hi + (170,))
    return outline_sticker(sp, grow=4)


def tape(w, h, col, angle=0):
    sp = Image.new("RGBA", (s(w + 20), s(h + 20)), (0, 0, 0, 0))
    d = ImageDraw.Draw(sp)
    x0, y0 = 10, 10
    pts = [(x0, y0)]
    for i in range(0, h + 1, 8):                       # zigzag ends
        pts.append((x0 - (4 if (i // 8) % 2 else 0), y0 + i))
    pts.append((x0, y0 + h))
    pts.append((x0 + w, y0 + h))
    for i in range(h, -1, -8):
        pts.append((x0 + w + (4 if (i // 8) % 2 else 0), y0 + i))
    poly(d, pts, fill=col)
    seg(d, (x0 + 4, y0 + h * 0.3), (x0 + w - 4, y0 + h * 0.3), 2, (255, 255, 255, 60))
    if angle:
        sp = sp.rotate(angle, Image.BICUBIC, expand=True)
    return sp


def sparkle(d, cx, cy, r, col=(150, 190, 230, 255)):
    poly(d, [(cx, cy - r), (cx + r * 0.45, cy), (cx, cy + r), (cx - r * 0.45, cy)], fill=col)


# ------------------------------------------------------------------ the 8 designs
DESIGNS = {}


def design(name):
    def deco(fn):
        DESIGNS[name] = fn
        return fn
    return deco


@design("scallopChecklist")
def d_scallop():
    P = (72, 76, 568, 564)
    mask = mask_layer()
    md = ImageDraw.Draw(mask)
    rect(md, P, fill=255)
    for x in range(P[0] + 14, P[2], 28):                 # stamp-style perforated edge
        ell(md, x, P[1], 11, fill=0)
        ell(md, x, P[3], 11, fill=0)
    for y in range(P[1] + 14, P[3], 28):
        ell(md, P[0], y, 11, fill=0)
        ell(md, P[2], y, 11, fill=0)
    ink = layer()
    d = ImageDraw.Draw(ink)
    for i in range(4):
        y = 176 + i * 92
        ell(d, 128, y, 17, outline=INK + (255,), width=s(4))
        seg(d, (176, y + 14), (528, y + 14), 6, LINE + (255,))
    deco = layer()
    dd = ImageDraw.Draw(deco)
    place(deco, bear(), 500, 494, 0.58)
    sparkle(dd, 556, 440, 14)
    sparkle(dd, 440, 548, 10)
    return mask, ink, deco, (0.27, 0.17, 0.57, 0.46), 0.12


@design("spiralBear")
def d_spiral():
    P = (104, 52, 574, 604)
    mask = mask_layer()
    rect(ImageDraw.Draw(mask), P, fill=255)
    ink = layer()
    d = ImageDraw.Draw(ink)
    hlines(d, 150, 548, 130, 560, 44, 3)
    deco = layer()
    dd = ImageDraw.Draw(deco)
    for i in range(12):
        y = 92 + i * 42
        seg(dd, (64, y), (126, y), 5, (70, 48, 38, 255))
        ell(dd, 118, y, 9, fill=(236, 226, 212, 255), outline=(70, 48, 38, 255), width=s(3))
    place(deco, bear(), 494, 488, 0.80)
    return mask, ink, deco, (0.25, 0.14, 0.62, 0.46), None


@design("tapedBear")
def d_taped():
    P = (70, 92, 570, 572)
    mask = mask_layer()
    rect(ImageDraw.Draw(mask), P, fill=255)
    ink = layer()
    d = ImageDraw.Draw(ink)
    rect(d, (88, 110, 552, 554), outline=(190, 164, 138, 255), width=s(4))
    hlines(d, 112, 528, 176, 530, 44, 3)
    deco = layer()
    place(deco, tape(190, 60, (206, 178, 142, 225), -2), 320, 90)
    place(deco, bear(heart=True), 140, 488, 0.68)
    return mask, ink, deco, (0.20, 0.22, 0.64, 0.42), None


@design("bowChecklist")
def d_bow():
    P = (70, 112, 570, 592)
    mask = mask_layer()
    rect(ImageDraw.Draw(mask), P, fill=255)
    ink = layer()
    d = ImageDraw.Draw(ink)
    x = 92
    while x < 548:
        seg(d, (x, 146), (x + 18, 146), 4, INK + (255,))
        x += 30
    for i in range(4):
        y = 224 + i * 88
        rect(d, (98, y - 14, 126, y + 14), outline=INK + (255,), width=s(3))
        seg(d, (150, y + 16), (540, y + 16), 3, LINE + (255,))
    deco = layer()
    place(deco, bow(), 320, 100, 0.86)
    return mask, ink, deco, (0.25, 0.30, 0.61, 0.58), None


@design("ringBinder")
def d_rings():
    P = (76, 100, 564, 596)
    mask = mask_layer()
    rrect(ImageDraw.Draw(mask), P, 52, fill=255)
    ink = layer()
    d = ImageDraw.Draw(ink)
    hlines(d, 112, 528, 206, 560, 44, 3)
    deco = layer()
    dd = ImageDraw.Draw(deco)
    for x in (196, 320, 444):
        ell(dd, x, 138, 11, fill=(96, 56, 44, 255))
        rrect(dd, (x - 5, 96, x + 5, 142), 5, fill=(70, 42, 34, 255))
    place(deco, gingerbread(dark=True, bow=False), 116, 122, 0.64, -18)
    place(deco, gingerbread(dark=True, bow=False), 192, 86, 0.50, 16)
    return mask, ink, deco, (0.17, 0.30, 0.68, 0.58), None


@design("tapePad")
def d_tape_pad():
    mask = mask_layer()
    md = ImageDraw.Draw(mask)
    rect(md, (64, 84, 548, 568), fill=255)
    ink = layer()
    d = ImageDraw.Draw(ink)
    hlines(d, 84, 528, 150, 548, 34, 3, (150, 138, 128))
    back = layer()
    bd = ImageDraw.Draw(back)
    rect(bd, (92, 112, 584, 596), fill=(228, 206, 176, 255))
    back_mask = back.getchannel("A")
    deco = layer()
    dd = ImageDraw.Draw(deco)
    rect(dd, (302, 56, 342, 118), fill=(92, 56, 44, 255))
    place(deco, cookie(), 122, 514, 0.76)
    mask = ImageChops.lighter(mask, back_mask)
    return mask, ink, deco, (0.14, 0.22, 0.70, 0.46), None, back


@design("spiralTab")
def d_spiral_tab():
    P = (92, 74, 572, 590)
    mask = mask_layer()
    rect(ImageDraw.Draw(mask), P, fill=255)
    ink = layer()
    d = ImageDraw.Draw(ink)
    seg(d, (170, 90), (170, 580), 2.5, (200, 168, 156, 255))
    hlines(d, 120, 548, 130, 560, 40, 3, (156, 146, 136))
    deco = layer()
    dd = ImageDraw.Draw(deco)
    for i in range(10):
        y = 120 + i * 46
        seg(dd, (66, y), (124, y), 5, (80, 52, 40, 255))
        ell(dd, 116, y, 8, fill=(236, 226, 212, 255), outline=(80, 52, 40, 255), width=s(3))
    rect(dd, (268, 56, 370, 92), fill=(96, 62, 48, 255))
    place(deco, gingerbread(), 118, 512, 0.72)
    return mask, ink, deco, (0.30, 0.22, 0.58, 0.50), None


@design("tornCupcake")
def d_torn():
    rs = random.Random(21)
    pts = []
    x0, y0, x1, y1 = 84, 64, 566, 580
    for x in range(x0, x1, 10):
        pts.append((x, y0 + rs.uniform(-7, 7)))
    for y in range(y0, y1, 12):
        pts.append((x1 + rs.uniform(-4, 4), y))
    for x in range(x1, x0, -10):
        pts.append((x, y1 + rs.uniform(-9, 5)))
    for y in range(y1, y0, -12):
        pts.append((x0 + rs.uniform(-4, 4), y))
    mask = mask_layer()
    poly(ImageDraw.Draw(mask), pts, fill=255)
    ink = layer()
    d = ImageDraw.Draw(ink)
    seg(d, (146, 70), (146, 574), 2.5, (200, 168, 156, 255))
    hlines(d, 100, 550, 150, 560, 44, 3, (156, 156, 170))
    deco = layer()
    place(deco, cupcake(), 140, 496, 0.76)
    return mask, ink, deco, (0.32, 0.20, 0.56, 0.52), None


# ------------------------------------------------------------------ render
def render(name, fn, seed):
    result = fn()
    mask, ink, deco, text_rect, pin_y = result[:5]
    back = result[5] if len(result) > 5 else None
    paper = finish_paper(mask, clipped(ink, mask), seed)
    if back is not None:                               # extra sheet peeking out behind the pad
        sheet = Image.new("RGBA", (W, W), (238, 224, 204, 255))
        sheet.putalpha(back.getchannel("A"))
        full = Image.new("RGBA", (W, W), (0, 0, 0, 0))
        full.alpha_composite(sheet)
        full.alpha_composite(paper)
        paper = full
    paper.resize((N, N), Image.LANCZOS).save(RES / f"note_{name}_paper.png")
    deco.resize((N, N), Image.LANCZOS).save(RES / f"note_{name}_deco.png")
    return text_rect, pin_y


RES.mkdir(parents=True, exist_ok=True)
rows_rect, rows_pin = [], []
for i, (name, fn) in enumerate(DESIGNS.items()):
    tr, pin = render(name, fn, i + 3)
    rows_rect.append(f"        case .{name}: return CGRect(x: {tr[0]:.2f}, y: {tr[1]:.2f}, width: {tr[2]:.2f}, height: {tr[3]:.2f})")
    rows_pin.append(f"        case .{name}: return {'nil' if pin is None else f'{pin:.2f}'}")

(MODELS / "NoteDesignLayout.swift").write_text(
    "import CoreGraphics\n\n"
    "/// Where text may be written on each design, as a fraction of the note's square frame, and where\n"
    "/// a push-pin goes (nil = the design already has tape, rings or a bow). Generated by scripts/generate_notes.py.\n"
    "extension NoteDesign {\n"
    "    var textRect: CGRect {\n        switch self {\n" + "\n".join(rows_rect) + "\n        }\n    }\n\n"
    "    var pinY: Double? {\n        switch self {\n" + "\n".join(rows_pin) + "\n        }\n    }\n}\n"
)
print("rendered", len(DESIGNS), "designs")
