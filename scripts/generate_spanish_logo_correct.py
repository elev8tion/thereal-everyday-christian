#!/usr/bin/env python3
"""
Generate Spanish version of Everyday Christian app logo
Matches the exact design: purple-blue gradient, golden sunrise, white text, open book
Replaces "EVERYDAY" with "CHRISTIANO" and "CHRISTIAN" with "DE CADA DIA"
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Output directory
OUTPUT_DIR = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish"

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

def create_spanish_logo(size=1024):
    """Create Spanish version logo matching exact original design"""

    # Create rounded square with gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    # Create gradient background (purple-blue gradient from original)
    for y in range(size):
        # Gradient colors from original: purple (#7B68EE) to dark blue (#1E3A8A)
        ratio = y / size
        r = int(123 * (1 - ratio) + 30 * ratio)
        g = int(104 * (1 - ratio) + 58 * ratio)
        b = int(238 * (1 - ratio) + 138 * ratio)

        for x in range(size):
            img.putpixel((x, y), (r, g, b, 255))

    # Create rounded corners mask
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.18)  # iOS app icon corner radius
    mask_draw.rounded_rectangle([(0, 0), (size, size)], radius=corner_radius, fill=255)

    # Apply mask
    img.putalpha(mask)

    # Create drawing context
    draw = ImageDraw.Draw(img)

    # Define colors
    gold = '#D4AF37'  # Golden color for sunrise/book/border
    white = '#FFFFFF'  # White text

    # Calculate positions
    center_x = size // 2

    # Sunrise position (top third)
    sunrise_y = int(size * 0.28)
    sunrise_radius = int(size * 0.13)

    # Draw sunrise rays (behind the arc)
    ray_length_long = int(size * 0.15)
    ray_length_short = int(size * 0.10)
    ray_width = int(size * 0.015)

    import math
    # Long rays (8 main directions)
    for angle in [180, 225, 270, 315, 0, 45, 90, 135]:
        if angle >= 180:  # Only top half
            rad = math.radians(angle)
            x1 = center_x + int((sunrise_radius + int(size * 0.02)) * math.cos(rad))
            y1 = sunrise_y + int((sunrise_radius + int(size * 0.02)) * math.sin(rad))
            x2 = center_x + int((sunrise_radius + ray_length_long) * math.cos(rad))
            y2 = sunrise_y + int((sunrise_radius + ray_length_long) * math.sin(rad))
            draw.line([(x1, y1), (x2, y2)], fill=gold, width=ray_width)

    # Short rays (in between)
    for angle in [202.5, 247.5, 292.5, 337.5, 22.5, 67.5, 112.5, 157.5]:
        if angle >= 180 or angle <= 90:
            rad = math.radians(angle)
            x1 = center_x + int((sunrise_radius + int(size * 0.01)) * math.cos(rad))
            y1 = sunrise_y + int((sunrise_radius + int(size * 0.01)) * math.sin(rad))
            x2 = center_x + int((sunrise_radius + ray_length_short) * math.cos(rad))
            y2 = sunrise_y + int((sunrise_radius + ray_length_short) * math.sin(rad))
            draw.line([(x1, y1), (x2, y2)], fill=gold, width=int(ray_width * 0.8))

    # Draw sunrise arc (semicircle)
    arc_thickness = int(size * 0.020)
    draw.arc(
        [(center_x - sunrise_radius, sunrise_y - sunrise_radius),
         (center_x + sunrise_radius, sunrise_y + sunrise_radius)],
        start=180, end=0, fill=gold, width=arc_thickness
    )

    # Draw inner rays inside the arc
    inner_ray_count = 15
    inner_ray_length = int(sunrise_radius * 0.7)
    inner_ray_width = int(size * 0.008)
    for i in range(inner_ray_count):
        angle = 180 + (i * 180 / (inner_ray_count - 1))
        rad = math.radians(angle)
        x1 = center_x + int((sunrise_radius * 0.15) * math.cos(rad))
        y1 = sunrise_y + int((sunrise_radius * 0.15) * math.sin(rad))
        x2 = center_x + int(inner_ray_length * math.cos(rad))
        y2 = sunrise_y + int(inner_ray_length * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=gold, width=inner_ray_width)

    # Draw horizontal lines flanking "EVERYDAY"/"CHRISTIANO"
    line_y = int(size * 0.465)
    line_length = int(size * 0.12)
    line_width = int(size * 0.010)

    # Left line
    draw.line([(int(size * 0.20), line_y), (int(size * 0.20) + line_length, line_y)],
              fill=gold, width=line_width)
    # Right line
    draw.line([(int(size * 0.80) - line_length, line_y), (int(size * 0.80), line_y)],
              fill=gold, width=line_width)

    # Load fonts
    try:
        # For "CHRISTIANO" (smaller text, wider spacing)
        font_top = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", int(size * 0.095))
        # For "DE CADA DIA" (larger text)
        font_bottom = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", int(size * 0.145))
    except:
        font_top = ImageFont.load_default()
        font_bottom = ImageFont.load_default()

    # Draw "CHRISTIANO" (centered, with decorative lines)
    top_text = "CHRISTIANO"
    top_y = int(size * 0.43)
    bbox_top = draw.textbbox((0, 0), top_text, font=font_top)
    text_width_top = bbox_top[2] - bbox_top[0]
    text_x_top = center_x - (text_width_top // 2)
    draw.text((text_x_top, top_y), top_text, fill=white, font=font_top)

    # Draw "DE CADA DIA" (larger, bold, centered)
    bottom_text = "DE CADA DIA"
    bottom_y = int(size * 0.53)
    bbox_bottom = draw.textbbox((0, 0), bottom_text, font=font_bottom)
    text_width_bottom = bbox_bottom[2] - bbox_bottom[0]
    text_x_bottom = center_x - (text_width_bottom // 2)
    draw.text((text_x_bottom, bottom_y), bottom_text, fill=white, font=font_bottom)

    # Draw open book at bottom
    book_y = int(size * 0.74)
    book_width = int(size * 0.35)
    book_height = int(size * 0.12)
    book_left = center_x - book_width // 2
    book_thickness = int(size * 0.015)

    # Book outline (golden)
    # Left page outline
    draw.line([(book_left, book_y), (center_x, book_y - int(size * 0.02))],
              fill=gold, width=book_thickness)
    draw.line([(center_x, book_y - int(size * 0.02)), (center_x, book_y + book_height)],
              fill=gold, width=book_thickness)
    draw.line([(center_x, book_y + book_height), (book_left, book_y + book_height)],
              fill=gold, width=book_thickness)
    draw.line([(book_left, book_y + book_height), (book_left, book_y)],
              fill=gold, width=book_thickness)

    # Right page outline
    draw.line([(center_x, book_y - int(size * 0.02)), (book_left + book_width, book_y)],
              fill=gold, width=book_thickness)
    draw.line([(book_left + book_width, book_y), (book_left + book_width, book_y + book_height)],
              fill=gold, width=book_thickness)
    draw.line([(book_left + book_width, book_y + book_height), (center_x, book_y + book_height)],
              fill=gold, width=book_thickness)

    # Book page lines (white, simulating text lines)
    page_line_count = 4
    page_line_width = int(size * 0.005)
    for i in range(1, page_line_count + 1):
        line_y_pos = book_y + int((book_height * i) / (page_line_count + 1))
        # Left page lines
        draw.line([(book_left + int(size * 0.02), line_y_pos),
                   (center_x - int(size * 0.02), line_y_pos)],
                  fill=white, width=page_line_width)
        # Right page lines
        draw.line([(center_x + int(size * 0.02), line_y_pos),
                   (book_left + book_width - int(size * 0.02), line_y_pos)],
                  fill=white, width=page_line_width)

    # Golden border around the entire icon
    border_width = int(size * 0.025)
    border_draw = ImageDraw.Draw(img)
    border_draw.rounded_rectangle(
        [(border_width // 2, border_width // 2),
         (size - border_width // 2, size - border_width // 2)],
        radius=corner_radius - border_width // 2,
        outline=gold,
        width=border_width
    )

    return img

def generate_all_sizes():
    """Generate all required icon sizes for iOS and Android"""

    sizes = {
        # iOS App Store
        'ios_app_store_1024.png': 1024,

        # iOS App Icons (iPhone)
        'ios_iphone_180.png': 180,  # 60pt @3x
        'ios_iphone_120.png': 120,  # 60pt @2x
        'ios_iphone_87.png': 87,    # 29pt @3x (Settings)
        'ios_iphone_80.png': 80,    # 40pt @2x (Spotlight)
        'ios_iphone_58.png': 58,    # 29pt @2x (Settings)

        # iOS App Icons (iPad)
        'ios_ipad_167.png': 167,    # 83.5pt @2x
        'ios_ipad_152.png': 152,    # 76pt @2x
        'ios_ipad_76.png': 76,      # 76pt @1x

        # Android Play Store
        'android_play_store_512.png': 512,

        # Android Launcher Icons
        'android_xxxhdpi_192.png': 192,
        'android_xxhdpi_144.png': 144,
        'android_xhdpi_96.png': 96,
        'android_hdpi_72.png': 72,
        'android_mdpi_48.png': 48,
    }

    print("Generating Spanish app logos (matching original design)...")

    for filename, size in sizes.items():
        print(f"  Creating {filename} ({size}x{size})")
        logo = create_spanish_logo(size)
        output_path = os.path.join(OUTPUT_DIR, filename)
        logo.save(output_path, 'PNG', quality=95)

    # Also create the main 1024x1024 version
    main_logo = create_spanish_logo(1024)
    main_logo.save(os.path.join(OUTPUT_DIR, 'spanish_logo_1024.png'), 'PNG', quality=95)

    print(f"\n✅ Generated {len(sizes) + 1} Spanish logo files in:")
    print(f"   {OUTPUT_DIR}")

if __name__ == '__main__':
    generate_all_sizes()
