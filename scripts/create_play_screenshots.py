#!/usr/bin/env python3
"""
Google Play Screenshot Generator for Morning On Time.

Takes raw phone screenshots and composites them into polished
Google Play store images (1080x1920) with:
- Colored gradient backgrounds
- Marketing headline text
- Rounded screenshot with shadow

Usage:
  1. Place raw screenshots:
     - English in screenshots/raw_en/
     - Spanish in screenshots/raw_es/
     Named: 01_getting_ready.png, 02_on_the_way.png, 03_on_the_way_urgent.png,
            04_success_idle.png, 05_settings.png

  2. Run: python3 scripts/create_play_screenshots.py

  3. Find results in screenshots/final_en/ and screenshots/final_es/

Requirements: pip3 install Pillow
"""

import os
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# --- Configuration ---

OUTPUT_WIDTH = 1080
OUTPUT_HEIGHT = 1920

# Where the screenshot sits on the canvas
SCREENSHOT_TOP_Y = 520       # top of screenshot area (more room for text)
SCREENSHOT_SIDE_MARGIN = 50  # left/right margin
SCREENSHOT_CORNER_RADIUS = 36
SCREENSHOT_SHADOW_OFFSET = 14
SCREENSHOT_SHADOW_BLUR = 30

# Text area
HEADLINE_Y = 80
HEADLINE_SUBLINE_GAP = 30   # space between headline bottom and subline top
HEADLINE_FONT_SIZE = 84      # bigger, bolder headline
HEADLINE_LINE_SPACING = 16
SUBLINE_FONT_SIZE = 40       # bigger body copy

# Status bar cropping (pixels to remove from top of raw screenshot)
STATUS_BAR_CROP = 90

# Definitions for each screenshot
SCREENSHOTS = [
    {
        "filename": "01_getting_ready.png",
        "bg_top": (77, 182, 172),       # teal
        "bg_bottom": (56, 142, 134),
        "en": {
            "headline": "Your Morning\nCo-Pilot",
            "subline": "Voice reminders guide your family\nfrom wake-up to school gate",
        },
        "es": {
            "headline": "Tu Copiloto\nde la Mañana",
            "subline": "Recordatorios de voz guían a tu familia\ndesde que suena el despertador",
        },
    },
    {
        "filename": "02_on_the_way.png",
        "bg_top": (255, 179, 0),        # amber
        "bg_bottom": (230, 126, 34),
        "en": {
            "headline": "Countdown\nto School",
            "subline": "Live timer keeps the family\nmoving and motivated",
        },
        "es": {
            "headline": "Cuenta Atrás\nhacia el Cole",
            "subline": "Un temporizador en vivo mantiene\na la familia en marcha",
        },
    },
    {
        "filename": "03_on_the_way_urgent.png",
        "bg_top": (211, 47, 47),         # red
        "bg_bottom": (183, 28, 28),
        "en": {
            "headline": "Hurry Up!\nAlmost There",
            "subline": "Urgency builds as the\ndeadline approaches",
        },
        "es": {
            "headline": "¡Date Prisa!\nCasi Llegamos",
            "subline": "La urgencia crece a medida\nque se acerca la hora límite",
        },
    },
    {
        "filename": "04_success_idle.png",
        "bg_top": (102, 187, 106),       # green
        "bg_bottom": (56, 142, 60),
        "en": {
            "headline": "Streaks &\nRewards",
            "subline": "Celebrate every win and build\nhabits with levels and rewards",
        },
        "es": {
            "headline": "Rachas y\nRecompensas",
            "subline": "Celebra cada logro y crea hábitos\ncon niveles y premios familiares",
        },
    },
    {
        "filename": "05_settings.png",
        "bg_top": (33, 150, 243),        # blue
        "bg_bottom": (25, 118, 210),
        "en": {
            "headline": "Setup in\nseconds",
            "subline": "Just three times: wake up,\nleave home, arrive at school",
        },
        "es": {
            "headline": "Configura en\nsegundos",
            "subline": "Solo tres horarios: despertar,\nsalir de casa, llegar al cole",
        },
    },
]


def find_font(weight="regular"):
    """Find a suitable system font. Returns a path string.
    weight: 'black', 'bold', or 'regular'
    """
    # Common macOS fonts by weight (heaviest first for headlines)
    candidates = {
        "black": [
            "/System/Library/Fonts/SFProDisplay-Black.otf",
            "/System/Library/Fonts/SFProDisplay-Heavy.otf",
            "/System/Library/Fonts/SFProDisplay-Bold.otf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/Library/Fonts/Arial Bold.ttf",
        ],
        "bold": [
            "/System/Library/Fonts/SFProDisplay-Bold.otf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
            "/Library/Fonts/Arial Bold.ttf",
        ],
        "regular": [
            "/System/Library/Fonts/SFProDisplay-Medium.otf",
            "/System/Library/Fonts/SFProDisplay-Regular.otf",
            "/System/Library/Fonts/Supplemental/Arial.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
            "/Library/Fonts/Arial.ttf",
        ],
    }
    for path in candidates.get(weight, candidates["regular"]):
        if os.path.exists(path):
            return path
    return None


def create_gradient(width, height, top_color, bottom_color):
    """Create a vertical gradient image."""
    img = Image.new("RGB", (width, height))
    for y in range(height):
        ratio = y / height
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * ratio)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * ratio)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * ratio)
        for x in range(width):
            img.putpixel((x, y), (r, g, b))
    return img


def create_gradient_fast(width, height, top_color, bottom_color):
    """Create a vertical gradient image (faster line-by-line method)."""
    img = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(img)
    for y in range(height):
        ratio = y / height
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * ratio)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * ratio)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    return img


def round_corners(img, radius):
    """Apply rounded corners to an image."""
    mask = Image.new("L", img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), img.size], radius=radius, fill=255)
    result = img.copy()
    result.putalpha(mask)
    return result


def add_shadow(img, offset=10, blur=20):
    """Add a drop shadow behind the image."""
    shadow = Image.new("RGBA", (img.width + blur * 2, img.height + blur * 2), (0, 0, 0, 0))
    shadow_layer = Image.new("RGBA", img.size, (0, 0, 0, 80))
    # Use the screenshot's alpha as the shadow shape
    if img.mode == "RGBA":
        shadow_layer.putalpha(img.split()[3])
    shadow.paste(shadow_layer, (blur + offset, blur + offset))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    # Composite the actual image on top
    shadow.paste(img, (blur, blur), img)
    return shadow


def compose_screenshot(raw_path, output_path, config, lang):
    """Create a single Google Play screenshot composite."""
    text = config[lang]

    # Create gradient background
    bg = create_gradient_fast(OUTPUT_WIDTH, OUTPUT_HEIGHT, config["bg_top"], config["bg_bottom"])
    bg = bg.convert("RGBA")

    # Load and process raw screenshot
    raw = Image.open(raw_path).convert("RGBA")

    # Crop status bar from top
    if STATUS_BAR_CROP > 0 and raw.height > STATUS_BAR_CROP:
        raw = raw.crop((0, STATUS_BAR_CROP, raw.width, raw.height))

    # Target width for the screenshot on canvas
    target_width = OUTPUT_WIDTH - (SCREENSHOT_SIDE_MARGIN * 2)
    # Scale proportionally
    scale = target_width / raw.width
    target_height = int(raw.height * scale)

    # Cap height so it doesn't overflow
    max_height = OUTPUT_HEIGHT - SCREENSHOT_TOP_Y - 40
    if target_height > max_height:
        target_height = max_height
        scale = target_height / raw.height
        target_width = int(raw.width * scale)

    raw_resized = raw.resize((target_width, target_height), Image.LANCZOS)

    # Round corners
    raw_rounded = round_corners(raw_resized, SCREENSHOT_CORNER_RADIUS)

    # Add shadow
    raw_with_shadow = add_shadow(raw_rounded, SCREENSHOT_SHADOW_OFFSET, SCREENSHOT_SHADOW_BLUR)

    # Center the screenshot horizontally
    ss_x = (OUTPUT_WIDTH - raw_with_shadow.width) // 2
    ss_y = SCREENSHOT_TOP_Y

    # Paste screenshot onto background
    bg.paste(raw_with_shadow, (ss_x, ss_y), raw_with_shadow)

    # Add text
    draw = ImageDraw.Draw(bg)

    # Use heaviest available font for headline (Duolingo-style bold titles)
    headline_font_path = find_font(weight="black")
    subline_font_path = find_font(weight="regular")

    if headline_font_path:
        headline_font = ImageFont.truetype(headline_font_path, HEADLINE_FONT_SIZE)
    else:
        headline_font = ImageFont.load_default()
        print("  Warning: No black/bold font found, using default")

    if subline_font_path:
        subline_font = ImageFont.truetype(subline_font_path, SUBLINE_FONT_SIZE)
    else:
        subline_font = ImageFont.load_default()
        print("  Warning: No regular font found, using default")

    # Draw headline (centered, white, extra bold)
    headline = text["headline"]
    draw.multiline_text(
        (OUTPUT_WIDTH // 2, HEADLINE_Y),
        headline,
        fill="white",
        font=headline_font,
        anchor="ma",
        align="center",
        spacing=HEADLINE_LINE_SPACING,
    )

    # Calculate subline Y dynamically from headline bounding box
    headline_bbox = draw.multiline_textbbox(
        (OUTPUT_WIDTH // 2, HEADLINE_Y),
        headline,
        font=headline_font,
        anchor="ma",
        align="center",
        spacing=HEADLINE_LINE_SPACING,
    )
    subline_y = headline_bbox[3] + HEADLINE_SUBLINE_GAP

    # Draw subline (centered, white with slight transparency)
    subline = text["subline"]
    draw.multiline_text(
        (OUTPUT_WIDTH // 2, subline_y),
        subline,
        fill=(255, 255, 255, 210),
        font=subline_font,
        anchor="ma",
        align="center",
        spacing=10,
    )

    # Save
    bg_rgb = bg.convert("RGB")
    bg_rgb.save(output_path, "PNG", quality=95)
    print(f"  Saved: {output_path}")


def process_language(lang, raw_dir, output_dir):
    """Process all screenshots for a single language.

    Returns (found_count, missing_filenames).
    """
    if not raw_dir.exists():
        raw_dir.mkdir(parents=True, exist_ok=True)
        print(f"Created directory: {raw_dir}")
        print(f"  Place {lang} raw screenshots here and re-run.")
        return 0, [s["filename"] for s in SCREENSHOTS]

    output_dir.mkdir(parents=True, exist_ok=True)

    found = 0
    missing = []

    for config in SCREENSHOTS:
        raw_path = raw_dir / config["filename"]
        if not raw_path.exists():
            missing.append(config["filename"])
            continue

        found += 1
        name = config["filename"].replace(".png", "")
        output_path = output_dir / f"{name}_{lang}.png"
        print(f"  [{lang}] Processing {config['filename']}...")
        compose_screenshot(raw_path, output_path, config, lang)

    return found, missing


def main():
    project_root = Path(__file__).parent.parent
    raw_en_dir = project_root / "screenshots" / "raw_en"
    raw_es_dir = project_root / "screenshots" / "raw_es"
    en_dir = project_root / "screenshots" / "final_en"
    es_dir = project_root / "screenshots" / "final_es"

    total_found = 0
    all_missing = {}

    # English
    print("=== English ===")
    found, missing = process_language("en", raw_en_dir, en_dir)
    total_found += found
    if missing:
        all_missing["en"] = (raw_en_dir, missing)

    # Spanish
    print("=== Spanish ===")
    found, missing = process_language("es", raw_es_dir, es_dir)
    total_found += found
    if missing:
        all_missing["es"] = (raw_es_dir, missing)

    print()
    print(f"Done! Processed {total_found} screenshot(s) total.")

    for lang, (raw_dir, filenames) in all_missing.items():
        print()
        print(f"Missing {len(filenames)} {lang} screenshot(s) - skipped:")
        for m in filenames:
            print(f"  {m}")
        print(f"Place them in: {raw_dir}/")

    if total_found > 0:
        print()
        print(f"English results: {en_dir}/")
        print(f"Spanish results: {es_dir}/")


if __name__ == "__main__":
    main()
