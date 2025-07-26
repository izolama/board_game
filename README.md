# Flutter Board Game Adventure

Game board berbasis Flutter dengan Flame Engine yang menggabungkan mekanik fog of war, sistem energi, dan jalur bercabang dengan gaya pixel art seperti Harvest Moon/Stardew Valley.

## 🎮 Fitur Game

### ✅ Fitur yang Sudah Diimplementasi (Point 1-5)

#### 1. Struktur Project Flutter
- ✅ Struktur folder yang terorganisir
- ✅ pubspec.yaml dengan dependencies yang tepat
- ✅ Asset management untuk images dan audio
- ✅ Konfigurasi desktop Flutter

#### 2. Game Screens & UI
- ✅ Menu Screen dengan desain pixel art style
- ✅ Game Screen dengan overlay UI
- ✅ Finish Screen dengan statistik game
- ✅ Navigation system antar screens

#### 3. Core Game Engine (my_game.dart)
- ✅ Flame Game class sebagai inti game loop
- ✅ Game state management (start, playing, finished)
- ✅ Keyboard input handling (SPACE untuk plant, ENTER untuk roll dice)
- ✅ UI components (energy bar, position, instructions)
- ✅ Game timer dan step counter

#### 4. Player Component
- ✅ Player character dengan animasi
- ✅ Smooth movement dengan effects
- ✅ Energy bar visual di atas player
- ✅ Visual feedback untuk actions (plant seed, damage, energy gain)
- ✅ Particle effects untuk seed planting
- ✅ Walking animation dan idle states

#### 5. Board & Tile System
- ✅ Dynamic grid-based board (50 tiles)
- ✅ Snake pattern layout (seperti ular tangga)
- ✅ Multiple tile types:
    - 🏠 Start tile
    - 🌿 Normal tiles
    - 💥 Obstacle tiles (mengurangi energy)
    - ⭐ Bonus tiles (menambah energy)
    - 🔀 Branch tiles (pilihan jalur)
    - 🏁 Finish tile
- ✅ Tile visibility system
- ✅ Path connections visualization
- ✅ Tile effects dan particle systems

#### 6. Dice System
- ✅ Visual dice dengan dots (1-6)
- ✅ Rolling animation dengan rotation dan scale
- ✅ Dice UI component
- ✅ Random number generation
- ✅ Visual feedback saat rolling

#### 7. Energy System
- ✅ Plant seed mechanism (SPACE key)
- ✅ Energy requirement untuk roll dice (100% energy)
- ✅ Energy consumption setelah roll
- ✅ Cooldown system untuk seed planting
- ✅ Visual energy bar dan status
- ✅ Bonus/penalty energy dari tiles

#### 8. Fog of War System
- ✅ Tile visibility management
- ✅ Progressive revelation saat player bergerak
- ✅ Explored tiles tracking
- ✅ Visibility range configuration
- ✅ Special abilities (scout ahead, illuminate area)
- ✅ Fog opacity animations

#### 9. Path System (Branching)
- ✅ Branch detection pada tiles
- ✅ Path selection UI dengan buttons
- ✅ Direction indicators (Left, Right, Forward)
- ✅ Path preview dan highlighting
- ✅ Smooth path selection experience
- ✅ Path validation system

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter 3.24.3 atau lebih baru
- Dart SDK
- Desktop development setup (Windows/macOS/Linux)

### Instalasi
```bash
# Clone atau download project
cd flutter_board_game

# Install dependencies
flutter pub get

# Run pada desktop
flutter run -d windows  # untuk Windows
flutter run -d macos    # untuk macOS  
flutter run -d linux    # untuk Linux
```

### Controls
- **SPACE**: Plant seed (mengisi energy)
- **ENTER**: Roll dice (jika energy penuh)
- **Mouse**: Pilih jalur saat branching
- **ESC**: Kembali ke menu (akan diimplementasi)

## 🎨 Style Guide

Game menggunakan pixel art style dengan inspirasi dari Harvest Moon/Stardew Valley:
- Warna cerah dan hangat
- Karakter chibi/cute
- Tile-based graphics
- Smooth animations
- Particle effects untuk feedback

## 📋 Roadmap Pengembangan Lanjut (Point 6)

### 🔊 Audio System
- [ ] Background music dengan loop
- [ ] Sound effects untuk:
    - Dice rolling
    - Seed planting
    - Tile effects (obstacle, bonus)
    - Movement sounds
    - UI interactions
- [ ] Volume controls
- [ ] Audio settings menu

### 🎲 Enhanced Dice Animation
- [ ] 3D dice rolling effect
- [ ] Multiple dice skins/themes
- [ ] Dice trail effects
- [ ] Custom dice faces
- [ ] Dice physics simulation

### 💾 Save/Load System
- [ ] Game progress saving
- [ ] Multiple save slots
- [ ] Auto-save functionality
- [ ] Statistics tracking
- [ ] Achievement system
- [ ] Leaderboards

### 🗺️ Advanced Level System
- [ ] Procedural map generation
- [ ] Multiple difficulty levels
- [ ] Different board themes:
    - Forest theme
    - Desert theme
    - Snow theme
    - Cave theme
- [ ] Dynamic weather effects
- [ ] Day/night cycle

### 🎨 Enhanced Graphics
- [ ] Sprite sheets untuk animations
- [ ] Parallax background
- [ ] Weather particles (rain, snow)
- [ ] Lighting effects
- [ ] Shadow system
- [ ] Screen shake effects

### 🎮 Gameplay Enhancements
- [ ] Power-ups dan special abilities
- [ ] Multiple characters dengan stats berbeda
- [ ] Inventory system
- [ ] Crafting system
- [ ] Quest system
- [ ] Mini-games di tiles tertentu

### 🌐 Multiplayer Support
- [ ] Local multiplayer (hot-seat)
- [ ] Online multiplayer
- [ ] Real-time synchronization
- [ ] Chat system
- [ ] Spectator mode

### 📱 Platform Expansion
- [ ] Mobile adaptation (Android/iOS)
- [ ] Touch controls
- [ ] Responsive UI
- [ ] Platform-specific optimizations

### 🏆 Achievement System
- [ ] Progress tracking
- [ ] Unlock conditions
- [ ] Achievement notifications
- [ ] Reward system
- [ ] Statistics dashboard

### ⚙️ Settings & Customization
- [ ] Graphics quality settings
- [ ] Control customization
- [ ] Accessibility options
- [ ] Language localization
- [ ] Theme customization

## 🛠️ Technical Architecture

### Core Components
- **MyGame**: Main game loop dan state management
- **Player**: Character logic dan animations
- **Board**: Grid management dan tile positioning
- **GameTile**: Individual tile behavior dan effects
- **Dice**: Rolling mechanics dan visual feedback

### Systems
- **EnergySystem**: Energy management dan seed planting
- **FogOfWar**: Visibility dan exploration mechanics
- **PathSystem**: Branching paths dan player choices

### Screens
- **MenuScreen**: Main menu dengan instructions
- **GameScreen**: Gameplay dengan UI overlay
- **FinishScreen**: Victory screen dengan statistics

## 🐛 Known Issues & TODO

### Bugs to Fix
- [ ] Player movement collision detection
- [ ] Tile highlight cleanup
- [ ] Memory optimization untuk effects
- [ ] Performance optimization untuk large boards

### Improvements
- [ ] Better error handling
- [ ] Code documentation
- [ ] Unit tests
- [ ] Integration tests
- [ ] Performance profiling

## 📄 License

This project is for educational purposes. Feel free to use and modify.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

**Dibuat dengan ❤️ menggunakan Flutter & Flame Engine**
