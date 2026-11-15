"""Renders the Dhuwitku launcher icon PNGs (needs Pillow).

The vector source of truth is android/app/src/main/res/drawable/
ic_launcher_foreground.xml (Android 8+). This script draws the same geometry
for the legacy PNG icons used by Android 7.x. Keep SHAPES in sync with it.

Usage (from the project root):
    python tool/render_icon.py android        # writes mipmap-*/ic_launcher.png
    python tool/render_icon.py preview out.png
"""
import sys
from PIL import Image, ImageDraw

BLUE = (0x3B, 0x82, 0xF6, 255)
CARD = (0xBF, 0xDB, 0xFE, 255)
CLASP = (0x1D, 0x4E, 0xD8, 255)
WHITE = (255, 255, 255, 255)

SHAPES = [  # (kind, box/center, radius, color)
    ("rect", (34, 32, 70, 48), 5, CARD),
    ("rect", (26, 40, 78, 78), 9, WHITE),
    ("rect", (60, 52, 82, 66), 7, CLASP),
    ("circle", (67, 59), 3, WHITE),
]

def draw_wallet(d, scale, ox=0.0, oy=0.0, zoom=0.85, cx=54, cy=55):
    def tx(x, y):
        return ((cx + (x - cx) * zoom) * scale + ox, (cy + (y - cy) * zoom) * scale + oy)
    for kind, geom, r, color in SHAPES:
        if kind == "rect":
            x1, y1 = tx(geom[0], geom[1]); x2, y2 = tx(geom[2], geom[3])
            d.rounded_rectangle((x1, y1, x2, y2), radius=r * zoom * scale, fill=color)
        else:
            x, y = tx(*geom); rr = r * zoom * scale
            d.ellipse((x - rr, y - rr, x + rr, y + rr), fill=color)

def legacy(size):
    """Square launcher icon for Android < 8 (rounded blue tile, wallet zoomed in)."""
    S = 1024
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pad = S * 0.04
    d.rounded_rectangle((pad, pad, S - pad, S - pad), radius=S * 0.22, fill=BLUE)
    draw_wallet(d, S / 108, zoom=1.2)
    return img.resize((size, size), Image.LANCZOS)

def adaptive_preview(size, shape="circle"):
    """What launchers show: 108 viewport, masked to the inner 72dp."""
    S = 1080
    img = Image.new("RGBA", (S, S), BLUE)
    draw_wallet(ImageDraw.Draw(img), S / 108)
    crop = img.crop((180, 180, 900, 900))  # visible 72/108
    mask = Image.new("L", crop.size, 0)
    md = ImageDraw.Draw(mask)
    if shape == "circle":
        md.ellipse((0, 0) + crop.size, fill=255)
    else:
        md.rounded_rectangle((0, 0) + crop.size, radius=crop.size[0] * 0.25, fill=255)
    out = Image.new("RGBA", crop.size, (0, 0, 0, 0)); out.paste(crop, mask=mask)
    return out.resize((size, size), Image.LANCZOS)

if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "android":
        res = "android/app/src/main/res"
        for density, size in [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)]:
            legacy(size).save(f"{res}/mipmap-{density}/ic_launcher.png")
        sys.exit(0)
    out = sys.argv[2]
    if mode == "preview":
        sheet = Image.new("RGBA", (900, 330), (0xF8, 0xFA, 0xFC, 255))
        sheet.paste(adaptive_preview(256, "circle"), (30, 37), adaptive_preview(256, "circle"))
        sheet.paste(adaptive_preview(256, "squircle"), (320, 37), adaptive_preview(256, "squircle"))
        lg = legacy(256); sheet.paste(lg, (610, 37), lg)
        small = adaptive_preview(48, "circle"); sheet.paste(small, (430, 290 - 48 + 30 - 10), small)
        sheet.save(out)
    else:  # legacy <size>
        legacy(int(mode)).save(out)
