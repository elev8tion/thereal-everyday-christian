#!/usr/bin/env python3
"""
Generate Spanish icons matching the transparent style of /icons/ folder
Just resize the source logo to all needed sizes - NO background, NO border
"""

from PIL import Image
import os

SOURCE_LOGO = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish/Spanish Emblem Logo for Everyday Christian-2.png"
OUTPUT_DIR = "/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/spanish"

def generate_all_sizes():
    """Generate all sizes by simply resizing the source logo"""

    print("Loading Spanish logo...")
    source = Image.open(SOURCE_LOGO)

    # All sizes from /icons/ folder (matching ios_Icon-*.png pattern)
    sizes = {
        'ios_Icon-1024.png': 1024,
        'ios_Icon-180.png': 180,
        'ios_Icon-167.png': 167,
        'ios_Icon-152.png': 152,
        'ios_Icon-120.png': 120,
        'ios_Icon-87.png': 87,
        'ios_Icon-80.png': 80,
        'ios_Icon-76.png': 76,
        'ios_Icon-60.png': 60,
        'ios_Icon-58.png': 58,
        'ios_Icon-40.png': 40,
        'ios_Icon-29.png': 29,
        'ios_Icon-20.png': 20,
        'android_mipmap-xxxhdpi_ic_launcher.png': 192,
        'android_mipmap-xxhdpi_ic_launcher.png': 144,
        'android_mipmap-xhdpi_ic_launcher.png': 96,
        'android_mipmap-hdpi_ic_launcher.png': 72,
        'android_mipmap-mdpi_ic_launcher.png': 48,
        'playstore_icon_512.png': 512,
    }

    print(f"Generating {len(sizes)} Spanish icon sizes (transparent style)...")

    for filename, size in sizes.items():
        print(f"  Creating {filename} ({size}x{size})")
        # Simply resize with high quality
        resized = source.resize((size, size), Image.Resampling.LANCZOS)
        output_path = os.path.join(OUTPUT_DIR, filename)
        resized.save(output_path, 'PNG', quality=100, optimize=True)

    print(f"\n✅ Generated {len(sizes)} Spanish icons")
    print(f"   Location: {OUTPUT_DIR}")
    print("\nIcons match /icons/ folder style (transparent, no background)")

if __name__ == '__main__':
    generate_all_sizes()
