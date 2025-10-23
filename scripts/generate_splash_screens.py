#!/usr/bin/env python3
"""
Splash Screen Generation Script for Everyday Christian
Creates branded splash screens for iOS and Android
"""

import os
import subprocess
from pathlib import Path

PROJECT_ROOT = Path("/Users/kcdacre8tor/ everyday-christian")
SOURCE_LOGO = PROJECT_ROOT / "assets/images/logo_transparent.png"
SPLASH_DIR = PROJECT_ROOT / "app_store_assets/splash"
ANDROID_DRAWABLE = PROJECT_ROOT / "android/app/src/main/res"

# Android Splash Screen Sizes
ANDROID_SPLASH_SIZES = {
    320: ("drawable-mdpi", "splash.png"),
    480: ("drawable-hdpi", "splash.png"),
    640: ("drawable-xhdpi", "splash.png"),
    960: ("drawable-xxhdpi", "splash.png"),
    1280: ("drawable-xxxhdpi", "splash.png"),
}

def create_splash(source, output_path, size):
    """Create a splash screen using sips"""
    try:
        subprocess.run(
            ["sips", "-z", str(size), str(size), str(source), "--out", str(output_path)],
            check=True,
            capture_output=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error creating splash {output_path}: {e}")
        return False

def main():
    # Create directories
    SPLASH_DIR.mkdir(parents=True, exist_ok=True)

    print("Generating Android Splash Screens...")
    android_count = 0

    for size, (drawable, filename) in ANDROID_SPLASH_SIZES.items():
        drawable_dir = ANDROID_DRAWABLE / drawable
        drawable_dir.mkdir(parents=True, exist_ok=True)

        output = drawable_dir / filename
        print(f"  Creating splash: {size}x{size} -> {drawable}/{filename}")

        if create_splash(SOURCE_LOGO, output, size):
            # Also save to splash directory
            (SPLASH_DIR / f"android_{drawable}_{filename}").write_bytes(output.read_bytes())
            android_count += 1

    # Create iOS splash screen (will use in LaunchScreen.storyboard)
    print("\nGenerating iOS Splash Screen...")
    ios_splash = SPLASH_DIR / "ios_splash_1024.png"
    if create_splash(SOURCE_LOGO, ios_splash, 1024):
        print(f"  ✓ iOS splash screen created: {ios_splash.name}")

    print("\n" + "="*60)
    print("✓ Splash screen generation complete!")
    print(f"  Android splash screens: {android_count}")
    print(f"  iOS splash screen: 1")
    print(f"  All splashes saved to: {SPLASH_DIR}")
    print("="*60)

if __name__ == "__main__":
    main()
