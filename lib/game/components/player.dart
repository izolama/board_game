import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../my_game.dart';

class Player extends SpriteComponent with HasGameRef<MyGame> {
  // Player properties
  double energy = 0.0;
  int currentTileIndex = 0;
  bool isMoving = false;

  // Animation properties
  late SpriteAnimationComponent idleAnimation;
  late SpriteAnimationComponent walkAnimation;
  bool isWalking = false;
  int walkFrame = 0;

  // Visual properties
  static const double playerSize = 32.0;

  // Sprites
  late Sprite idleSprite;
  List<Sprite> walkSprites = [];

  Player({required MyGame gameRef}) : super() {
    // Remove invalid assignment
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Set player size
    size = Vector2.all(playerSize);

    // Load player sprites
    await _loadPlayerSprites();

    // Set initial position
    position = Vector2(100, 300);

    // Add to collision detection
    add(RectangleHitbox());
  }

  Future<void> _loadPlayerSprites() async {
    try {
      // Load idle sprite
      idleSprite = await Sprite.load('characters/player_idle.png');
      sprite = idleSprite;

      // Load walking sprites
      for (int i = 1; i <= 4; i++) {
        walkSprites.add(await Sprite.load('characters/player_walk_$i.png'));
      }
    } catch (e) {
      // Fallback to generated sprite if assets not found
      await _createPlayerSprite();
    }
  }

  Future<void> _createPlayerSprite() async {
    // Create a simple colored rectangle as player sprite
    // In a real game, you would load actual sprite images
    final paint = Paint()
      ..color = Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw player body (green rectangle)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, playerSize, playerSize),
        Radius.circular(4),
      ),
      paint,
    );

    // Draw player face (simple dots and smile)
    final facePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Eyes
    canvas.drawCircle(Offset(8, 8), 2, facePaint);
    canvas.drawCircle(Offset(24, 8), 2, facePaint);

    // Smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromLTWH(8, 12, 16, 12),
      0,
      3.14159, // π radians (180 degrees)
      false,
      smilePaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(playerSize.toInt(), playerSize.toInt());

    idleSprite = Sprite(image);
    sprite = idleSprite;

    // Create walk sprites (same as idle for fallback)
    for (int i = 0; i < 4; i++) {
      walkSprites.add(idleSprite);
    }
  }

  void moveToTile(int tileIndex) {
    if (isMoving) return;

    isMoving = true;
    currentTileIndex = tileIndex;

    // Get target position from board
    Vector2 targetPosition = gameRef.board.getTilePosition(tileIndex);

    // Start walking animation
    _startWalkingAnimation();

    // Play footstep sound
    _playFootstepSound();

    // Move to target position with smooth animation
    add(
      MoveEffect.to(
        targetPosition,
        EffectController(duration: 0.5, curve: Curves.easeInOut),
        onComplete: () {
          isMoving = false;
          _stopWalkingAnimation();
        },
      ),
    );

    // Add bounce effect when landing
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
          startDelay: 0.5,
        ),
      ),
    );
  }

  void _playFootstepSound() {
    try {
      // Alternate between footstep sounds
      String soundFile =
          walkFrame % 2 == 0 ? 'footstep_1.wav' : 'footstep_2.wav';
      FlameAudio.play(soundFile, volume: 0.3);
    } catch (e) {
      // Ignore audio errors
    }
  }

  void _startWalkingAnimation() {
    isWalking = true;
    walkFrame = 0;

    // Start walking sprite animation
    _animateWalkingSprites();

    // Add walking bob animation
    add(
      MoveEffect.by(
        Vector2(0, -5),
        EffectController(
          duration: 0.25,
          reverseDuration: 0.25,
          infinite: true,
        ),
      ),
    );
  }

  void _animateWalkingSprites() {
    if (!isWalking || walkSprites.isEmpty) return;

    // Change sprite every 0.125 seconds for smooth animation
    Future.delayed(Duration(milliseconds: 125), () {
      if (isWalking) {
        walkFrame = (walkFrame + 1) % walkSprites.length;
        sprite = walkSprites[walkFrame];
        _animateWalkingSprites(); // Continue animation
      }
    });
  }

  void _stopWalkingAnimation() {
    isWalking = false;
    sprite = idleSprite; // Return to idle sprite
    // Remove walking effects would be handled by the effect completion
  }

  void setPosition(Vector2 newPosition) {
    position = newPosition;
  }

  void plantSeed() {
    // Play seed planting sound
    try {
      FlameAudio.play('seed_plant.wav', volume: 0.6);
    } catch (e) {
      // Ignore audio errors
    }

    // Visual feedback for planting seed
    add(
      ScaleEffect.by(
        Vector2.all(0.8),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
        ),
      ),
    );

    // Create seed planting particle effect
    _createSeedParticles();
  }

  void _createSeedParticles() {
    for (int i = 0; i < 5; i++) {
      final particle = SpriteComponent(
        size: Vector2.all(4),
        position: position +
            Vector2(
              (i - 2) * 8.0,
              playerSize + 5,
            ),
      );

      // Create small green particle
      final paint = Paint()..color = Colors.lightGreen;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawCircle(Offset(2, 2), 2, paint);

      final picture = recorder.endRecording();
      picture.toImage(4, 4).then((image) {
        particle.sprite = Sprite(image);
      });

      gameRef.add(particle);

      // Animate particle
      particle.add(
        MoveEffect.by(
          Vector2(0, 20),
          EffectController(duration: 0.8),
          onComplete: () => particle.removeFromParent(),
        ),
      );

      particle.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.8),
        ),
      );
    }
  }

  void showEnergyGain() {
    // Play energy gain sound
    try {
      FlameAudio.play('energy_gain.wav', volume: 0.5);
    } catch (e) {
      // Ignore audio errors
    }

    // Visual feedback for energy gain
    add(
      ColorEffect(
        Colors.yellow,
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
        ),
        opacityFrom: 0.0,
        opacityTo: 0.5,
      ),
    );
  }

  void showEnergyFull() {
    // Play energy full sound
    try {
      FlameAudio.play('energy_full.wav', volume: 0.7);
    } catch (e) {
      // Ignore audio errors
    }

    // Visual feedback for full energy
    add(
      ColorEffect(
        Colors.amber,
        EffectController(
          duration: 0.3,
          reverseDuration: 0.3,
          repeatCount: 2,
        ),
        opacityFrom: 0.0,
        opacityTo: 0.7,
      ),
    );

    // Glow effect
    add(
      ScaleEffect.by(
        Vector2.all(1.3),
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          repeatCount: 2,
        ),
      ),
    );
  }

  void showDamage() {
    // Visual feedback for taking damage
    add(
      ColorEffect(
        Colors.red,
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
        ),
        opacityFrom: 0.0,
        opacityTo: 0.7,
      ),
    );

    // Shake effect
    add(
      MoveEffect.by(
        Vector2(5, 0),
        EffectController(
          duration: 0.05,
          reverseDuration: 0.05,
          repeatCount: 4,
        ),
      ),
    );
  }

  void reset() {
    energy = 0.0;
    currentTileIndex = 0;
    isMoving = false;
    isWalking = false;
    walkFrame = 0;

    // Reset sprite to idle
    sprite = idleSprite;

    // Reset position to start
    position = gameRef.board.getTilePosition(0);

    // Remove all effects
    children.whereType<Effect>().forEach((effect) {
      effect.removeFromParent();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update animations based on state
    if (isWalking && !isMoving) {
      _stopWalkingAnimation();
    }

    // Check for energy full state
    if (energy >= 1.0 && !isMoving) {
      // Show energy full effect occasionally
      if (DateTime.now().millisecondsSinceEpoch % 3000 < 50) {
        showEnergyFull();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw energy bar above player
    if (energy > 0) {
      const barWidth = playerSize;
      const barHeight = 4.0;
      const barY = -10.0;

      // Background bar
      canvas.drawRect(
        Rect.fromLTWH(0, barY, barWidth, barHeight),
        Paint()..color = Colors.grey[400]!,
      );

      // Energy bar
      canvas.drawRect(
        Rect.fromLTWH(0, barY, barWidth * energy, barHeight),
        Paint()..color = energy >= 1.0 ? Colors.amber : Colors.green,
      );

      // Bar border
      canvas.drawRect(
        Rect.fromLTWH(0, barY, barWidth, barHeight),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }
}
