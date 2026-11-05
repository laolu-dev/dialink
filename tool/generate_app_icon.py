"""Generates the Dialink app icons, one per theme, for iOS and Android.

Run from the project root:  python3 tool/generate_app_icon.py
Requires Pillow (pip install pillow).

iOS: `AppIcon` is the Glass icon (the iOS default theme); the others are
alternate icons `AppIcon-<Theme>`, each with dark and tinted versions.
Android: `ic_launcher` is the Clinical icon (the Android default theme);
the others are `ic_launcher_<theme>`, used by the activity aliases in
AndroidManifest.xml. Glass is iOS only.
The app also shows the icons, from `assets/icons/<theme>.png`.

It also makes the native launch screens, which show the default theme's icon
(Glass on iOS, Clinical on Android) on its background, light and dark. The
app's own splash then takes over in the patient's theme (SplashScreen).

Keep the themes in step with lib/src/config/theme/app_themes.dart.
"""

import json
import os
import shutil

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SS = 4  # supersampling factor for smooth edges
BASE = 1024


def rgb(hex_):
    hex_ = hex_.lstrip("#")
    return tuple(int(hex_[i : i + 2], 16) for i in (0, 2, 4))


def rgba(hex_, alpha):
    return rgb(hex_) + (round(alpha * 255),)


# name -> colours. `ios`/`android`: the asset name on that platform, or None.
THEMES = {
    "glass": dict(
        bg=("#BFE3E7", "#D6DEF8"), card=rgba("#FFFFFF", 0.78),
        head=rgba("#0B7A83", 0.22), mark="#0B7A83", dot="#F08A6B",
        ring=rgba("#FFFFFF", 0.95), dark_card="#2A8F98",
        ios="AppIcon", android=None,
    ),
    "clinical": dict(
        bg=("#0B7A83", "#14A3AE"), card="#FFFFFF", head="#DDF1F2",
        mark="#0B7A83", dot="#F08A6B", dark_card="#14A3AE",
        ios="AppIcon-Clinical", android="ic_launcher",
    ),
    "sage": dict(
        bg=("#3D7A55", "#62A27A"), card="#FFFDF6", head="#E2EEDF",
        mark="#3D7A55", dot="#E9B44C", dark_card="#62A27A",
        ios="AppIcon-Sage", android="ic_launcher_sage",
    ),
    "sunset": dict(
        bg=("#C4532F", "#EE8A5E"), card="#FFFFFF", head="#FCE3D8",
        mark="#C4532F", dot="#2F6F8F", dark_card="#EE8A5E",
        ios="AppIcon-Sunset", android="ic_launcher_sunset",
    ),
    "midnight": dict(
        bg=("#3A2FC2", "#6C63FF"), card="#FFFFFF", head="#E5E3FC",
        mark="#4B3FE0", dot="#FF6F61", dark_card="#6C63FF",
        ios="AppIcon-Midnight", android="ic_launcher_midnight",
    ),
    "highContrast": dict(
        bg=("#000000", "#000000"), card="#FFD60A", head="#FFD60A",
        mark="#000000", dot="#FFFFFF", dot_edge="#000000", dark_card="#FFD60A",
        ios="AppIcon-HighContrast", android="ic_launcher_high_contrast",
    ),
    "easyRead": dict(
        bg=("#FBF7EC", "#F1EAD6"), card="#FFFFFF", head="#1F5FAF",
        mark="#1F5FAF", dot="#D9822B", edge="#1B2A4A", dark_card="#1F5FAF",
        ios="AppIcon-EasyRead", android="ic_launcher_easy_read",
    ),
}


def colour(c):
    return rgb(c) + (255,) if isinstance(c, str) else c


def gradient(size, top, bottom):
    """Diagonal gradient from top-left to bottom-right."""
    top, bottom = rgb(top), rgb(bottom)
    small = Image.new("RGBA", (256, 256))
    px = small.load()
    for y in range(256):
        for x in range(256):
            t = (x + y) / 510
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)) + (255,)
    return small.resize((size, size), Image.BICUBIC)


def draw_glyph(img, t, card=None, head=None, mark=None):
    """Calendar with a medical cross, in a 100-unit design space."""
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    k = img.size[0] / 100
    s = lambda v: round(v * k)
    card = colour(card or t["card"])
    head = colour(head or t["head"])
    mark = colour(mark or t["mark"])

    # Card, with an outline for Easy read and a light rim for Glass.
    edge = t.get("edge") or t.get("ring")
    d.rounded_rectangle(
        [s(22), s(27), s(78), s(77)], radius=s(11), fill=card,
        outline=colour(edge) if edge else None,
        width=s(2.5 if t.get("edge") else 1.2) if edge else 0,
    )
    # Header band across the top of the card.
    band = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(band).rounded_rectangle(
        [s(22), s(27), s(78), s(77)], radius=s(11), fill=head
    )
    clip = Image.new("L", img.size, 0)
    ImageDraw.Draw(clip).rectangle([s(22), s(27), s(78), s(41)], fill=255)
    layer.alpha_composite(Image.composite(band, Image.new("RGBA", img.size), clip))
    # Binder rings and cross.
    for x in (34, 61):
        d.rounded_rectangle([s(x), s(21), s(x + 5), s(33)], radius=s(2.5), fill=mark)
    d.rounded_rectangle([s(45.5), s(47), s(54.5), s(71)], radius=s(2.5), fill=mark)
    d.rounded_rectangle([s(38), s(54.5), s(62), s(63.5)], radius=s(2.5), fill=mark)
    # Notification dot: a confirmed visit.
    dot_edge = t.get("dot_edge")
    d.ellipse(
        [s(68), s(21), s(80), s(33)], fill=colour(t["dot"]),
        outline=colour(dot_edge) if dot_edge else None,
        width=s(1.5) if dot_edge else 0,
    )
    img.alpha_composite(layer)


def render(t, variant="any", background=True):
    size = BASE * SS
    if variant == "any" and background:
        img = gradient(size, *t["bg"])
    else:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    if variant == "dark":
        draw_glyph(img, t, card=t["dark_card"], head=t["dark_card"],
                   mark="#000000" if t["dark_card"] == "#FFD60A" else "#FFFFFF")
    elif variant == "tinted":
        draw_glyph(img, dict(t, edge=None, ring=None, dot_edge=None, dot="#FFFFFF"),
                   card="#FFFFFF", head="#D0D0D0", mark="#404040")
    else:
        draw_glyph(img, t)
    return img.resize((BASE, BASE), Image.LANCZOS)


def rounded(img):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, img.size[0] - 1, img.size[1] - 1], radius=round(img.size[0] * 0.22), fill=255
    )
    out = img.copy()
    out.putalpha(mask)
    return out


def save(img, path, px):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.resize((px, px), Image.LANCZOS).save(path, optimize=True)


def ios():
    catalog = os.path.join(ROOT, "ios/Runner/Assets.xcassets")
    for t in THEMES.values():
        folder = os.path.join(catalog, f"{t['ios']}.appiconset")
        shutil.rmtree(folder, ignore_errors=True)
        os.makedirs(folder)
        # Icons must be opaque; dark and tinted ones may be transparent.
        render(t).convert("RGB").save(os.path.join(folder, "icon.png"), optimize=True)
        render(t, "dark").save(os.path.join(folder, "icon-dark.png"), optimize=True)
        render(t, "tinted").save(os.path.join(folder, "icon-tinted.png"), optimize=True)

        def entry(filename, appearance=None):
            e = {"filename": filename, "idiom": "universal", "platform": "ios", "size": "1024x1024"}
            if appearance:
                e["appearances"] = [{"appearance": "luminosity", "value": appearance}]
            return e

        with open(os.path.join(folder, "Contents.json"), "w") as f:
            json.dump(
                {
                    "images": [
                        entry("icon.png"),
                        entry("icon-dark.png", "dark"),
                        entry("icon-tinted.png", "tinted"),
                    ],
                    "info": {"author": "xcode", "version": 1},
                },
                f,
                indent=2,
            )


def android():
    res = os.path.join(ROOT, "android/app/src/main/res")
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    anydpi = os.path.join(res, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)

    for t in THEMES.values():
        name = t["android"]
        if not name:
            continue
        legacy = rounded(render(t))
        # Adaptive icons are 108dp with a 66dp safe zone: shrink the glyph.
        glyph = render(t, background=False)
        inner = round(BASE * 0.74)
        fg = Image.new("RGBA", (BASE, BASE), (0, 0, 0, 0))
        off = (BASE - inner) // 2
        fg.alpha_composite(glyph.resize((inner, inner), Image.LANCZOS), (off, off))
        bg = gradient(BASE, *t["bg"])
        mono = Image.new("RGBA", (BASE, BASE), (0, 0, 0, 0))
        mono.alpha_composite(
            render(t, "tinted").resize((inner, inner), Image.LANCZOS), (off, off)
        )

        for density, k in densities.items():
            d = os.path.join(res, f"mipmap-{density}")
            save(legacy, os.path.join(d, f"{name}.png"), round(48 * k))
            save(fg, os.path.join(d, f"{name}_foreground.png"), round(108 * k))
            save(bg, os.path.join(d, f"{name}_background.png"), round(108 * k))
            save(mono, os.path.join(d, f"{name}_monochrome.png"), round(108 * k))

        with open(os.path.join(anydpi, f"{name}.xml"), "w") as f:
            f.write(
                '<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                f'    <background android:drawable="@mipmap/{name}_background"/>\n'
                f'    <foreground android:drawable="@mipmap/{name}_foreground"/>\n'
                f'    <monochrome android:drawable="@mipmap/{name}_monochrome"/>\n'
                "</adaptive-icon>\n"
            )

    # The single-colour background is no longer used.
    old = os.path.join(res, "values/ic_launcher_background.xml")
    if os.path.exists(old):
        os.remove(old)


def assets():
    folder = os.path.join(ROOT, "assets/icons")
    os.makedirs(folder, exist_ok=True)
    for theme, t in THEMES.items():
        save(rounded(render(t)), os.path.join(folder, f"{theme}.png"), 256)


# The launch icon's size in points/dp; matches SplashScreen.iconSize.
SPLASH_ICON = 120

# Background behind the launch icon: (light, dark), as in app_themes.dart.
SPLASH_BACKGROUND = {
    "glass": ("#E3F0F2", "#0A1416"),
    "clinical": ("#F4F8F9", "#0A1517"),
}


def ios_splash():
    catalog = os.path.join(ROOT, "ios/Runner/Assets.xcassets")
    icon = rounded(render(THEMES["glass"]))
    folder = os.path.join(catalog, "LaunchImage.imageset")
    shutil.rmtree(folder, ignore_errors=True)
    os.makedirs(folder)
    images = []
    for scale in (1, 2, 3):
        name = "LaunchImage.png" if scale == 1 else f"LaunchImage@{scale}x.png"
        save(icon, os.path.join(folder, name), SPLASH_ICON * scale)
        images.append({"filename": name, "idiom": "universal", "scale": f"{scale}x"})
    with open(os.path.join(folder, "Contents.json"), "w") as f:
        json.dump({"images": images, "info": {"author": "xcode", "version": 1}}, f, indent=2)

    def component(hex_):
        r, g, b = rgb(hex_)
        return {
            "color-space": "srgb",
            "components": {"alpha": "1.000", "red": f"0x{r:02X}", "green": f"0x{g:02X}", "blue": f"0x{b:02X}"},
        }

    light, dark = SPLASH_BACKGROUND["glass"]
    folder = os.path.join(catalog, "LaunchBackground.colorset")
    os.makedirs(folder, exist_ok=True)
    with open(os.path.join(folder, "Contents.json"), "w") as f:
        json.dump(
            {
                "colors": [
                    {"color": component(light), "idiom": "universal"},
                    {
                        "appearances": [{"appearance": "luminosity", "value": "dark"}],
                        "color": component(dark),
                        "idiom": "universal",
                    },
                ],
                "info": {"author": "xcode", "version": 1},
            },
            f,
            indent=2,
        )


def android_splash():
    res = os.path.join(ROOT, "android/app/src/main/res")
    icon = rounded(render(THEMES["clinical"]))
    for density, k in {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}.items():
        save(icon, os.path.join(res, f"drawable-{density}", "splash_icon.png"), round(SPLASH_ICON * k))

    light, dark = SPLASH_BACKGROUND["clinical"]
    for folder, colour_ in (("values", light), ("values-night", dark)):
        os.makedirs(os.path.join(res, folder), exist_ok=True)
        with open(os.path.join(res, folder, "splash.xml"), "w") as f:
            f.write(
                '<?xml version="1.0" encoding="utf-8"?>\n'
                "<resources>\n"
                f'    <color name="splash_background">{colour_}</color>\n'
                "</resources>\n"
            )

    layers = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<!-- Generated by tool/generate_app_icon.py -->\n"
        '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <item android:drawable="@color/splash_background" />\n'
        "    <item>\n"
        '        <bitmap android:gravity="center" android:src="@drawable/splash_icon" />\n'
        "    </item>\n"
        "</layer-list>\n"
    )
    for folder in ("drawable", "drawable-v21"):
        with open(os.path.join(res, folder, "launch_background.xml"), "w") as f:
            f.write(layers)


if __name__ == "__main__":
    ios()
    android()
    assets()
    ios_splash()
    android_splash()
    print("App icons generated.")
