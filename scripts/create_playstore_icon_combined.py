#!/usr/bin/env python3
"""
Create Play Store icon by combining gradient background with logo
"""

from PIL import Image, ImageDraw
import os
from datetime import datetime

def create_playstore_icon():
    # Paths
    logo_path = '/Users/kcdacre8tor/thereal-everyday-christian/assets/images/logo_playstore.png'
    bg_path = '/Users/kcdacre8tor/thereal-everyday-christian/assets/images/gradient_background.png'
    output_dir = '/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons'

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Load images
    print("Loading images...")
    logo = Image.open(logo_path)
    background = Image.open(bg_path)

    # Create 512x512 canvas
    print("Creating 512x512 Play Store icon...")
    icon_size = 512
    final_icon = Image.new('RGBA', (icon_size, icon_size), (255, 255, 255, 0))

    # Process gradient background
    print("Processing gradient background...")
    # Calculate center crop for square aspect ratio
    bg_width, bg_height = background.size
    min_dimension = min(bg_width, bg_height)

    # Calculate crop box to get center square
    left = (bg_width - min_dimension) // 2
    top = (bg_height - min_dimension) // 2
    right = left + min_dimension
    bottom = top + min_dimension

    # Crop and resize background to 512x512
    bg_cropped = background.crop((left, top, right, bottom))
    bg_resized = bg_cropped.resize((icon_size, icon_size), Image.Resampling.LANCZOS)

    # Convert to RGBA if needed
    if bg_resized.mode != 'RGBA':
        bg_resized = bg_resized.convert('RGBA')

    # Paste background
    final_icon.paste(bg_resized, (0, 0))

    # Process logo
    print("Processing logo overlay...")
    # The logo is already 512x512, but let's scale it down slightly
    # to give some padding from the edges (85% of icon size)
    logo_scale = 0.85
    new_logo_size = int(icon_size * logo_scale)
    logo_resized = logo.resize((new_logo_size, new_logo_size), Image.Resampling.LANCZOS)

    # Calculate position to center the logo
    logo_x = (icon_size - new_logo_size) // 2
    logo_y = (icon_size - new_logo_size) // 2

    # Paste logo with transparency
    final_icon.paste(logo_resized, (logo_x, logo_y), logo_resized)

    # Save with different names for backup
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

    # Save main version
    main_output = os.path.join(output_dir, 'playstore_icon_512.png')
    final_icon.save(main_output, 'PNG', quality=100)
    print(f"Saved: {main_output}")

    # Save timestamped backup
    backup_output = os.path.join(output_dir, f'playstore_icon_512_{timestamp}.png')
    final_icon.save(backup_output, 'PNG', quality=100)
    print(f"Backup saved: {backup_output}")

    # Also save a preview with rounded corners (Google Play style)
    print("Creating rounded corner preview...")
    rounded_icon = final_icon.copy()

    # Create rounded corner mask
    mask = Image.new('L', (icon_size, icon_size), 0)
    draw = ImageDraw.Draw(mask)
    corner_radius = icon_size // 8  # 12.5% radius
    draw.rounded_rectangle([(0, 0), (icon_size, icon_size)], radius=corner_radius, fill=255)

    # Apply rounded corners
    output = Image.new('RGBA', (icon_size, icon_size), (0, 0, 0, 0))
    output.paste(rounded_icon, (0, 0))
    output.putalpha(mask)

    # Save rounded version
    rounded_output = os.path.join(output_dir, 'playstore_icon_512_rounded.png')
    output.save(rounded_output, 'PNG', quality=100)
    print(f"Rounded preview saved: {rounded_output}")

    print("\n✅ Play Store icon created successfully!")
    print(f"   Main icon: {main_output}")
    print(f"   Size: {final_icon.size}")
    print(f"   Logo scale: {int(logo_scale * 100)}% of icon size")

    return main_output

if __name__ == "__main__":
    create_playstore_icon()