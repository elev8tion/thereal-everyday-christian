#!/usr/bin/env python3
"""
Generate all Spanish icon sizes matching the English icons_new folder
"""

from PIL import Image, ImageDraw
import os

SOURCE_LOGO = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish/Spanish Emblem Logo for Everyday Christian-2.png"
OUTPUT_DIR = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish"

def create_icon_with_background(source_img, size):
    """Create app icon with gradient background matching English version"""

    # Create new image with gradient background
    icon = Image.new('RGB', (size, size))

    # Create purple-blue gradient (matching English version exactly)
    for y in range(size):
        progress = y / size
        # Top: RGB(123, 104, 238) - Medium Purple
        # Bottom: RGB(30, 58, 138) - Dark Blue
        r = int(123 + (30 - 123) * progress)
        g = int(104 + (58 - 104) * progress)
        b = int(238 + (138 - 238) * progress)

        for x in range(size):
            icon.putpixel((x, y), (r, g, b))

    # Resize source logo to fit
    logo_resized = source_img.resize((size, size), Image.Resampling.LANCZOS)

    # Composite logo on background
    if logo_resized.mode == 'RGBA':
        icon.paste(logo_resized, (0, 0), logo_resized)
    else:
        icon.paste(logo_resized, (0, 0))

    # Apply rounded corners for iOS
    corner_radius = int(size * 0.225)
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size-1, size-1)], radius=corner_radius, fill=255)

    # Convert to RGBA and apply mask
    icon_rgba = icon.convert('RGBA')
    icon_rgba.putalpha(mask)

    # Add golden border
    draw = ImageDraw.Draw(icon_rgba)
    gold = (212, 175, 55)
    border_thickness = int(size * 0.030)
    draw.rounded_rectangle(
        [(border_thickness//2, border_thickness//2),
         (size - border_thickness//2 - 1, size - border_thickness//2 - 1)],
        radius=corner_radius - border_thickness//2,
        outline=gold,
        width=border_thickness
    )

    return icon_rgba

def generate_all_sizes():
    """Generate all sizes matching English icons_new folder"""

    print("Loading Spanish logo...")
    source = Image.open(SOURCE_LOGO)

    # All sizes from icons_new folder
    sizes = {
        'Icon-1024.png': 1024,
        'Icon-180.png': 180,
        'Icon-167.png': 167,
        'Icon-152.png': 152,
        'Icon-120.png': 120,
        'Icon-87.png': 87,
        'Icon-80.png': 80,
        'Icon-76.png': 76,
        'Icon-60.png': 60,
        'Icon-58.png': 58,
        'Icon-40.png': 40,
        'Icon-29.png': 29,
        'Icon-20.png': 20,
    }

    print(f"Generating {len(sizes)} Spanish icon sizes...")

    for filename, size in sizes.items():
        print(f"  Creating {filename} ({size}x{size})")
        icon = create_icon_with_background(source, size)
        output_path = os.path.join(OUTPUT_DIR, filename)
        icon.save(output_path, 'PNG', quality=100)

    print(f"\n✅ Generated {len(sizes)} Spanish icons")
    print(f"   Location: {OUTPUT_DIR}")
    print("\nIcons match English versions in icons_new/")

if __name__ == '__main__':
    generate_all_sizes()
