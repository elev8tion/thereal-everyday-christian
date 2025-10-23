#!/bin/bash

# App Icon Generation Script for Everyday Christian
# Generates all required icon sizes for iOS and Android

set -e

PROJECT_ROOT="/Users/kcdacre8tor/ everyday-christian"
SOURCE_LOGO="$PROJECT_ROOT/assets/images/logo_playstore.png"
ICONS_DIR="$PROJECT_ROOT/app_store_assets/icons"
IOS_ICONS="$PROJECT_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_RES="$PROJECT_ROOT/android/app/src/main/res"

# Create directories
mkdir -p "$ICONS_DIR"
mkdir -p "$IOS_ICONS"
mkdir -p "$ANDROID_RES/mipmap-mdpi"
mkdir -p "$ANDROID_RES/mipmap-hdpi"
mkdir -p "$ANDROID_RES/mipmap-xhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxxhdpi"

echo "Generating iOS App Icons..."

# iOS Icon Sizes (iPhone & iPad)
declare -A ios_sizes=(
    ["20"]="Icon-20.png"
    ["29"]="Icon-29.png"
    ["40"]="Icon-40.png"
    ["58"]="Icon-58.png"
    ["60"]="Icon-60.png"
    ["76"]="Icon-76.png"
    ["80"]="Icon-80.png"
    ["87"]="Icon-87.png"
    ["120"]="Icon-120.png"
    ["152"]="Icon-152.png"
    ["167"]="Icon-167.png"
    ["180"]="Icon-180.png"
    ["1024"]="Icon-1024.png"
)

for size in "${!ios_sizes[@]}"; do
    output="${ios_sizes[$size]}"
    echo "  Creating iOS icon: ${size}x${size} -> $output"
    sips -z "$size" "$size" "$SOURCE_LOGO" --out "$IOS_ICONS/$output" > /dev/null 2>&1
    cp "$IOS_ICONS/$output" "$ICONS_DIR/ios_$output"
done

echo "Generating Android App Icons..."

# Android Icon Sizes
declare -A android_sizes=(
    ["48"]="mipmap-mdpi"
    ["72"]="mipmap-hdpi"
    ["96"]="mipmap-xhdpi"
    ["144"]="mipmap-xxhdpi"
    ["192"]="mipmap-xxxhdpi"
)

for size in "${!android_sizes[@]}"; do
    density="${android_sizes[$size]}"
    echo "  Creating Android icon: ${size}x${size} -> $density"
    sips -z "$size" "$size" "$SOURCE_LOGO" --out "$ANDROID_RES/$density/ic_launcher.png" > /dev/null 2>&1
    cp "$ANDROID_RES/$density/ic_launcher.png" "$ICONS_DIR/android_${density}_ic_launcher.png"
done

# Generate Play Store icon (512x512)
echo "Generating Play Store icon (512x512)..."
sips -z 512 512 "$SOURCE_LOGO" --out "$ICONS_DIR/playstore_icon_512.png" > /dev/null 2>&1

# Generate App Store icon (1024x1024) - already done above but ensure it's in icons dir
echo "App Store icon (1024x1024) created"

echo ""
echo "✓ Icon generation complete!"
echo "  iOS icons: $IOS_ICONS"
echo "  Android icons: $ANDROID_RES"
echo "  All icons saved to: $ICONS_DIR"
echo ""
echo "Total icons generated: $((${#ios_sizes[@]} + ${#android_sizes[@]} + 1))"
