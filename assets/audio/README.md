# Audio Assets Directory

Folder ini berisi semua asset audio untuk game Board Game Adventure.

## Struktur Audio

### Background Music
- `menu_theme.ogg` - Musik tema untuk menu utama
- `gameplay_theme.ogg` - Musik tema untuk gameplay
- `victory_theme.ogg` - Musik kemenangan

### Sound Effects

#### Player Actions
- `seed_plant.wav` - Suara menanam bibit
- `footstep_1.wav` - Suara langkah kaki 1
- `footstep_2.wav` - Suara langkah kaki 2
- `energy_gain.wav` - Suara mendapat energi
- `energy_full.wav` - Suara energi penuh

#### Dice Sounds
- `dice_roll.wav` - Suara dadu berputar
- `dice_land.wav` - Suara dadu mendarat

#### Tile Effects
- `tile_normal.wav` - Suara menginjak tile normal
- `tile_obstacle.wav` - Suara terkena obstacle
- `tile_bonus.wav` - Suara mendapat bonus
- `tile_branch.wav` - Suara mencapai percabangan
- `tile_finish.wav` - Suara mencapai finish

#### UI Sounds
- `button_hover.wav` - Suara hover tombol
- `button_click.wav` - Suara klik tombol
- `menu_select.wav` - Suara pilih menu
- `notification.wav` - Suara notifikasi

## Spesifikasi Audio

### Format File
- **Music**: OGG Vorbis (untuk kompresi yang baik)
- **SFX**: WAV (untuk kualitas dan loading cepat)

### Kualitas Audio
- **Sample Rate**: 44.1 kHz
- **Bit Depth**: 16-bit
- **Channels**: Stereo untuk musik, Mono untuk SFX

### Volume Guidelines
- **Music**: -12dB to -18dB (background level)
- **SFX**: -6dB to -12dB (prominent but not overwhelming)
- **UI Sounds**: -18dB to -24dB (subtle feedback)

## Style Guide Audio

### Music Style
- **Genre**: Chiptune/8-bit inspired
- **Tempo**: Medium (120-140 BPM)
- **Mood**: Cheerful, adventurous, relaxing
- **Instruments**: Synthesized sounds, simple melodies
- **Loop**: Seamless looping untuk background music

### Sound Effects Style
- **Style**: Retro/pixel game sounds
- **Duration**: Short (0.1-2 seconds)
- **Processing**: Light reverb, no heavy effects
- **Consistency**: Cohesive sound palette

## Implementation dalam Flutter

```dart
// Contoh penggunaan audio
import 'package:flame_audio/flame_audio.dart';

// Play background music
FlameAudio.bgm.play('gameplay_theme.ogg');

// Play sound effect
FlameAudio.play('dice_roll.wav');

// Stop music
FlameAudio.bgm.stop();
```

## Audio Dependencies

Tambahkan ke pubspec.yaml:
```yaml
dependencies:
  flame_audio: ^2.0.0
  audioplayers: ^5.0.0
```

## Tools Rekomendasi

### Music Creation
- **FamiTracker** - Chiptune music creation
- **LMMS** - Free DAW dengan retro synths
- **Audacity** - Audio editing dan processing
- **Reaper** - Professional DAW

### Sound Effects
- **Bfxr** - Retro sound effect generator
- **Audacity** - Recording dan editing
- **Freesound.org** - Free sound library
- **Zapsplat** - Professional sound library

## Placeholder Audio

Saat ini game belum mengimplementasikan audio. Untuk implementasi:

1. Tambah flame_audio dependency
2. Load audio files dalam game initialization
3. Trigger sounds pada events yang sesuai
4. Implement volume controls
5. Add audio settings menu

## Audio Events Mapping

| Game Event | Audio File | Volume | Priority |
|------------|------------|---------|----------|
| Menu Load | menu_theme.ogg | -15dB | Low |
| Game Start | gameplay_theme.ogg | -15dB | Low |
| Plant Seed | seed_plant.wav | -10dB | Medium |
| Roll Dice | dice_roll.wav | -8dB | High |
| Move Player | footstep_1.wav | -12dB | Medium |
| Hit Obstacle | tile_obstacle.wav | -6dB | High |
| Get Bonus | tile_bonus.wav | -8dB | High |
| Reach Finish | victory_theme.ogg | -12dB | High |

## Performance Considerations

- Preload frequently used sounds
- Use audio pools untuk repeated sounds
- Implement audio streaming untuk music
- Add audio quality settings
- Optimize file sizes untuk mobile
