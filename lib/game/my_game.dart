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
import 'systems/energy_system.dart';
import 'systems/fog_of_war.dart';
import 'systems/path_system.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  late Board board;
  late EnergySystem energySystem;
  late FogOfWar fogOfWar;
  late PathSystem pathSystem;

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
  bool soundEnabled = true;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Initialize game systems
    energySystem = EnergySystem();
    fogOfWar = FogOfWar();
    pathSystem = PathSystem();

    // Create board
    board = Board(gameRef: this);
    add(board);

    // Create player
    player = Player(gameRef: this);
    add(player);

    // Initialize UI components
    await _initializeUI();

    // Start background music
    await _startBackgroundMusic();

    // Start the game
    startGame();
  }

  Future<void> _startBackgroundMusic() async {
    if (!isMusicPlaying && soundEnabled) {
      try {
        await FlameAudio.bgm.play('gameplay_theme.wav', volume: 0.3);
        isMusicPlaying = true;
      } catch (e) {
        // Ignore audio errors
        // Could not play background music
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

    // Initialize player position
    player.setPosition(board.getTilePosition(0));

    // Initialize fog of war
    fogOfWar.revealTile(0);
    fogOfWar.revealTile(1); // Show next tile

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

    // Play dice roll sound
    _playUISound('dice_roll.wav');

    // Reset energy after rolling
    player.energy = 0.0;

    // Generate dice roll (1-6)
    final random = Random();
    lastDiceRoll = random.nextInt(6) + 1;

    // Visual feedback
    _showFloatingText(
        '🎲 $lastDiceRoll', player.position + Vector2(0, -30), Colors.blue);

    // Move player after short delay
    Future.delayed(Duration(milliseconds: 800), () {
      _playUISound('dice_land.wav');
      movePlayer(lastDiceRoll);
      isDiceRolling = false;
    });

    updateUI();
  }

  void _playUISound(String soundFile) {
    if (!soundEnabled) return;

    try {
      FlameAudio.play(soundFile, volume: 0.4);
    } catch (e) {
      // Ignore audio errors
    }
  }

  void movePlayer(int steps) {
    totalSteps += steps;

    for (int i = 0; i < steps; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        _movePlayerOneStep();
      });
    }
  }

  void _movePlayerOneStep() {
    if (isGameFinished) return;

    int nextTileIndex = player.currentTileIndex + 1;

    // Check if reached finish
    if (nextTileIndex >= Board.totalTiles) {
      finishGame();
      return;
    }

    // Check for branching paths
    GameTile currentTile = board.getTile(nextTileIndex);
    if (currentTile.tileType == TileType.branch) {
      pathSystem.showBranchingOptions(this, nextTileIndex);
      return;
    }

    // Normal movement
    player.moveToTile(nextTileIndex);

    // Reveal new tiles (fog of war)
    fogOfWar.revealTile(nextTileIndex);
    if (nextTileIndex + 1 < Board.totalTiles) {
      fogOfWar.revealTile(nextTileIndex + 1);
    }

    // Handle tile effects
    _handleTileEffect(currentTile);

    updateUI();
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

    floatingText.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 1.0, startDelay: 0.5),
      ),
    );
  }

  void finishGame() {
    isGameFinished = true;
    final gameTime = DateTime.now().difference(gameStartTime!);

    // Stop background music
    _stopBackgroundMusic();

    // Play victory music
    try {
      FlameAudio.bgm.play('victory_theme.wav', volume: 0.5);
    } catch (e) {
      // Ignore audio errors
    }

    _showFloatingText('🏁 Finish!', player.position, Colors.amber);

    // Navigate to finish screen after delay
    Future.delayed(Duration(seconds: 3), () {
      // This would typically navigate to finish screen with gameTime
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

    _playUISound('button_click.wav');
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
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
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
