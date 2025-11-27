#!/usr/bin/env python3
"""
Update Android app icons with the new Play Store icon design
Generates all required sizes for different screen densities
"""

from PIL import Image
import os
import shutil
from datetime import datetime

def update_android_icons():
    """Generate and update all Android app icons"""

    # Source icon (the new 90% scale version)
    source_icon_path = '/Users/kcdacre8tor/thereal-everyday-christian/app_store_assets/icons/playstore_icon_512.png'

    # Android res directory
    android_res_dir = '/Users/kcdacre8tor/thereal-everyday-christian/android/app/src/main/res'

    # Icon sizes for different densities
    android_icon_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    # Backup directory for existing icons
    backup_dir = f'/Users/kcdacre8tor/thereal-everyday-christian/android/app/src/main/res/backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}'

    print("Android Icon Update Process")
    print("=" * 50)
    print(f"Source: {source_icon_path}")
    print(f"Target: Android app icons\n")

    # Load the source icon
    print("Loading source icon...")
    source_icon = Image.open(source_icon_path)

    # Ensure it's in RGBA mode
    if source_icon.mode != 'RGBA':
        source_icon = source_icon.convert('RGBA')

    # Create backup directory
    os.makedirs(backup_dir, exist_ok=True)
    print(f"Created backup directory: {backup_dir}\n")

    # Process each density
    for folder, size in android_icon_sizes.items():
        folder_path = os.path.join(android_res_dir, folder)
        icon_path = os.path.join(folder_path, 'ic_launcher.png')

        print(f"Processing {folder}:")
        print(f"  Size: {size}x{size}")

        # Backup existing icon if it exists
        if os.path.exists(icon_path):
            backup_folder = os.path.join(backup_dir, folder)
            os.makedirs(backup_folder, exist_ok=True)
            backup_path = os.path.join(backup_folder, 'ic_launcher.png')
            shutil.copy2(icon_path, backup_path)
            print(f"  Backed up existing icon")

        # Create folder if it doesn't exist
        os.makedirs(folder_path, exist_ok=True)

        # Resize the icon
        resized_icon = source_icon.resize((size, size), Image.Resampling.LANCZOS)

        # Save the new icon
        resized_icon.save(icon_path, 'PNG', optimize=True)
        print(f"  ✅ Updated: {icon_path}")
        print()

    # Also create adaptive icon versions (for Android 8.0+)
    print("Creating adaptive icon resources...")

    # For adaptive icons, we need both foreground and background
    # We'll use the logo as foreground and extract the gradient as background

    # Create foreground (logo with padding for adaptive icon safe zone)
    # Adaptive icons need extra padding (about 66% of full size for foreground)
    adaptive_size = 512
    foreground = Image.new('RGBA', (adaptive_size, adaptive_size), (0, 0, 0, 0))

    # Load just the logo
    logo_path = '/Users/kcdacre8tor/thereal-everyday-christian/assets/images/logo_playstore.png'
    logo = Image.open(logo_path)

    # Scale logo to 66% for adaptive icon safe zone
    logo_size = int(adaptive_size * 0.66)
    logo_resized = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)

    # Center the logo
    logo_x = (adaptive_size - logo_size) // 2
    logo_y = (adaptive_size - logo_size) // 2
    foreground.paste(logo_resized, (logo_x, logo_y), logo_resized)

    # Create background (gradient)
    bg_path = '/Users/kcdacre8tor/thereal-everyday-christian/assets/images/gradient_background.png'
    background_img = Image.open(bg_path)

    # Crop and resize background to square
    bg_width, bg_height = background_img.size
    min_dimension = min(bg_width, bg_height)
    left = (bg_width - min_dimension) // 2
    top = (bg_height - min_dimension) // 2
    right = left + min_dimension
    bottom = top + min_dimension

    bg_cropped = background_img.crop((left, top, right, bottom))
    bg_resized = bg_cropped.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)

    # Save adaptive icon components to mipmap-anydpi-v26
    adaptive_dir = os.path.join(android_res_dir, 'mipmap-anydpi-v26')
    os.makedirs(adaptive_dir, exist_ok=True)

    # Create adaptive icon XML
    adaptive_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>'''

    adaptive_xml_path = os.path.join(adaptive_dir, 'ic_launcher.xml')
    with open(adaptive_xml_path, 'w') as f:
        f.write(adaptive_xml)
    print(f"✅ Created adaptive icon XML: {adaptive_xml_path}")

    # Save foreground and background drawables
    drawable_dir = os.path.join(android_res_dir, 'drawable')
    os.makedirs(drawable_dir, exist_ok=True)

    # Save at highest resolution for drawable
    foreground_path = os.path.join(drawable_dir, 'ic_launcher_foreground.png')
    foreground.save(foreground_path, 'PNG', optimize=True)
    print(f"✅ Created foreground: {foreground_path}")

    background_path = os.path.join(drawable_dir, 'ic_launcher_background.png')
    bg_resized.save(background_path, 'PNG', optimize=True)
    print(f"✅ Created background: {background_path}")

    print("\n" + "=" * 50)
    print("✅ Android app icons updated successfully!")
    print(f"📁 Backup saved to: {backup_dir}")
    print("\n🎯 Next steps:")
    print("1. Run 'flutter clean' to clear cache")
    print("2. Run 'flutter pub get'")
    print("3. Rebuild the app to see the new icon")

    return True

if __name__ == "__main__":
    update_android_icons()