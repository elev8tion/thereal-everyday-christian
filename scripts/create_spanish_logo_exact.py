#!/usr/bin/env python3
"""
Create exact replica of Everyday Christian logo with Spanish text
Uses the original logo as base and overlays new text
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Paths
ORIGINAL_LOGO = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons_new/Icon-1024.png"
OUTPUT_DIR = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish"

def create_spanish_logo_from_original(size=1024):
    """Load original logo and replace text with Spanish"""

    # Load original image
    original = Image.open(ORIGINAL_LOGO)

    # Resize if needed
    if original.size[0] != size:
        original = original.resize((size, size), Image.Resampling.LANCZOS)

    # Convert to RGBA for editing
    img = original.convert('RGBA')
    draw = ImageDraw.Draw(img)

    # Sample the background color from the text area to cover original text
    # Get color from middle area (where text is)
    bg_color_sample = img.getpixel((size // 2, int(size * 0.47)))

    # Cover "EVERYDAY" text area with background
    # Create a rectangle that covers the existing text
    everyday_y_start = int(size * 0.40)
    everyday_y_end = int(size * 0.51)

    # Sample multiple points to get the gradient
    for y in range(everyday_y_start, everyday_y_end):
        bg_sample = img.getpixel((size // 2, y))
        draw.rectangle(
            [(int(size * 0.15), y), (int(size * 0.85), y + 1)],
            fill=bg_sample
        )

    # Cover "CHRISTIAN" text area with background
    christian_y_start = int(size * 0.51)
    christian_y_end = int(size * 0.70)

    for y in range(christian_y_start, christian_y_end):
        bg_sample = img.getpixel((size // 2, y))
        draw.rectangle(
            [(int(size * 0.10), y), (int(size * 0.90), y + 1)],
            fill=bg_sample
        )

    # Load font - try multiple options
    font_top = None
    font_bottom = None

    font_paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf",
    ]

    for font_path in font_paths:
        try:
            font_top = ImageFont.truetype(font_path, int(size * 0.085))
            font_bottom = ImageFont.truetype(font_path, int(size * 0.135))
            break
        except:
            continue

    if font_top is None:
        print("Warning: Could not load custom font, using default")
        font_top = ImageFont.load_default()
        font_bottom = ImageFont.load_default()

    # Draw "CHRISTIANO" where "EVERYDAY" was
    top_text = "CHRISTIANO"
    center_x = size // 2
    top_y = int(size * 0.42)

    # Get text bounding box for centering
    bbox_top = draw.textbbox((0, 0), top_text, font=font_top)
    text_width = bbox_top[2] - bbox_top[0]
    text_x = center_x - (text_width // 2)

    # Draw white text
    draw.text((text_x, top_y), top_text, fill=(255, 255, 255, 255), font=font_top)

    # Draw "DE CADA DIA" where "CHRISTIAN" was
    bottom_text = "DE CADA DIA"
    bottom_y = int(size * 0.53)

    bbox_bottom = draw.textbbox((0, 0), bottom_text, font=font_bottom)
    text_width_bottom = bbox_bottom[2] - bbox_bottom[0]
    text_x_bottom = center_x - (text_width_bottom // 2)

    draw.text((text_x_bottom, bottom_y), bottom_text, fill=(255, 255, 255, 255), font=font_bottom)

    return img

def generate_all_sizes():
    """Generate all required icon sizes"""

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

    print("Creating Spanish logo from original...")

    for filename, size in sizes.items():
        print(f"  Generating {filename} ({size}x{size})")
        logo = create_spanish_logo_from_original(size)
        output_path = os.path.join(OUTPUT_DIR, filename)
        logo.save(output_path, 'PNG', quality=100)

    print(f"\n✅ Generated {len(sizes)} Spanish logo files")
    print(f"   Location: {OUTPUT_DIR}")

if __name__ == '__main__':
    generate_all_sizes()
