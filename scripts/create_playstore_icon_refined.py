#!/usr/bin/env python3
"""
Create a refined 512x512 Play Store icon for Everyday Christian app
Matches the TestFlight version more closely
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import os

def create_refined_playstore_icon():
    # Create a 512x512 image with RGBA
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Define colors - matching the original more closely
    purple_top = (147, 112, 219)  # Medium purple
    blue_bottom = (100, 149, 237)  # Cornflower blue
    gold = (255, 215, 0)  # Pure gold
    white = (255, 255, 255)
    light_gold = (255, 233, 150)  # Lighter gold for accents

    # Create smoother gradient background
    for y in range(size):
        # Non-linear interpolation for smoother gradient
        ratio = (y / size) ** 1.2  # Power curve for smoother transition
        r = int(purple_top[0] * (1 - ratio) + blue_bottom[0] * ratio)
        g = int(purple_top[1] * (1 - ratio) + blue_bottom[1] * ratio)
        b = int(purple_top[2] * (1 - ratio) + blue_bottom[2] * ratio)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b))

    # Draw rounded rectangle border (golden) with better proportions
    border_width = 6
    corner_radius = 90  # More rounded corners

    # Draw golden border
    draw.rounded_rectangle(
        [(border_width, border_width), (size-border_width, size-border_width)],
        radius=corner_radius,
        outline=gold,
        width=border_width
    )

    # Add inner border for depth
    draw.rounded_rectangle(
        [(border_width+2, border_width+2), (size-border_width-2, size-border_width-2)],
        radius=corner_radius-2,
        outline=light_gold,
        width=2
    )

    # Draw improved sunrise/sun icon
    sun_center_x = size // 2
    sun_center_y = 130
    sun_radius = 30

    # Draw sun rays with varying lengths
    num_rays = 20
    for i in range(num_rays):
        angle = i * 180 / num_rays  # Only upper semicircle
        angle_rad = angle * math.pi / 180

        # Varying ray lengths for more dynamic look
        ray_length = 25 if i % 2 == 0 else 18
        inner_radius = sun_radius + 8
        outer_radius = sun_radius + ray_length + 8

        x1 = sun_center_x + inner_radius * math.cos(angle_rad)
        y1 = sun_center_y - inner_radius * math.sin(angle_rad)
        x2 = sun_center_x + outer_radius * math.cos(angle_rad)
        y2 = sun_center_y - outer_radius * math.sin(angle_rad)

        width = 3 if i % 2 == 0 else 2
        draw.line([(x1, y1), (x2, y2)], fill=light_gold, width=width)

    # Draw semi-circle for sun
    draw.pieslice(
        [(sun_center_x - sun_radius, sun_center_y - sun_radius),
         (sun_center_x + sun_radius, sun_center_y)],
        start=180, end=360,
        fill=gold
    )

    # Draw inner sun rays for depth
    for i in range(12):
        angle = 180 + (i * 180 / 12)
        angle_rad = angle * math.pi / 180
        x = sun_center_x + (sun_radius - 3) * math.cos(angle_rad)
        y = sun_center_y + (sun_radius - 3) * math.sin(angle_rad)
        draw.line([(sun_center_x, sun_center_y), (x, y)], fill=light_gold, width=1)

    # Draw horizon lines
    horizon_y = sun_center_y
    line_length = 85
    # Left horizon line
    draw.line([(sun_center_x - sun_radius - 50, horizon_y),
               (sun_center_x - sun_radius - 50 - line_length, horizon_y)],
              fill=gold, width=3)
    # Right horizon line
    draw.line([(sun_center_x + sun_radius + 50, horizon_y),
               (sun_center_x + sun_radius + 50 + line_length, horizon_y)],
              fill=gold, width=3)

    # Try to use better fonts
    try:
        # macOS fonts
        font_thin = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 42)
        font_bold = ImageFont.truetype("/System/Library/Fonts/HelveticaNeue.ttc", 68)
    except:
        try:
            # Linux fonts
            font_thin = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf", 42)
            font_bold = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf", 68)
        except:
            # Fallback
            font_thin = ImageFont.load_default()
            font_bold = ImageFont.load_default()

    # Draw "EVERYDAY" text with better spacing
    text1 = "EVERYDAY"
    bbox1 = draw.textbbox((0, 0), text1, font=font_thin)
    text1_width = bbox1[2] - bbox1[0]
    text1_height = bbox1[3] - bbox1[1]
    text1_x = (size - text1_width) // 2
    text1_y = 195

    # Draw decorative lines around EVERYDAY
    line_y = text1_y + text1_height // 2
    line_gap = 20
    line_length = 60

    # Left line
    draw.line([(text1_x - line_gap - line_length, line_y),
               (text1_x - line_gap, line_y)],
              fill=white, width=2)
    # Right line
    draw.line([(text1_x + text1_width + line_gap, line_y),
               (text1_x + text1_width + line_gap + line_length, line_y)],
              fill=white, width=2)

    # Draw the text with slight shadow for depth
    shadow_offset = 2
    draw.text((text1_x + shadow_offset, text1_y + shadow_offset), text1,
              fill=(0, 0, 0, 80), font=font_thin)
    draw.text((text1_x, text1_y), text1, fill=white, font=font_thin)

    # Draw "CHRISTIAN" text (bolder and larger)
    text2 = "CHRISTIAN"
    bbox2 = draw.textbbox((0, 0), text2, font=font_bold)
    text2_width = bbox2[2] - bbox2[0]
    text2_x = (size - text2_width) // 2
    text2_y = 250

    # Shadow for CHRISTIAN
    draw.text((text2_x + shadow_offset, text2_y + shadow_offset), text2,
              fill=(0, 0, 0, 80), font=font_bold)
    draw.text((text2_x, text2_y), text2, fill=white, font=font_bold)

    # Draw improved open book icon
    book_center_x = size // 2
    book_y = 365
    book_width = 90
    book_height = 50
    perspective = 15

    # Create book with perspective effect
    # Left page
    left_page = [
        (book_center_x - book_width//2, book_y + perspective),
        (book_center_x - 3, book_y),
        (book_center_x - 3, book_y + book_height),
        (book_center_x - book_width//2, book_y + book_height + perspective)
    ]

    # Fill left page
    draw.polygon(left_page, fill=None, outline=light_gold, width=3)

    # Right page
    right_page = [
        (book_center_x + book_width//2, book_y + perspective),
        (book_center_x + 3, book_y),
        (book_center_x + 3, book_y + book_height),
        (book_center_x + book_width//2, book_y + book_height + perspective)
    ]

    # Fill right page
    draw.polygon(right_page, fill=None, outline=light_gold, width=3)

    # Book spine
    draw.line([(book_center_x, book_y), (book_center_x, book_y + book_height)],
              fill=gold, width=4)

    # Add page lines for detail
    for i in range(3):
        y_offset = book_y + 12 + (i * 10)
        # Left page lines
        draw.line([(book_center_x - book_width//2 + 10, y_offset + perspective//2),
                   (book_center_x - 10, y_offset)],
                  fill=(255, 255, 255, 100), width=1)
        # Right page lines
        draw.line([(book_center_x + 10, y_offset),
                   (book_center_x + book_width//2 - 10, y_offset + perspective//2)],
                  fill=(255, 255, 255, 100), width=1)

    # Add subtle vignette effect
    vignette = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    vignette_draw = ImageDraw.Draw(vignette)

    # Create radial gradient for vignette
    center_x, center_y = size // 2, size // 2
    max_radius = math.sqrt((size/2)**2 + (size/2)**2)

    for radius in range(int(max_radius), 0, -5):
        alpha = int(255 * (1 - (radius / max_radius) ** 2) * 0.2)
        vignette_draw.ellipse(
            [(center_x - radius, center_y - radius),
             (center_x + radius, center_y + radius)],
            fill=(0, 0, 0, alpha)
        )

    # Composite vignette with very low opacity
    vignette = vignette.filter(ImageFilter.GaussianBlur(radius=50))
    img = Image.alpha_composite(img, vignette)

    return img

if __name__ == "__main__":
    print("Creating refined Play Store icon...")
    icon = create_refined_playstore_icon()

    # Save the refined icon
    output_path = "playstore_icon_512_final.png"
    icon.save(output_path, "PNG", quality=100, optimize=True)
    print(f"Refined icon saved as {output_path}")

    # Replace the one in app_store_assets
    if os.path.exists("app_store_assets/icons"):
        asset_path = "app_store_assets/icons/playstore_icon_512.png"
        # Backup the old one first
        if os.path.exists(asset_path):
            backup_path = asset_path.replace('.png', '_backup.png')
            os.rename(asset_path, backup_path)
            print(f"Backed up old icon to {backup_path}")
        icon.save(asset_path, "PNG", quality=100, optimize=True)
        print(f"Saved final version as {asset_path}")