#!/usr/bin/env python3
"""
Generate app icons matching the FAB button design from glassmorphic_fab_menu.dart
"""

from PIL import Image, ImageDraw, ImageFilter
import os

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_gradient(width, height, color1, color2):
    """Create a diagonal gradient from top-left to bottom-right"""
    base = Image.new('RGBA', (width, height), color1)
    top = Image.new('RGBA', (width, height), color2)

    mask = Image.new('L', (width, height))
    mask_draw = ImageDraw.Draw(mask)

    for y in range(height):
        for x in range(width):
            # Diagonal gradient from top-left to bottom-right
            distance = ((x / width) + (y / height)) / 2
            mask.putpixel((x, y), int(255 * distance))

    base.paste(top, (0, 0), mask)
    return base

def create_fab_icon(size):
    """Create an app icon matching the FAB button design with app gradient background"""

    # Colors from AppTheme
    gold_color = hex_to_rgb('#D4AF37')  # goldColor

    # App background gradient colors (from AppGradients.backgroundDark)
    navy_color = hex_to_rgb('#1A1A2E')  # Dark navy
    deep_blue = hex_to_rgb('#16213E')   # Deep blue
    dark_purple = hex_to_rgb('#0F3460') # Dark purple

    # Create base image with app gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    # Create vertical gradient background (navy → deep blue → dark purple)
    # This matches the app's main background
    gradient = Image.new('RGB', (size, size))
    for y in range(size):
        # Create 3-color vertical gradient
        if y < size // 2:
            # First half: navy to deep blue
            ratio = y / (size // 2)
            r = int(navy_color[0] + (deep_blue[0] - navy_color[0]) * ratio)
            g = int(navy_color[1] + (deep_blue[1] - navy_color[1]) * ratio)
            b = int(navy_color[2] + (deep_blue[2] - navy_color[2]) * ratio)
        else:
            # Second half: deep blue to dark purple
            ratio = (y - size // 2) / (size // 2)
            r = int(deep_blue[0] + (dark_purple[0] - deep_blue[0]) * ratio)
            g = int(deep_blue[1] + (dark_purple[1] - deep_blue[1]) * ratio)
            b = int(deep_blue[2] + (dark_purple[2] - deep_blue[2]) * ratio)

        for x in range(size):
            gradient.putpixel((x, y), (r, g, b))

    # Apply rounded corners (Apple automatically applies rounded corners, but we'll keep them)
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.225)  # iOS standard is ~22.5% radius
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)

    # Create background with app gradient (fully opaque - Apple requirement)
    background = gradient.convert('RGBA')

    # Add border (gold with 60% opacity)
    border_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_img)
    border_width = max(2, int(size * 0.02))  # 2% border width
    border_color = gold_color + (int(255 * 0.6),)

    # Draw border
    border_draw.rounded_rectangle(
        [(border_width//2, border_width//2), (size - border_width//2, size - border_width//2)],
        corner_radius,
        outline=border_color,
        width=border_width
    )

    # Composite border
    background = Image.alpha_composite(background, border_img)

    # Load and resize logo_cropped.png (centered, 80% of icon size)
    try:
        logo = Image.open('assets/images/logo_cropped.png').convert('RGBA')
        logo_size = int(size * 0.8)
        logo = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)

        # Center the logo
        logo_pos = ((size - logo_size) // 2, (size - logo_size) // 2)
        background.paste(logo, logo_pos, logo)
    except Exception as e:
        print(f"Warning: Could not load logo: {e}")

    return background

def main():
    """Generate all required iOS icon sizes"""

    # iOS icon sizes (from AppIcon.appiconset)
    sizes = [
        (1024, 'Icon-1024.png'),      # App Store
        (180, 'Icon-180.png'),        # iPhone 3x
        (167, 'Icon-167.png'),        # iPad Pro
        (152, 'Icon-152.png'),        # iPad 2x
        (120, 'Icon-120.png'),        # iPhone 2x
        (87, 'Icon-87.png'),          # iPhone 3x Settings
        (80, 'Icon-80.png'),          # iPhone/iPad 2x Settings
        (76, 'Icon-76.png'),          # iPad
        (60, 'Icon-60.png'),          # iPhone
        (58, 'Icon-58.png'),          # iPhone/iPad Settings
        (40, 'Icon-40.png'),          # Spotlight
        (29, 'Icon-29.png'),          # Settings
        (20, 'Icon-20.png'),          # Notification
    ]

    output_dir = 'app_store_assets/icons_new'
    os.makedirs(output_dir, exist_ok=True)

    print("Generating FAB-style app icons...")

    for size, filename in sizes:
        print(f"  Creating {filename} ({size}x{size})...")
        icon = create_fab_icon(size)
        icon.save(os.path.join(output_dir, filename))

    print(f"\n✅ All icons generated in {output_dir}/")
    print("\nNext steps:")
    print("1. Review the generated icons")
    print("2. Copy them to ios/Runner/Assets.xcassets/AppIcon.appiconset/")
    print("3. Update Contents.json if needed")

if __name__ == '__main__':
    main()
