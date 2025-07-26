#!/usr/bin/env python3
"""
Asset Generator untuk Flutter Board Game Adventure
Membuat pixel art assets sesuai spesifikasi di README.md
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Konfigurasi warna sesuai style guide
COLORS = {
    'primary_green': (76, 175, 80),      # #4CAF50
    'secondary_blue': (33, 150, 243),    # #2196F3
    'danger_red': (244, 67, 54),         # #F44336
    'bonus_gold': (255, 215, 0),         # #FFD700
    'branch_purple': (156, 39, 176),     # #9C27B0
    'normal_light_green': (143, 188, 143), # #8FBC8F
    'black': (0, 0, 0),
    'white': (255, 255, 255),
    'dark_green': (46, 125, 50),         # #2E7D32
    'brown': (139, 69, 19),
    'sky_blue': (135, 206, 235),
}

def create_tile_sprite(size, bg_color, icon_char, filename):
    """Membuat sprite tile dengan icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background dengan rounded corners
    margin = 2
    draw.rounded_rectangle(
        [margin, margin, size-margin, size-margin], 
        radius=4, 
        fill=bg_color, 
        outline=COLORS['black'], 
        width=2
    )
    
    # Icon di tengah
    try:
        # Coba gunakan font default
        font_size = size // 3
        font = ImageFont.load_default()
        
        # Hitung posisi tengah untuk text
        bbox = draw.textbbox((0, 0), icon_char, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (size - text_width) // 2
        y = (size - text_height) // 2 - 2
        
        # Draw text dengan outline
        for dx in [-1, 0, 1]:
            for dy in [-1, 0, 1]:
                if dx != 0 or dy != 0:
                    draw.text((x+dx, y+dy), icon_char, font=font, fill=COLORS['black'])
        draw.text((x, y), icon_char, font=font, fill=COLORS['white'])
        
    except:
        # Fallback: gambar shape sederhana
        center = size // 2
        if icon_char == '🏠':  # Start - house shape
            points = [(center, 8), (8, center), (center, center), (size-8, center)]
            draw.polygon(points, fill=COLORS['white'], outline=COLORS['black'])
        elif icon_char == '🏁':  # Finish - flag shape
            draw.rectangle([center-8, 8, center+8, size-8], fill=COLORS['white'], outline=COLORS['black'])
        elif icon_char == '💥':  # Obstacle - X shape
            draw.line([8, 8, size-8, size-8], fill=COLORS['white'], width=3)
            draw.line([8, size-8, size-8, 8], fill=COLORS['white'], width=3)
        elif icon_char == '⭐':  # Bonus - star shape
            draw.regular_polygon((center, center, 8), 5, fill=COLORS['white'], outline=COLORS['black'])
        elif icon_char == '🔀':  # Branch - arrows
            draw.line([8, center, size-8, center], fill=COLORS['white'], width=2)
            draw.line([center, 8, center, size-8], fill=COLORS['white'], width=2)
        else:  # Normal - dot
            draw.ellipse([center-4, center-4, center+4, center+4], fill=COLORS['white'], outline=COLORS['black'])
    
    img.save(filename)
    print(f"Created: {filename}")

def create_character_sprite(size, filename, frame=0):
    """Membuat sprite karakter dengan animasi"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    
    # Body (green rectangle)
    body_width = size - 8
    body_height = size - 8
    body_x = (size - body_width) // 2
    body_y = (size - body_height) // 2
    
    draw.rounded_rectangle(
        [body_x, body_y, body_x + body_width, body_y + body_height],
        radius=4,
        fill=COLORS['primary_green'],
        outline=COLORS['black'],
        width=1
    )
    
    # Face (eyes and smile)
    eye_y = body_y + 6
    # Eyes
    draw.ellipse([body_x + 6, eye_y, body_x + 8, eye_y + 2], fill=COLORS['black'])
    draw.ellipse([body_x + body_width - 8, eye_y, body_x + body_width - 6, eye_y + 2], fill=COLORS['black'])
    
    # Smile
    smile_y = eye_y + 6
    smile_points = [
        (body_x + 6, smile_y),
        (center, smile_y + 4),
        (body_x + body_width - 6, smile_y)
    ]
    for i in range(len(smile_points) - 1):
        draw.line([smile_points[i], smile_points[i+1]], fill=COLORS['black'], width=1)
    
    # Walking animation offset
    if frame % 2 == 1:
        # Slight vertical offset for walking
        pass
    
    img.save(filename)
    print(f"Created: {filename}")

def create_dice_sprite(size, number, filename):
    """Membuat sprite dadu dengan angka"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Dice background
    margin = 4
    draw.rounded_rectangle(
        [margin, margin, size-margin, size-margin],
        radius=8,
        fill=COLORS['white'],
        outline=COLORS['black'],
        width=2
    )
    
    # Dots based on number
    dot_radius = 3
    positions = {
        1: [(size//2, size//2)],
        2: [(size//3, size//3), (2*size//3, 2*size//3)],
        3: [(size//4, size//4), (size//2, size//2), (3*size//4, 3*size//4)],
        4: [(size//3, size//3), (2*size//3, size//3), (size//3, 2*size//3), (2*size//3, 2*size//3)],
        5: [(size//4, size//4), (3*size//4, size//4), (size//2, size//2), (size//4, 3*size//4), (3*size//4, 3*size//4)],
        6: [(size//3, size//4), (2*size//3, size//4), (size//3, size//2), (2*size//3, size//2), (size//3, 3*size//4), (2*size//3, 3*size//4)]
    }
    
    for pos in positions.get(number, []):
        draw.ellipse([pos[0]-dot_radius, pos[1]-dot_radius, pos[0]+dot_radius, pos[1]+dot_radius], 
                    fill=COLORS['black'])
    
    img.save(filename)
    print(f"Created: {filename}")

def create_ui_elements():
    """Membuat elemen UI"""
    # Energy bar background
    img = Image.new('RGBA', (100, 10), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, 100, 10], radius=5, fill=(128, 128, 128), outline=COLORS['black'])
    img.save('flutter_board_game/assets/images/ui/energy_bar_bg.png')
    
    # Energy bar fill
    img = Image.new('RGBA', (100, 10), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, 100, 10], radius=5, fill=COLORS['primary_green'])
    img.save('flutter_board_game/assets/images/ui/energy_bar_fill.png')
    
    # Button background
    img = Image.new('RGBA', (100, 40), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, 100, 40], radius=20, fill=COLORS['secondary_blue'], outline=COLORS['black'], width=2)
    img.save('flutter_board_game/assets/images/ui/button_bg.png')
    
    print("Created UI elements")

def main():
    """Generate semua assets"""
    print("Generating pixel art assets...")
    
    # Buat direktori jika belum ada
    os.makedirs('flutter_board_game/assets/images/tiles', exist_ok=True)
    os.makedirs('flutter_board_game/assets/images/characters', exist_ok=True)
    os.makedirs('flutter_board_game/assets/images/ui', exist_ok=True)
    
    # Generate tiles (40x40)
    tile_configs = [
        ('tile_start.png', COLORS['primary_green'], '🏠'),
        ('tile_normal.png', COLORS['normal_light_green'], '🌿'),
        ('tile_obstacle.png', COLORS['danger_red'], '💥'),
        ('tile_bonus.png', COLORS['secondary_blue'], '⭐'),
        ('tile_branch.png', COLORS['branch_purple'], '🔀'),
        ('tile_finish.png', COLORS['bonus_gold'], '🏁'),
    ]
    
    for filename, color, icon in tile_configs:
        create_tile_sprite(40, color, icon, f'flutter_board_game/assets/images/tiles/{filename}')
    
    # Generate character sprites (32x32)
    create_character_sprite(32, 'flutter_board_game/assets/images/characters/player_idle.png', 0)
    for i in range(1, 5):
        create_character_sprite(32, f'flutter_board_game/assets/images/characters/player_walk_{i}.png', i)
    
    # Generate dice sprites (60x60)
    for i in range(1, 7):
        create_dice_sprite(60, i, f'flutter_board_game/assets/images/ui/dice_{i}.png')
    
    # Generate UI elements
    create_ui_elements()
    
    print("\n✅ Asset generation completed!")
    print("Generated assets:")
    print("- 6 tile sprites (40x40)")
    print("- 5 character sprites (32x32)")
    print("- 6 dice sprites (60x60)")
    print("- 3 UI elements")

if __name__ == "__main__":
    main()
