#!/usr/bin/env python3
"""
Generate Spanish version of Everyday Christian app logo
Replaces "EVERYDAY" with "CHRISTIANO" and "CHRISTIAN" with "DE CADA DIA"
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Output directory
OUTPUT_DIR = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish"

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

def create_spanish_logo(size=1024):
    """Create Spanish version logo matching existing design"""

    # Create image with light background (matching original)
    img = Image.new('RGB', (size, size), color='#F5F5F0')
    draw = ImageDraw.Draw(img)

    # Define colors (matching original gold gradient scheme)
    gold_dark = '#B8860B'  # Dark goldenrod
    gold_light = '#DAA520'  # Goldenrod
    text_color = '#2C2C2C'  # Dark gray for text

    # Calculate positions (proportional to size)
    center_x = size // 2
    top_text_y = int(size * 0.15)  # "CHRISTIANO" position
    bottom_text_y = int(size * 0.78)  # "DE CADA DIA" position
    symbol_center_y = int(size * 0.45)  # Center symbol position

    # Try to use a clean sans-serif font
    # Fall back to default if custom fonts not available
    font_size_top = int(size * 0.12)  # Size for "CHRISTIANO"
    font_size_bottom = int(size * 0.09)  # Size for "DE CADA DIA"
    font_size_symbol = int(size * 0.25)  # Size for sunrise/book symbol

    try:
        # Try to load a clean font (Arial, Helvetica, or system default)
        font_top = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", font_size_top)
        font_bottom = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", font_size_bottom)
    except:
        # Fall back to default font
        font_top = ImageFont.load_default()
        font_bottom = ImageFont.load_default()

    # Draw "CHRISTIANO" at top (centered)
    top_text = "CHRISTIANO"
    bbox_top = draw.textbbox((0, 0), top_text, font=font_top)
    text_width_top = bbox_top[2] - bbox_top[0]
    text_x_top = center_x - (text_width_top // 2)
    draw.text((text_x_top, top_text_y), top_text, fill=text_color, font=font_top)

    # Draw sunrise/book symbol in center (simplified golden circle with rays)
    symbol_radius = int(size * 0.15)
    symbol_x = center_x
    symbol_y = symbol_center_y

    # Draw golden circle (sun)
    draw.ellipse(
        [symbol_x - symbol_radius, symbol_y - symbol_radius,
         symbol_x + symbol_radius, symbol_y + symbol_radius],
        fill=gold_light,
        outline=gold_dark,
        width=int(size * 0.01)
    )

    # Draw sun rays (simplified - 8 rays)
    ray_length = int(size * 0.08)
    ray_width = int(size * 0.02)
    for angle in range(0, 360, 45):
        import math
        rad = math.radians(angle)
        x1 = symbol_x + int((symbol_radius + ray_width) * math.cos(rad))
        y1 = symbol_y + int((symbol_radius + ray_width) * math.sin(rad))
        x2 = symbol_x + int((symbol_radius + ray_length) * math.cos(rad))
        y2 = symbol_y + int((symbol_radius + ray_length) * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=gold_dark, width=ray_width)

    # Draw open book below sun (simplified two pages)
    book_width = int(size * 0.25)
    book_height = int(size * 0.12)
    book_y = symbol_y + symbol_radius + int(size * 0.05)
    book_left = center_x - book_width // 2

    # Left page
    draw.polygon(
        [(book_left, book_y),
         (center_x, book_y - int(size * 0.02)),
         (center_x, book_y + book_height),
         (book_left, book_y + book_height)],
        fill='#FFFFFF',
        outline=gold_dark,
        width=int(size * 0.005)
    )

    # Right page
    draw.polygon(
        [(center_x, book_y - int(size * 0.02)),
         (book_left + book_width, book_y),
         (book_left + book_width, book_y + book_height),
         (center_x, book_y + book_height)],
        fill='#F8F8F8',
        outline=gold_dark,
        width=int(size * 0.005)
    )

    # Draw "DE CADA DIA" at bottom (centered)
    bottom_text = "DE CADA DIA"
    bbox_bottom = draw.textbbox((0, 0), bottom_text, font=font_bottom)
    text_width_bottom = bbox_bottom[2] - bbox_bottom[0]
    text_x_bottom = center_x - (text_width_bottom // 2)
    draw.text((text_x_bottom, bottom_text_y), bottom_text, fill=text_color, font=font_bottom)

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

        # Android Launcher Icons (xxxhdpi to mdpi)
        'android_xxxhdpi_192.png': 192,
        'android_xxhdpi_144.png': 144,
        'android_xhdpi_96.png': 96,
        'android_hdpi_72.png': 72,
        'android_mdpi_48.png': 48,
    }

    print("Generating Spanish app logos...")

    for filename, size in sizes.items():
        print(f"  Creating {filename} ({size}x{size})")
        logo = create_spanish_logo(size)
        output_path = os.path.join(OUTPUT_DIR, filename)
        logo.save(output_path, 'PNG', quality=95)

    # Also create the main 1024x1024 version without prefix
    main_logo = create_spanish_logo(1024)
    main_logo.save(os.path.join(OUTPUT_DIR, 'spanish_logo_1024.png'), 'PNG', quality=95)

    print(f"\n✅ Generated {len(sizes) + 1} Spanish logo files in:")
    print(f"   {OUTPUT_DIR}")

if __name__ == '__main__':
    generate_all_sizes()
