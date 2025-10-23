#!/usr/bin/env python3
"""
App Icon Generation Script for Everyday Christian
Generates all required icon sizes for iOS and Android
"""

import os
import subprocess
from pathlib import Path

PROJECT_ROOT = Path("/Users/kcdacre8tor/ everyday-christian")
SOURCE_LOGO = PROJECT_ROOT / "assets/images/logo_playstore.png"
ICONS_DIR = PROJECT_ROOT / "app_store_assets/icons"
IOS_ICONS = PROJECT_ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_RES = PROJECT_ROOT / "android/app/src/main/res"

# iOS Icon Sizes (all required sizes for iPhone and iPad)
IOS_SIZES = {
    20: "Icon-20.png",
    29: "Icon-29.png",
    40: "Icon-40.png",
    58: "Icon-58.png",
    60: "Icon-60.png",
    76: "Icon-76.png",
    80: "Icon-80.png",
    87: "Icon-87.png",
    120: "Icon-120.png",
    152: "Icon-152.png",
    167: "Icon-167.png",
    180: "Icon-180.png",
    1024: "Icon-1024.png",
}

# Android Icon Sizes
ANDROID_SIZES = {
    48: "mipmap-mdpi",
    72: "mipmap-hdpi",
    96: "mipmap-xhdpi",
    144: "mipmap-xxhdpi",
    192: "mipmap-xxxhdpi",
}

def create_icon(source, output_path, size):
    """Create an icon using sips"""
    try:
        subprocess.run(
            ["sips", "-z", str(size), str(size), str(source), "--out", str(output_path)],
            check=True,
            capture_output=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error creating icon {output_path}: {e}")
        return False

def main():
    # Create directories
    ICONS_DIR.mkdir(parents=True, exist_ok=True)
    IOS_ICONS.mkdir(parents=True, exist_ok=True)

    for density in ANDROID_SIZES.values():
        (ANDROID_RES / density).mkdir(parents=True, exist_ok=True)

    print("Generating iOS App Icons...")
    ios_count = 0
    for size, filename in IOS_SIZES.items():
        output = IOS_ICONS / filename
        print(f"  Creating iOS icon: {size}x{size} -> {filename}")
        if create_icon(SOURCE_LOGO, output, size):
            # Also save to icons directory
            (ICONS_DIR / f"ios_{filename}").write_bytes(output.read_bytes())
            ios_count += 1

    print("\nGenerating Android App Icons...")
    android_count = 0
    for size, density in ANDROID_SIZES.items():
        output = ANDROID_RES / density / "ic_launcher.png"
        print(f"  Creating Android icon: {size}x{size} -> {density}")
        if create_icon(SOURCE_LOGO, output, size):
            # Also save to icons directory
            (ICONS_DIR / f"android_{density}_ic_launcher.png").write_bytes(output.read_bytes())
            android_count += 1

    # Generate Play Store icon
    print("\nGenerating Play Store icon (512x512)...")
    playstore_icon = ICONS_DIR / "playstore_icon_512.png"
    if create_icon(SOURCE_LOGO, playstore_icon, 512):
        print("  ✓ Play Store icon created")

    print("\n" + "="*60)
    print("✓ Icon generation complete!")
    print(f"  iOS icons generated: {ios_count}")
    print(f"  Android icons generated: {android_count}")
    print(f"  All icons saved to: {ICONS_DIR}")
    print("="*60)

if __name__ == "__main__":
    main()
