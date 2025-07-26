# Assets Directory

Folder ini berisi semua asset visual untuk game Board Game Adventure.

## Struktur Folder

### /tiles/
Berisi sprite untuk berbagai jenis tile:
- `tile_start.png` - Tile start (rumah)
- `tile_normal.png` - Tile normal (rumput)
- `tile_obstacle.png` - Tile obstacle (batu/rintangan)
- `tile_bonus.png` - Tile bonus (bintang/hadiah)
- `tile_branch.png` - Tile percabangan
- `tile_finish.png` - Tile finish (bendera)

### /characters/
Berisi sprite untuk karakter player:
- `player_idle.png` - Player dalam posisi diam
- `player_walk_1.png` - Frame 1 animasi berjalan
- `player_walk_2.png` - Frame 2 animasi berjalan
- `player_walk_3.png` - Frame 3 animasi berjalan
- `player_walk_4.png` - Frame 4 animasi berjalan

### /ui/
Berisi elemen UI:
- `dice_1.png` sampai `dice_6.png` - Sprite dadu
- `energy_bar_bg.png` - Background energy bar
- `energy_bar_fill.png` - Fill energy bar
- `button_bg.png` - Background tombol
- `panel_bg.png` - Background panel UI

## Spesifikasi Asset

### Ukuran Tile
- Ukuran: 40x40 pixels
- Format: PNG dengan transparency
- Style: Pixel art dengan outline hitam

### Ukuran Character
- Ukuran: 32x32 pixels
- Format: PNG dengan transparency
- Style: Chibi/cute pixel art

### Ukuran UI Elements
- Dice: 60x60 pixels
- Buttons: Variable, minimum 100x40 pixels
- Panels: Variable sesuai kebutuhan

## Style Guide

### Warna Palette
- Hijau: #4CAF50 (primary)
- Biru: #2196F3 (secondary)
- Merah: #F44336 (danger/obstacle)
- Kuning: #FFD700 (bonus/finish)
- Ungu: #9C27B0 (branch)
- Hijau Muda: #8FBC8F (normal tiles)

### Art Style
- Pixel art dengan resolusi rendah
- Outline hitam 1-2 pixel
- Warna cerah dan kontras tinggi
- Inspirasi dari Harvest Moon/Stardew Valley
- Konsisten dengan grid 8x8 atau 16x16

## Cara Menambah Asset

1. Buat sprite sesuai spesifikasi di atas
2. Simpan dalam folder yang sesuai
3. Update pubspec.yaml jika perlu
4. Gunakan dalam kode dengan `Sprite.load('path/to/asset.png')`

## Tools Rekomendasi

- **Aseprite** - Untuk pixel art animation
- **GIMP** - Free alternative
- **Photoshop** - Dengan pixel art plugins
- **Piskel** - Online pixel art editor

## Placeholder Assets

Saat ini game menggunakan generated sprites (kotak warna) sebagai placeholder. 
Untuk production, ganti dengan asset pixel art yang sesuai style guide.
