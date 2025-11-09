#!/usr/bin/env python3
"""
Perfect recreation of Everyday Christian logo with Spanish text
Analyzes and recreates every element exactly
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

OUTPUT_DIR = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def create_perfect_spanish_logo(size=1024):
    """Perfect recreation matching original design exactly"""

    # Create base image with alpha channel
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    # Create gradient background (purple to dark blue)
    for y in range(size):
        progress = y / size
        # Top: RGB(123, 104, 238) - Medium Purple
        # Bottom: RGB(30, 58, 138) - Dark Blue
        r = int(123 + (30 - 123) * progress)
        g = int(104 + (58 - 104) * progress)
        b = int(238 + (138 - 238) * progress)

        for x in range(size):
            img.putpixel((x, y), (r, g, b, 255))

    # Apply rounded corners
    corner_radius = int(size * 0.225)  # iOS standard for app icons
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size-1, size-1)], radius=corner_radius, fill=255)
    img.putalpha(mask)

    draw = ImageDraw.Draw(img)

    # Colors
    gold = (212, 175, 55)  # D4AF37
    white = (255, 255, 255)

    center_x = size // 2

    # === SUNRISE AT TOP ===
    sunrise_center_y = int(size * 0.285)
    sunrise_radius = int(size * 0.13)

    # Draw sunrays FIRST (so arc goes over them)
    ray_thickness = int(size * 0.018)

    # Long rays (every 45 degrees)
    long_ray_length = int(size * 0.16)
    for angle in [180, 225, 270, 315, 0, 45, 90, 135]:
        if 135 <= angle <= 405:  # Top half + sides
            rad = math.radians(angle)
            start_x = center_x + int((sunrise_radius + 5) * math.cos(rad))
            start_y = sunrise_center_y + int((sunrise_radius + 5) * math.sin(rad))
            end_x = center_x + int((sunrise_radius + long_ray_length) * math.cos(rad))
            end_y = sunrise_center_y + int((sunrise_radius + long_ray_length) * math.sin(rad))
            draw.line([(start_x, start_y), (end_x, end_y)], fill=gold, width=ray_thickness)

    # Short rays (in between)
    short_ray_length = int(size * 0.10)
    for angle in [157.5, 202.5, 247.5, 292.5, 337.5, 22.5, 67.5, 112.5]:
        if 112.5 <= angle <= 427.5:
            rad = math.radians(angle)
            start_x = center_x + int((sunrise_radius + 3) * math.cos(rad))
            start_y = sunrise_center_y + int((sunrise_radius + 3) * math.sin(rad))
            end_x = center_x + int((sunrise_radius + short_ray_length) * math.cos(rad))
            end_y = sunrise_center_y + int((sunrise_radius + short_ray_length) * math.sin(rad))
            draw.line([(start_x, start_y), (end_x, end_y)], fill=gold, width=int(ray_thickness * 0.7))

    # Draw sunrise arc (semicircle outline)
    arc_thickness = int(size * 0.022)
    bbox = [center_x - sunrise_radius, sunrise_center_y - sunrise_radius,
            center_x + sunrise_radius, sunrise_center_y + sunrise_radius]
    draw.arc(bbox, start=180, end=0, fill=gold, width=arc_thickness)

    # Draw inner sunrise rays (inside the arc)
    inner_ray_count = 17
    inner_ray_length = int(sunrise_radius * 0.85)
    inner_ray_width = int(size * 0.008)

    for i in range(inner_ray_count):
        angle = 180 + (i * 180.0 / (inner_ray_count - 1))
        rad = math.radians(angle)
        start_dist = int(sunrise_radius * 0.05)
        start_x = center_x + int(start_dist * math.cos(rad))
        start_y = sunrise_center_y + int(start_dist * math.sin(rad))
        end_x = center_x + int(inner_ray_length * math.cos(rad))
        end_y = sunrise_center_y + int(inner_ray_length * math.sin(rad))
        draw.line([(start_x, start_y), (end_x, end_y)], fill=gold, width=inner_ray_width)

    # === DECORATIVE HORIZONTAL LINES ===
    line_y = int(size * 0.465)
    line_length = int(size * 0.135)
    line_thickness = int(size * 0.012)

    # Left line
    left_start = int(size * 0.18)
    draw.line([(left_start, line_y), (left_start + line_length, line_y)],
              fill=gold, width=line_thickness)

    # Right line
    right_end = int(size * 0.82)
    draw.line([(right_end - line_length, line_y), (right_end, line_y)],
              fill=gold, width=line_thickness)

    # === TEXT ===
    # Try multiple font paths
    font_paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]

    font_top_size = int(size * 0.095)
    font_bottom_size = int(size * 0.145)

    font_top = None
    font_bottom = None

    for path in font_paths:
        if os.path.exists(path):
            try:
                font_top = ImageFont.truetype(path, font_top_size)
                font_bottom = ImageFont.truetype(path, font_bottom_size)
                break
            except:
                continue

    if font_top is None:
        print("Warning: Using default font (install Arial Bold for best results)")
        font_top = ImageFont.load_default()
        font_bottom = ImageFont.load_default()

    # Draw "CHRISTIANO"
    top_text = "CHRISTIANO"
    top_y = int(size * 0.425)
    bbox = draw.textbbox((0, 0), top_text, font=font_top)
    text_width = bbox[2] - bbox[0]
    text_x = center_x - (text_width // 2)
    draw.text((text_x, top_y), top_text, fill=white, font=font_top)

    # Draw "DE CADA DIA"
    bottom_text = "DE CADA DIA"
    bottom_y = int(size * 0.535)
    bbox = draw.textbbox((0, 0), bottom_text, font=font_bottom)
    text_width = bbox[2] - bbox[0]
    text_x = center_x - (text_width // 2)
    draw.text((text_x, bottom_y), bottom_text, fill=white, font=font_bottom)

    # === OPEN BOOK AT BOTTOM ===
    book_center_y = int(size * 0.795)
    book_width = int(size * 0.36)
    book_height = int(size * 0.13)
    book_lift = int(size * 0.025)  # How much pages lift up
    book_thickness = int(size * 0.018)

    # Book outline (two pages)
    book_left = center_x - book_width // 2
    book_right = center_x + book_width // 2
    book_top = book_center_y - book_height // 2
    book_bottom = book_center_y + book_height // 2

    # Left page (slightly raised center)
    left_page = [
        (book_left, book_top),
        (center_x, book_top - book_lift),
        (center_x, book_bottom),
        (book_left, book_bottom)
    ]
    draw.polygon(left_page, outline=gold, width=book_thickness)

    # Right page (slightly raised center)
    right_page = [
        (center_x, book_top - book_lift),
        (book_right, book_top),
        (book_right, book_bottom),
        (center_x, book_bottom)
    ]
    draw.polygon(right_page, outline=gold, width=book_thickness)

    # Page lines (white, representing text)
    page_line_thickness = int(size * 0.006)
    num_lines = 4

    for i in range(1, num_lines + 1):
        line_y = book_top + (i * book_height // (num_lines + 1))
        margin = int(size * 0.025)

        # Left page lines
        draw.line([(book_left + margin, line_y), (center_x - margin, line_y)],
                 fill=white, width=page_line_thickness)

        # Right page lines
        draw.line([(center_x + margin, line_y), (book_right - margin, line_y)],
                 fill=white, width=page_line_thickness)

    # === GOLDEN BORDER ===
    border_thickness = int(size * 0.030)
    border_draw = ImageDraw.Draw(img)
    border_draw.rounded_rectangle(
        [(border_thickness//2, border_thickness//2),
         (size - border_thickness//2 - 1, size - border_thickness//2 - 1)],
        radius=corner_radius - border_thickness//2,
        outline=gold,
        width=border_thickness
    )

    return img

def generate_all_sizes():
    """Generate all required sizes"""

    sizes = {
        'spanish_logo_1024.png': 1024,
        'ios_app_store_1024.png': 1024,
        'ios_iphone_180.png': 180,
        'ios_iphone_120.png': 120,
        'ios_iphone_87.png': 87,
        'ios_iphone_80.png': 80,
        'ios_iphone_58.png': 58,
        'ios_ipad_167.png': 167,
        'ios_ipad_152.png': 152,
        'ios_ipad_76.png': 76,
        'android_play_store_512.png': 512,
        'android_xxxhdpi_192.png': 192,
        'android_xxhdpi_144.png': 144,
        'android_xhdpi_96.png': 96,
        'android_hdpi_72.png': 72,
        'android_mdpi_48.png': 48,
    }

    print("Creating perfect Spanish logo recreation...")

    for filename, size in sizes.items():
        print(f"  Generating {filename} ({size}x{size})")
        logo = create_perfect_spanish_logo(size)
        logo.save(os.path.join(OUTPUT_DIR, filename), 'PNG', quality=100, optimize=True)

    print(f"\n✅ Generated {len(sizes)} Spanish logos")
    print(f"   Location: {OUTPUT_DIR}")

if __name__ == '__main__':
    generate_all_sizes()
