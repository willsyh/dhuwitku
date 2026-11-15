"""Builds the Dhuwitku launcher icon and splash logo from tool/app_icon_source.png.

The source is a rounded blue tile on a white background. Outputs:
  * mipmap-*/ic_launcher_foreground.png - Android 8+ adaptive icon layer
    (108dp, full bleed): the tile in the middle, the area around it filled
    with the tile's own blue gradient so any launcher mask shape looks clean.
  * mipmap-*/ic_launcher.png - Android 7.x icon: the rounded tile as is.
  * drawable-xxxhdpi/splash_logo.png - Android 7-11 launch screen logo.
Also prints the colour to use for @color/ic_launcher_background.

Usage (from the project root; needs numpy and Pillow):
    python tool/make_app_icon.py            # writes the Android resources
    python tool/make_app_icon.py preview    # also writes icon_preview.png
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
SRC = os.path.join(ROOT, "tool", "app_icon_source.png")

# Tile rectangle and corner radius in the source image (measured).
TILE = (119, 129, 1137, 1099)
RADIUS = 262
# Tile width inside the 108dp adaptive layer. Launchers show the middle 72dp,
# so at 78dp the tile's bevelled rim stays hidden under every mask shape.
TILE_DP = 78

DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def tile_and_mask():
    src = Image.open(SRC).convert("RGB")
    tile = src.crop(TILE)
    w, h = tile.size
    big = Image.new("L", (w * 4, h * 4), 0)
    # Inset by 2px so no white antialiased edge from the source is kept.
    ImageDraw.Draw(big).rounded_rectangle((8, 8, w * 4 - 9, h * 4 - 9), RADIUS * 4, fill=255)
    mask = big.resize((w, h), Image.LANCZOS)
    return tile, mask


def fit_gradient(tile, mask):
    """Least-squares plane per channel fitted to the blue just inside the edge."""
    a = np.asarray(tile).astype(float)
    m = np.asarray(mask) > 250
    inner = np.asarray(mask.filter(ImageFilter.MinFilter(61))) > 250
    band = m & ~inner
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    band &= (b - r > 120)  # tile background only, not the cloud
    ys, xs = np.nonzero(band)
    h, w = m.shape
    X = np.stack([np.ones_like(xs), xs / w, ys / h], 1).astype(float)
    coef = [np.linalg.lstsq(X, a[ys, xs, c], rcond=None)[0] for c in range(3)]
    return coef


def gradient_canvas(coef, size, ox, oy, scale, tw, th):
    """Square canvas painted with the fitted plane, in tile coordinates."""
    yy, xx = np.mgrid[0:size, 0:size].astype(float)
    tx = (xx - ox) / scale / tw
    ty = (yy - oy) / scale / th
    out = np.stack([c[0] + c[1] * tx + c[2] * ty for c in coef], -1)
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB")


def adaptive_layer(tile, mask, coef, size=1296):
    tw, th = tile.size
    scale = size * TILE_DP / 108 / tw
    sw, sh = round(tw * scale), round(th * scale)
    ox, oy = (size - sw) / 2, (size - sh) / 2
    canvas = gradient_canvas(coef, size, ox, oy, scale, tw, th)
    soft = mask.filter(ImageFilter.GaussianBlur(3))
    canvas.paste(tile.resize((sw, sh), Image.LANCZOS), (round(ox), round(oy)),
                 soft.resize((sw, sh), Image.LANCZOS))
    return canvas


def rounded_tile(tile, mask, size, margin):
    """The tile with transparent corners, centred on a square of `size`."""
    rgba = tile.copy()
    rgba.putalpha(mask)
    tw, th = rgba.size
    s = (size - 2 * margin) / max(tw, th)
    small = rgba.resize((round(tw * s), round(th * s)), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.alpha_composite(small, ((size - small.width) // 2, (size - small.height) // 2))
    return out


def main():
    tile, mask = tile_and_mask()
    coef = fit_gradient(tile, mask)
    layer = adaptive_layer(tile, mask, coef)
    for name, d in DENSITIES.items():
        folder = os.path.join(RES, f"mipmap-{name}")
        layer.resize((round(108 * d),) * 2, Image.LANCZOS).save(
            os.path.join(folder, "ic_launcher_foreground.png"), optimize=True)
        rounded_tile(tile, mask, round(48 * d * 4), round(1 * d * 4)).resize(
            (round(48 * d),) * 2, Image.LANCZOS).save(os.path.join(folder, "ic_launcher.png"), optimize=True)
    os.makedirs(os.path.join(RES, "drawable-xxxhdpi"), exist_ok=True)
    rounded_tile(tile, mask, 448, 0).save(os.path.join(RES, "drawable-xxxhdpi", "splash_logo.png"), optimize=True)

    mid = layer.getpixel((layer.width // 2, layer.height // 20))
    print("background colour (top centre): #%02X%02X%02X" % mid[:3])

    if len(sys.argv) > 1 and sys.argv[1] == "preview":
        preview(layer)


def preview(layer):
    """Circle, squircle and rounded-square masks side by side."""
    size = 432
    full = layer.resize((size, size), Image.LANCZOS)
    vis = round(size * 72 / 108)
    off = (size - vis) // 2
    crop = full.crop((off - 20, off - 20, off + vis + 20, off + vis + 20))
    cells = []
    for shape in ("circle", "squircle", "square"):
        m = Image.new("L", (vis * 4, vis * 4), 0)
        d = ImageDraw.Draw(m)
        if shape == "circle":
            d.ellipse((0, 0, vis * 4 - 1, vis * 4 - 1), fill=255)
        elif shape == "squircle":
            n = 4.0
            pts = []
            for t in np.linspace(0, 2 * np.pi, 400):
                c, s_ = np.cos(t), np.sin(t)
                x = np.sign(c) * abs(c) ** (2 / n)
                y = np.sign(s_) * abs(s_) ** (2 / n)
                pts.append(((x + 1) * vis * 2, (y + 1) * vis * 2))
            d.polygon(pts, fill=255)
        else:
            d.rounded_rectangle((0, 0, vis * 4 - 1, vis * 4 - 1), vis * 4 // 6, fill=255)
        m = m.resize((vis, vis), Image.LANCZOS)
        cell = Image.new("RGB", (vis + 40, vis + 40), (240, 240, 240))
        cell.paste(crop.crop((20, 20, 20 + vis, 20 + vis)), (20, 20), m)
        cells.append(cell)
    sheet = Image.new("RGB", (sum(c.width for c in cells) + full.width, max(full.height, cells[0].height)), (255, 255, 255))
    x = 0
    for c in cells:
        sheet.paste(c, (x, 0))
        x += c.width
    sheet.paste(full, (x, 0))
    sheet.save(os.path.join(ROOT, "tool", "icon_preview.png"))


if __name__ == "__main__":
    main()
