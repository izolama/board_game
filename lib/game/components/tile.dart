import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import '../my_game.dart';

enum TileType {
  start,
  normal,
  obstacle,
  bonus,
  branch,
  finish,
}

class GameTile extends SpriteComponent with HasGameRef<MyGame> {
  final int tileIndex;
  final TileType tileType;
  bool isVisible = false;
  bool isHighlighted = false;
  Color? highlightColor;

  // Visual properties
  static const double tileSize = 40.0;
  late Paint tilePaint;
  late Paint borderPaint;

  GameTile({
    required this.tileIndex,
    required this.tileType,
    required Vector2 position,
    required MyGame gameRef,
  }) : super(position: position, size: Vector2.all(tileSize)) {
    // Remove invalid assignment
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Initialize paints
    _initializePaints();

    // Load tile sprite from assets
    await _loadTileSprite();

    // Add hitbox for collision detection
    add(RectangleHitbox());

    // Initially hidden (fog of war)
    opacity = isVisible ? 1.0 : 0.3;
  }

  void _initializePaints() {
    tilePaint = Paint()..style = PaintingStyle.fill;
    borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black54;
  }

  Future<void> _loadTileSprite() async {
    // Load sprite from assets based on tile type
    String spritePath = _getTileSpritePath();
    try {
      sprite = await Sprite.load(spritePath);
    } catch (e) {
      // Fallback to generated sprite if asset not found
      await _createTileSprite();
    }
  }

  String _getTileSpritePath() {
    switch (tileType) {
      case TileType.start:
        return 'tiles/tile_start.png';
      case TileType.finish:
        return 'tiles/tile_finish.png';
      case TileType.obstacle:
        return 'tiles/tile_obstacle.png';
      case TileType.bonus:
        return 'tiles/tile_bonus.png';
      case TileType.branch:
        return 'tiles/tile_branch.png';
      case TileType.normal:
        return 'tiles/tile_normal.png';
    }
  }

  Future<void> _createTileSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Set tile color based on type
    Color tileColor = _getTileColor();
    tilePaint.color = tileColor;

    // Draw tile background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, tileSize, tileSize),
        Radius.circular(4),
      ),
      tilePaint,
    );

    // Draw tile border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, tileSize, tileSize),
        Radius.circular(4),
      ),
      borderPaint,
    );

    // Draw tile icon/symbol
    _drawTileIcon(canvas);

    final picture = recorder.endRecording();
    final image = await picture.toImage(tileSize.toInt(), tileSize.toInt());
    sprite = Sprite(image);
  }

  Color _getTileColor() {
    switch (tileType) {
      case TileType.start:
        return Color(0xFF4CAF50); // Green
      case TileType.finish:
        return Color(0xFFFFD700); // Amber
      case TileType.obstacle:
        return Color(0xFFF44336); // Red
      case TileType.bonus:
        return Color(0xFF2196F3); // Blue
      case TileType.branch:
        return Color(0xFF9C27B0); // Purple
      case TileType.normal:
        return Color(0xFF8FBC8F); // Light green
    }
  }

  void _drawTileIcon(Canvas canvas) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    String icon = _getTileIcon();

    textPainter.text = TextSpan(
      text: icon,
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
    );

    textPainter.layout();

    // Center the icon
    final offset = Offset(
      (tileSize - textPainter.width) / 2,
      (tileSize - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  String _getTileIcon() {
    switch (tileType) {
      case TileType.start:
        return '🏠';
      case TileType.finish:
        return '🏁';
      case TileType.obstacle:
        return '💥';
      case TileType.bonus:
        return '⭐';
      case TileType.branch:
        return '🔀';
      case TileType.normal:
        return '🌿';
    }
  }

  void setVisible(bool visible) {
    isVisible = visible;

    if (visible) {
      // Fade in effect
      add(
        OpacityEffect.fadeIn(
          EffectController(duration: 0.5),
        ),
      );
    } else {
      // Fade out effect
      add(
        OpacityEffect.to(
          0.3,
          EffectController(duration: 0.3),
        ),
      );
    }
  }

  void setHighlight(Color color) {
    isHighlighted = true;
    highlightColor = color;

    // Add pulsing highlight effect
    add(
      ColorEffect(
        color,
        EffectController(
          duration: 0.5,
          reverseDuration: 0.5,
          infinite: true,
        ),
        opacityFrom: 0.0,
        opacityTo: 0.6,
      ),
    );

    // Add scale effect
    add(
      ScaleEffect.by(
        Vector2.all(1.1),
        EffectController(
          duration: 0.3,
          reverseDuration: 0.3,
          infinite: true,
        ),
      ),
    );
  }

  void clearHighlight() {
    isHighlighted = false;
    highlightColor = null;

    // Remove all color and scale effects
    children.whereType<ColorEffect>().forEach((effect) {
      effect.removeFromParent();
    });

    children.whereType<ScaleEffect>().forEach((effect) {
      effect.removeFromParent();
    });

    // Reset scale
    scale = Vector2.all(1.0);
  }

  void triggerTileEffect() {
    // Play sound effect
    _playTileSound();

    switch (tileType) {
      case TileType.obstacle:
        _triggerObstacleEffect();
        break;
      case TileType.bonus:
        _triggerBonusEffect();
        break;
      case TileType.branch:
        _triggerBranchEffect();
        break;
      case TileType.normal:
        _triggerNormalEffect();
        break;
      default:
        // No special effect for start/finish tiles
        break;
    }
  }

  void _playTileSound() {
    String soundPath = _getTileSoundPath();
    try {
      FlameAudio.play(soundPath, volume: 0.5);
    } catch (e) {
      // Ignore audio errors
    }
  }

  String _getTileSoundPath() {
    switch (tileType) {
      case TileType.obstacle:
        return 'tile_obstacle.wav';
      case TileType.bonus:
        return 'tile_bonus.wav';
      case TileType.branch:
        return 'tile_branch.wav';
      case TileType.finish:
        return 'tile_finish.wav';
      case TileType.normal:
      case TileType.start:
      default:
        return 'tile_normal.wav';
    }
  }

  void _triggerNormalEffect() {
    // Subtle effect for normal tiles
    add(
      ColorEffect(
        Colors.green.withOpacity(0.3),
        EffectController(duration: 0.2, reverseDuration: 0.2),
        opacityFrom: 0.0,
        opacityTo: 0.3,
      ),
    );
  }

  void _triggerObstacleEffect() {
    // Visual feedback for obstacle
    add(
      ColorEffect(
        Colors.red,
        EffectController(duration: 0.3, reverseDuration: 0.3),
        opacityFrom: 0.0,
        opacityTo: 0.8,
      ),
    );

    // Shake effect
    add(
      MoveEffect.by(
        Vector2(3, 0),
        EffectController(
          duration: 0.05,
          reverseDuration: 0.05,
          repeatCount: 6,
        ),
      ),
    );

    // Create obstacle particles
    _createObstacleParticles();
  }

  void _triggerBonusEffect() {
    // Visual feedback for bonus
    add(
      ColorEffect(
        Colors.yellow,
        EffectController(duration: 0.5, reverseDuration: 0.5),
        opacityFrom: 0.0,
        opacityTo: 0.7,
      ),
    );

    // Bounce effect
    add(
      ScaleEffect.by(
        Vector2.all(1.3),
        EffectController(duration: 0.2, reverseDuration: 0.2),
      ),
    );

    // Create bonus particles
    _createBonusParticles();
  }

  void _triggerBranchEffect() {
    // Visual feedback for branch
    add(
      ColorEffect(
        Colors.purple,
        EffectController(duration: 0.4, reverseDuration: 0.4),
        opacityFrom: 0.0,
        opacityTo: 0.6,
      ),
    );

    // Rotation effect
    add(
      RotateEffect.by(
        0.2,
        EffectController(duration: 0.3, reverseDuration: 0.3),
      ),
    );
  }

  void _createObstacleParticles() {
    for (int i = 0; i < 8; i++) {
      final particle = SpriteComponent(
        size: Vector2.all(3),
        position: position + Vector2(tileSize / 2, tileSize / 2),
      );

      // Create red particle
      final paint = Paint()..color = Colors.red;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawCircle(Offset(1.5, 1.5), 1.5, paint);

      final picture = recorder.endRecording();
      picture.toImage(3, 3).then((image) {
        particle.sprite = Sprite(image);
      });

      gameRef.add(particle);

      // Random direction
      final direction = Vector2(
        30 * (0.5 - (i % 2)) * 2,
        30 * (0.5 - (i ~/ 2 % 2)) * 2,
      );

      // Animate particle
      particle.add(
        MoveEffect.by(
          direction,
          EffectController(duration: 0.6),
          onComplete: () => particle.removeFromParent(),
        ),
      );

      particle.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.6),
        ),
      );
    }
  }

  void _createBonusParticles() {
    for (int i = 0; i < 6; i++) {
      final particle = SpriteComponent(
        size: Vector2.all(4),
        position: position + Vector2(tileSize / 2, tileSize / 2),
      );

      // Create golden particle
      final paint = Paint()..color = Colors.amber;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawCircle(Offset(2, 2), 2, paint);

      final picture = recorder.endRecording();
      picture.toImage(4, 4).then((image) {
        particle.sprite = Sprite(image);
      });

      gameRef.add(particle);

      // Upward direction with spread
      final direction = Vector2(
        (i - 3) * 10.0,
        -40 - (i * 5),
      );

      // Animate particle
      particle.add(
        MoveEffect.by(
          direction,
          EffectController(duration: 1.0),
          onComplete: () => particle.removeFromParent(),
        ),
      );

      particle.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 1.0, startDelay: 0.3),
        ),
      );

      // Add sparkle effect
      particle.add(
        ScaleEffect.by(
          Vector2.all(1.5),
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            infinite: true,
          ),
        ),
      );
    }
  }

  void reset() {
    isVisible = false;
    isHighlighted = false;
    highlightColor = null;
    opacity = 0.3;
    scale = Vector2.all(1.0);

    // Remove all effects
    children.whereType<Effect>().forEach((effect) {
      effect.removeFromParent();
    });
  }

  String getTileDescription() {
    switch (tileType) {
      case TileType.start:
        return 'Starting point of your adventure';
      case TileType.finish:
        return 'The finish line - your goal!';
      case TileType.obstacle:
        return 'Dangerous obstacle - reduces energy';
      case TileType.bonus:
        return 'Bonus tile - grants extra energy';
      case TileType.branch:
        return 'Branching path - choose your direction';
      case TileType.normal:
        return 'Safe path tile';
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw tile index for debugging (only if visible)
    if (isVisible) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: tileIndex.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(2, 2));
    }
  }
}
