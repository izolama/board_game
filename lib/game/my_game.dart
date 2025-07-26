import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'components/player.dart';
import 'components/board.dart';
import 'components/tile.dart';
import 'components/dice.dart';
import 'systems/energy_system.dart';
import 'systems/fog_of_war.dart';
import 'systems/path_system.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  late Board board;
  late EnergySystem energySystem;
  late FogOfWar fogOfWar;
  late PathSystem pathSystem;
  late Dice dice;
  late DiceUI diceUI;

  // Game state
  bool isGameStarted = false;
  bool isGameFinished = false;
  DateTime? gameStartTime;
  int totalSteps = 0;

  // UI Components
  late TextComponent energyText;
  late TextComponent positionText;
  late TextComponent instructionText;

  // Dice rolling
  bool isDiceRolling = false;
  int lastDiceRoll = 0;

  // Audio state
  bool isMusicPlaying = false;
  bool soundEnabled = true; // Aktifkan audio kembali

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Initialize game systems
    energySystem = EnergySystem();
    fogOfWar = FogOfWar();
    add(fogOfWar);
    pathSystem = PathSystem();
    add(pathSystem);

    // Create board
    board = Board(gameRef: this);
    add(board);

    // Create player
    player = Player(gameRef: this);
    add(player);

    // Create dice
    dice = Dice(position: Vector2(size.x - 100, 50));
    diceUI = DiceUI();
    add(dice);
    add(diceUI);

    // Initialize UI components
    await _initializeUI();

    // Preload audio files to avoid conflicts
    await _preloadAudio();

    // Start background music
    await _startBackgroundMusic();

    // Start the game - set player position ke tile 0
    startGame();
  }

  Future<void> _preloadAudio() async {
    if (!soundEnabled) return;
    
    try {
      // Preload common audio files with retry mechanism
      List<String> audioFiles = [
        'gameplay_theme.wav',
        'seed_plant.wav',
        'energy_gain.wav',
        'energy_full.wav',
        'footstep_1.wav',
        'footstep_2.wav',
        'dice_roll.wav',
        'dice_land.wav',
        'notification.wav',
        'tile_normal.wav',
        'tile_bonus.wav',
        'tile_obstacle.wav',
        'tile_branch.wav',
        'tile_finish.wav',
        'victory_theme.wav',
      ];
      
      // Load audio files one by one with delay to avoid conflicts
      for (String audioFile in audioFiles) {
        try {
          await FlameAudio.audioCache.load(audioFile);
          await Future.delayed(Duration(milliseconds: 10)); // Small delay between loads
        } catch (e) {
          print('Could not preload $audioFile: $e');
          // Continue with other files
        }
      }
      print('Audio files preloaded successfully');
    } catch (e) {
      print('Could not preload audio files: $e');
      // Continue without audio if preloading fails
    }
  }

  Future<void> _startBackgroundMusic() async {
    if (!isMusicPlaying && soundEnabled) {
      try {
        await FlameAudio.bgm.play('gameplay_theme.wav', volume: 0.3);
        isMusicPlaying = true;
        print('Background music started successfully');
      } catch (e) {
        // Ignore audio errors - audio files might not exist
        print('Could not play background music: $e');
        isMusicPlaying = false;
      }
    }
  }

  Future<void> _stopBackgroundMusic() async {
    if (isMusicPlaying) {
      try {
        FlameAudio.bgm.stop();
        isMusicPlaying = false;
      } catch (e) {
        // Ignore audio errors
        print('Could not stop background music: $e');
      }
    }
  }

  Future<void> _initializeUI() async {
    // Energy display
    energyText = TextComponent(
      text: 'Energy: ${(player.energy * 100).toInt()}%',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
    add(energyText);

    // Position display
    positionText = TextComponent(
      text: 'Position: ${player.currentTileIndex}',
      position: Vector2(20, 45),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
    add(positionText);

    // Instruction display
    instructionText = TextComponent(
      text: 'Press SPACE to plant seed, ENTER to roll dice',
      position: Vector2(20, size.y - 30),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
    add(instructionText);
  }

  void startGame() {
    isGameStarted = true;
    gameStartTime = DateTime.now();

    // Initialize player position ke tile start (index 0)
    player.currentTileIndex = 0;
    Vector2 startPosition = board.getTilePosition(0);
    player.setPosition(startPosition);
    
    print('Player started at tile 0, position: $startPosition'); // Debug info

    // Initialize fog of war - hanya tile start yang terlihat
    fogOfWar.revealTile(0); // Tile start
    // Tile berikutnya tidak langsung terlihat, harus dilewati dulu

    updateUI();
  }

  void plantSeed() {
    if (!isGameStarted || isGameFinished) return;

    if (!energySystem.canPlantSeed()) {
      // Play error sound
      _playUISound('notification.wav');
      return;
    }

    energySystem.plantSeed(player);
    player.plantSeed(); // This will play the seed sound and show effects

    // Check if energy is full
    if (player.energy >= 1.0) {
      player.showEnergyFull();
    } else {
      player.showEnergyGain();
    }

    updateUI();

    // Visual feedback
    _showFloatingText('🌱 +Energy!', player.position, Colors.green);
  }

  bool canRollDice() {
    return isGameStarted &&
        !isGameFinished &&
        !isDiceRolling &&
        player.energy >= 1.0;
  }

  void rollDice() {
    if (!canRollDice()) {
      _playUISound('notification.wav');
      return;
    }

    isDiceRolling = true;

    // Play dice roll sound with delay
    Future.delayed(Duration(milliseconds: 25), () async {
      try {
        await _playAudioWithRetry('dice_roll.wav', 0.4);
      } catch (e) {
        print('Could not play dice roll sound: $e');
      }
    });

    // Reset energy after rolling
    player.energy = 0.0;

    // Use actual dice component
    dice.roll().then((diceValue) {
      lastDiceRoll = diceValue;
      
      // Visual feedback
      _showFloatingText(
          '🎲 $lastDiceRoll', player.position + Vector2(0, -30), Colors.blue);

      // Move player after short delay
      Future.delayed(Duration(milliseconds: 800), () {
        // Play dice land sound
        Future.delayed(Duration(milliseconds: 25), () async {
          try {
            await _playAudioWithRetry('dice_land.wav', 0.4);
          } catch (e) {
            print('Could not play dice land sound: $e');
          }
        });
        movePlayer(lastDiceRoll);
        isDiceRolling = false;
      });
    });

    updateUI();
  }

  void _playUISound(String soundFile) {
    if (!soundEnabled) return;

    // Add delay to prevent file access conflicts
    Future.delayed(Duration(milliseconds: 50), () async {
      try {
        // Try to play with retry mechanism
        await _playAudioWithRetry(soundFile, 0.4, maxRetries: 3);
      } catch (e) {
        // Ignore audio errors - sound files might not exist or be in use
        print('Could not play sound: $soundFile - $e');
      }
    });
  }

  Future<void> _playAudioWithRetry(String soundFile, double volume, {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        // Try to use cached audio first
        await FlameAudio.audioCache.load(soundFile);
        await FlameAudio.play(soundFile, volume: volume);
        return; // Success, exit retry loop
      } catch (e) {
        if (attempt < maxRetries - 1) {
          // Wait before retry
          await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
          print('Retrying audio play for $soundFile, attempt ${attempt + 1}');
        } else {
          // Last attempt failed, try direct play
          try {
            await FlameAudio.play(soundFile, volume: volume);
            return;
          } catch (finalError) {
            // Final attempt failed, rethrow
            rethrow;
          }
        }
      }
    }
  }

  void movePlayer(int steps) {
    totalSteps += steps;

    // Pindahkan player langsung ke posisi akhir sesuai nilai dadu
    int targetTileIndex = player.currentTileIndex + steps;
    
    // Pastikan tidak melebihi jumlah tile
    if (targetTileIndex >= Board.totalTiles) {
      targetTileIndex = Board.totalTiles - 1; // Berhenti di tile terakhir
    }

    // Check if reached finish
    if (targetTileIndex >= Board.totalTiles - 1) {
      finishGame();
      return;
    }

    // Update player position
    player.currentTileIndex = targetTileIndex;
    player.moveToTile(targetTileIndex);

    // Reveal tiles yang dilewati
    for (int i = player.currentTileIndex - steps + 1; i <= targetTileIndex; i++) {
      if (i >= 0 && i < Board.totalTiles) {
        fogOfWar.revealTile(i);
      }
    }

    // Handle tile effect untuk tile tujuan
    if (targetTileIndex < Board.totalTiles) {
      GameTile targetTile = board.getTile(targetTileIndex);
      _handleTileEffect(targetTile);
      
      // Check for branching paths setelah player berhenti
      if (targetTile.tileType == TileType.branch) {
        pathSystem.showBranchingOptions(this, targetTileIndex);
      }
    }

    updateUI();
  }

  void _movePlayerOneStep() {
    // Method ini tidak digunakan lagi karena player langsung pindah ke tujuan
    // Tapi tetap dipertahankan untuk kompatibilitas
  }

  void _handleTileEffect(GameTile tile) {
    // Trigger tile effect (includes sound)
    tile.triggerTileEffect();

    switch (tile.tileType) {
      case TileType.obstacle:
        // Lose some energy or skip next turn
        player.energy = max(0.0, player.energy - 0.3);
        player.showDamage();
        _showFloatingText('💥 Obstacle!', player.position, Colors.red);
        break;

      case TileType.bonus:
        // Gain energy or extra move
        player.energy = min(1.0, player.energy + 0.5);
        player.showEnergyGain();
        _showFloatingText('⭐ Bonus!', player.position, Colors.amber);
        break;

      case TileType.normal:
      case TileType.start:
      case TileType.finish:
      case TileType.branch:
        // No special effect
        break;
    }
  }

  void _showFloatingText(String text, Vector2 position, Color color) {
    final floatingText = TextComponent(
      text: text,
      position: position.clone(),
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );

    add(floatingText);

    // Animate floating text
    floatingText.add(
      MoveEffect.to(
        position + Vector2(0, -50),
        EffectController(duration: 1.0),
        onComplete: () => floatingText.removeFromParent(),
      ),
    );

    // Ganti efek fade dengan manual
    fadeText(floatingText, 1.0, 0.0, Duration(seconds: 1));
  }

  void finishGame() {
    isGameFinished = true;
    final gameTime = DateTime.now().difference(gameStartTime!);

    // Stop background music
    _stopBackgroundMusic();

    // Play victory music with delay
    Future.delayed(Duration(milliseconds: 200), () async {
      try {
        await FlameAudio.bgm.play('victory_theme.wav', volume: 0.5);
        print('Victory music started successfully');
      } catch (e) {
        // Ignore audio errors
        print('Could not play victory music: $e');
      }
    });

    _showFloatingText('🏁 Finish!', player.position, Colors.amber);

    // Navigate to finish screen after delay
    Future.delayed(Duration(seconds: 3), () {
      // This would typically navigate to finish screen
      // For now, we'll just reset the game
      resetGame();
    });
  }

  void resetGame() {
    isGameStarted = false;
    isGameFinished = false;
    gameStartTime = null;
    totalSteps = 0;
    lastDiceRoll = 0;
    isDiceRolling = false;

    // Stop any playing music
    _stopBackgroundMusic();

    player.reset();
    board.reset();
    fogOfWar.reset();

    // Restart background music
    _startBackgroundMusic();

    startGame();
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;

    if (!soundEnabled) {
      _stopBackgroundMusic();
    } else {
      _startBackgroundMusic();
    }

    // Play toggle sound with delay
    Future.delayed(Duration(milliseconds: 50), () async {
      try {
        await _playAudioWithRetry('button_click.wav', 0.4);
      } catch (e) {
        print('Could not play button click sound: $e');
      }
    });
  }

  void updateUI() {
    energyText.text = 'Energy: ${(player.energy * 100).toInt()}%';
    positionText.text = 'Position: ${player.currentTileIndex}';

    String instruction = '';
    if (player.energy < 1.0) {
      instruction = 'Press SPACE to plant seed';
    } else if (canRollDice()) {
      instruction = 'Press ENTER to roll dice';
    } else if (isDiceRolling) {
      instruction = 'Rolling dice...';
    }

    instructionText.text = instruction;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        plantSeed();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.enter)) {
        if (canRollDice()) {
          rollDice();
        }
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.keyM)) {
        // Toggle music with M key
        toggleSound();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update game systems
    energySystem.update(dt);
    fogOfWar.update(dt);
    pathSystem.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Render background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Color(0xFF87CEEB), // Sky blue background
    );

    super.render(canvas);

    // Draw sound indicator
    if (soundEnabled) {
      final soundIcon = TextComponent(
        text: '🔊',
        position: Vector2(size.x - 40, 20),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 20),
        ),
      );
      soundIcon.render(canvas);
    } else {
      final soundIcon = TextComponent(
        text: '🔇',
        position: Vector2(size.x - 40, 20),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 20),
        ),
      );
      soundIcon.render(canvas);
    }
  }

  @override
  void onRemove() {
    // Clean up audio when game is removed
    _stopBackgroundMusic();
    super.onRemove();
  }
}

Future<void> fadeText(TextComponent text, double from, double to, Duration duration) async {
  final steps = 20;
  for (int i = 0; i <= steps; i++) {
    final t = i / steps;
    final opacity = from + (to - from) * t;
    text.textRenderer = TextPaint(
      style: (text.textRenderer as TextPaint).style.copyWith(
        color: (text.textRenderer as TextPaint).style.color?.withOpacity(opacity),
      ),
    );
    await Future.delayed(duration ~/ steps);
  }
}
