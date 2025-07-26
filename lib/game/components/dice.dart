import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:math';
import '../my_game.dart';

class Dice extends SpriteComponent
    with HasGameRef<MyGame>, HasCollisionDetection {
  int currentValue = 1;
  bool isRolling = false;

  // Visual properties
  static const double diceSize = 60.0;
  late Paint dicePaint;
  late Paint dotPaint;

  // Animation properties
  double rollAnimationTime = 0.0;
  static const double rollDuration = 1.0;

  Dice({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(diceSize),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Initialize paints
    dicePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Create initial dice sprite
    await _createDiceSprite();

    // Add hitbox
    add(RectangleHitbox());
  }

  Future<void> _createDiceSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw dice background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, diceSize, diceSize),
        Radius.circular(8),
      ),
      dicePaint,
    );

    // Draw dice border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, diceSize, diceSize),
        Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw dots based on current value
    _drawDiceDots(canvas, currentValue);

    final picture = recorder.endRecording();
    final image = await picture.toImage(diceSize.toInt(), diceSize.toInt());
    sprite = Sprite(image);
  }

  void _drawDiceDots(Canvas canvas, int value) {
    const double dotRadius = 4.0;
    const double margin = 12.0;

    // Dot positions for different dice faces
    final center = Offset(diceSize / 2, diceSize / 2);
    final topLeft = Offset(margin, margin);
    final topRight = Offset(diceSize - margin, margin);
    final middleLeft = Offset(margin, diceSize / 2);
    final middleRight = Offset(diceSize - margin, diceSize / 2);
    final bottomLeft = Offset(margin, diceSize - margin);
    final bottomRight = Offset(diceSize - margin, diceSize - margin);

    switch (value) {
      case 1:
        canvas.drawCircle(center, dotRadius, dotPaint);
        break;
      case 2:
        canvas.drawCircle(topLeft, dotRadius, dotPaint);
        canvas.drawCircle(bottomRight, dotRadius, dotPaint);
        break;
      case 3:
        canvas.drawCircle(topLeft, dotRadius, dotPaint);
        canvas.drawCircle(center, dotRadius, dotPaint);
        canvas.drawCircle(bottomRight, dotRadius, dotPaint);
        break;
      case 4:
        canvas.drawCircle(topLeft, dotRadius, dotPaint);
        canvas.drawCircle(topRight, dotRadius, dotPaint);
        canvas.drawCircle(bottomLeft, dotRadius, dotPaint);
        canvas.drawCircle(bottomRight, dotRadius, dotPaint);
        break;
      case 5:
        canvas.drawCircle(topLeft, dotRadius, dotPaint);
        canvas.drawCircle(topRight, dotRadius, dotPaint);
        canvas.drawCircle(center, dotRadius, dotPaint);
        canvas.drawCircle(bottomLeft, dotRadius, dotPaint);
        canvas.drawCircle(bottomRight, dotRadius, dotPaint);
        break;
      case 6:
        canvas.drawCircle(topLeft, dotRadius, dotPaint);
        canvas.drawCircle(topRight, dotRadius, dotPaint);
        canvas.drawCircle(middleLeft, dotRadius, dotPaint);
        canvas.drawCircle(middleRight, dotRadius, dotPaint);
        canvas.drawCircle(bottomLeft, dotRadius, dotPaint);
        canvas.drawCircle(bottomRight, dotRadius, dotPaint);
        break;
    }
  }

  Future<int> roll() async {
    if (isRolling) return currentValue;

    isRolling = true;
    rollAnimationTime = 0.0;

    // Add rolling animation effects
    add(
      RotateEffect.by(
        2 * pi,
        EffectController(duration: rollDuration),
      ),
    );

    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: rollDuration / 2,
          reverseDuration: rollDuration / 2,
        ),
      ),
    );

    // Generate final result
    final random = Random();
    final finalValue = random.nextInt(6) + 1;

    // Animate through random values during roll
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: i * 100));
      if (isRolling) {
        currentValue = random.nextInt(6) + 1;
        _updateDiceSprite();
      }
    }

    // Set final value
    await Future.delayed(Duration(milliseconds: (rollDuration * 1000).toInt()));
    currentValue = finalValue;
    _updateDiceSprite();
    isRolling = false;

    // Bounce effect when landing
    add(
      ScaleEffect.by(
        Vector2.all(1.1),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
        ),
      ),
    );

    return finalValue;
  }

  Future<void> _updateDiceSprite() async {
    await _createDiceSprite();
  }

  Future<void> showResult(int value) async {
    currentValue = value;
    await _updateDiceSprite();

    // Highlight effect
    add(
      ColorEffect(
        Colors.yellow,
        EffectController(
          duration: 0.3,
          reverseDuration: 0.3,
          repeatCount: 2,
        ),
        opacityFrom: 0.0,
        opacityTo: 0.5,
      ),
    );
  }

  Future<void> reset() async {
    currentValue = 1;
    isRolling = false;
    rollAnimationTime = 0.0;

    // Remove all effects
    children.whereType<Effect>().forEach((effect) {
      effect.removeFromParent();
    });

    // Reset transformations
    scale = Vector2.all(1.0);
    angle = 0.0;

    await _updateDiceSprite();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isRolling) {
      rollAnimationTime += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, diceSize, diceSize),
        Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
  }
}

class DiceUI extends SpriteComponent with HasGameRef<MyGame> {
  late Dice dice;
  late TextComponent resultText;

  bool isVisible = false;

  DiceUI() : super(size: Vector2(120, 100));

  @override
  Future<void> onLoad() async {
    // Set posisi untuk UI container
    position = Vector2(gameRef.size.x - 140, 20);

    // Set background sprite terlebih dahulu
    await _createBackgroundSprite();
    await super.onLoad();

    // Create dice
    dice = Dice(position: Vector2(gameRef.size.x - 110, 50));
    add(dice);

    // Create result text
    resultText = TextComponent(
      text: 'Roll: ${dice.currentValue}',
      position: Vector2(gameRef.size.x - 130, 130),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(resultText);

    // Initially hidden
    opacity = 0.0;
  }

  Future<void> _createBackgroundSprite() async {
    try {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Pastikan ukuran valid (minimal 1x1)
      final imageWidth = size.x.toInt().clamp(1, 1000);
      final imageHeight = size.y.toInt().clamp(1, 1000);

      // Draw background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble()),
          Radius.circular(8),
        ),
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.fill,
      );

      // Draw border
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble()),
          Radius.circular(8),
        ),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(imageWidth, imageHeight);
      sprite = Sprite(image);
    } catch (e) {
      // Fallback: create simple colored rectangle
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.white,
      );
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.x.toInt(), size.y.toInt());
      sprite = Sprite(image);
    }
  }

  void show() {
    if (!isVisible) {
      isVisible = true;
      opacity = 1.0;
    }
  }

  void hide() {
    if (isVisible) {
      isVisible = false;
      opacity = 0.0;
    }
  }

  Future<int> rollDice() async {
    show();
    final result = await dice.roll();
    resultText.text = 'Roll: ${dice.currentValue}';

    // Hide after showing result
    Future.delayed(Duration(seconds: 2), () {
      hide();
    });

    return result;
  }

  Future<void> reset() async {
    await dice.reset();
    resultText.text = 'Roll: ${dice.currentValue}';
    hide();
  }
}
