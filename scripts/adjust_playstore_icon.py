#!/usr/bin/env python3
"""
Adjust Play Store icon logo size - allows customization of the logo scale
"""

from PIL import Image, ImageDraw
import os
import sys
from datetime import datetime

def create_playstore_icon_with_scale(logo_scale=0.85):
    """
    Create Play Store icon with adjustable logo scale

    Args:
        logo_scale: Scale factor for logo (0.5 to 1.0, default 0.85)
    """
    # Paths
    logo_path = '/Users/kcdacre8tor/thereal-everyday-christian/assets/images/logo_playstore.png'
    bg_path = '/Users/kcdacre8tor/thereal-everyday-christian/assets/images/gradient_background.png'
    output_dir = '/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons'

    # Validate scale
    logo_scale = max(0.5, min(1.0, logo_scale))

    # Load images
    print(f"Creating icon with logo at {int(logo_scale * 100)}% scale...")
    logo = Image.open(logo_path)
    background = Image.open(bg_path)

    # Create 512x512 canvas
    icon_size = 512
    final_icon = Image.new('RGBA', (icon_size, icon_size), (255, 255, 255, 0))

    # Process gradient background
    bg_width, bg_height = background.size
    min_dimension = min(bg_width, bg_height)

    # Calculate crop box to get center square
    left = (bg_width - min_dimension) // 2
    top = (bg_height - min_dimension) // 2
    right = left + min_dimension
    bottom = top + min_dimension

    # Crop and resize background
    bg_cropped = background.crop((left, top, right, bottom))
    bg_resized = bg_cropped.resize((icon_size, icon_size), Image.Resampling.LANCZOS)

    # Convert to RGBA if needed
    if bg_resized.mode != 'RGBA':
        bg_resized = bg_resized.convert('RGBA')

    # Paste background
    final_icon.paste(bg_resized, (0, 0))

    # Process logo with custom scale
    new_logo_size = int(icon_size * logo_scale)
    logo_resized = logo.resize((new_logo_size, new_logo_size), Image.Resampling.LANCZOS)

    # Calculate position to center the logo
    logo_x = (icon_size - new_logo_size) // 2
    logo_y = (icon_size - new_logo_size) // 2

    # Paste logo with transparency
    final_icon.paste(logo_resized, (logo_x, logo_y), logo_resized)

    # Save with scale in filename
    scale_suffix = f"_{int(logo_scale * 100)}pct"
    output_path = os.path.join(output_dir, f'playstore_icon_512{scale_suffix}.png')
    final_icon.save(output_path, 'PNG', quality=100)

    print(f"✅ Saved: {output_path}")
    print(f"   Logo scale: {int(logo_scale * 100)}% of icon size")

    return output_path

def main():
    print("Play Store Icon Generator with Adjustable Logo Size")
    print("=" * 50)
    print("\nDefault scale is 85% (recommended)")
    print("You can try: 70%, 75%, 80%, 85%, 90%, 95%, 100%")

    if len(sys.argv) > 1:
        try:
            scale = float(sys.argv[1])
            if scale > 1:
                scale = scale / 100  # Convert percentage to decimal
        except ValueError:
            print("Invalid scale value. Using default 85%")
            scale = 0.85
    else:
        print("\nUsage: python3 adjust_playstore_icon.py [scale]")
        print("Example: python3 adjust_playstore_icon.py 0.75")
        print("     or: python3 adjust_playstore_icon.py 75")
        print("\nUsing default scale of 85%...")
        scale = 0.85

    create_playstore_icon_with_scale(scale)

    print("\n💡 Tip: To try different scales, run:")
    print("   python3 scripts/adjust_playstore_icon.py 0.75")
    print("   python3 scripts/adjust_playstore_icon.py 0.90")

if __name__ == "__main__":
    main()