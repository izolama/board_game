import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../my_game.dart';
import 'tile.dart';

class Board extends Component with HasGameRef<MyGame> {
  // Board properties
  static const int totalTiles = 50;
  static const double tileSize = 40.0;
  static const double tileSpacing = 10.0;

  // Board layout
  List<GameTile> tiles = [];
  List<Vector2> tilePositions = [];

  // Board path configuration
  static const int tilesPerRow = 10;
  bool isRightToLeft = false; // For snake-like pattern

  Board({required MyGame gameRef}) : super() {
    // Remove the invalid assignment
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _generateBoard();
  }

  Future<void> _generateBoard() async {
    tiles.clear();
    tilePositions.clear();

    final random = Random();

    for (int i = 0; i < totalTiles; i++) {
      // Calculate tile position in snake pattern
      Vector2 tilePos = _calculateTilePosition(i);
      tilePositions.add(tilePos);

      // Determine tile type
      TileType tileType = _determineTileType(i, random);

      // Create tile
      GameTile tile = GameTile(
        tileIndex: i,
        tileType: tileType,
        position: tilePos,
        gameRef: gameRef,
      );

      tiles.add(tile);
      add(tile);
    }
  }

  Vector2 _calculateTilePosition(int index) {
    // Calculate row and column
    int row = index ~/ tilesPerRow;
    int col = index % tilesPerRow;

    // Snake pattern: alternate direction each row
    if (row % 2 == 1) {
      col = tilesPerRow - 1 - col; // Reverse direction
    }

    // Calculate actual position
    double x = 50 + col * (tileSize + tileSpacing);
    double y = 100 + row * (tileSize + tileSpacing);

    return Vector2(x, y);
  }

  TileType _determineTileType(int index, Random random) {
    // Special tiles
    if (index == 0) return TileType.start;
    if (index == totalTiles - 1) return TileType.finish;

    // Random tile types with weighted probability
    int randomValue = random.nextInt(100);

    if (randomValue < 10) {
      return TileType.obstacle; // 10% chance
    } else if (randomValue < 20) {
      return TileType.bonus; // 10% chance
    } else if (randomValue < 30 && index > 5) {
      return TileType.branch; // 10% chance, but not too early
    } else {
      return TileType.normal; // 70% chance
    }
  }

  GameTile getTile(int index) {
    if (index >= 0 && index < tiles.length) {
      return tiles[index];
    }
    return tiles[0]; // Return start tile as fallback
  }

  Vector2 getTilePosition(int index) {
    if (index >= 0 && index < tilePositions.length) {
      return tilePositions[index];
    }
    return tilePositions[0]; // Return start position as fallback
  }

  List<int> getBranchingOptions(int currentIndex) {
    // Generate branching options for a tile
    List<int> options = [];

    // Always add straight path
    if (currentIndex + 1 < totalTiles) {
      options.add(currentIndex + 1);
    }

    // Add alternative paths based on board layout
    int col = currentIndex % tilesPerRow;

    // Left branch (if not at left edge)
    if (col > 0) {
      int leftIndex = currentIndex + tilesPerRow - 1;
      if (leftIndex < totalTiles) {
        options.add(leftIndex);
      }
    }

    // Right branch (if not at right edge)
    if (col < tilesPerRow - 1) {
      int rightIndex = currentIndex + tilesPerRow + 1;
      if (rightIndex < totalTiles) {
        options.add(rightIndex);
      }
    }

    return options;
  }

  void revealTile(int index) {
    if (index >= 0 && index < tiles.length) {
      tiles[index].setVisible(true);
    }
  }

  void hideTile(int index) {
    if (index >= 0 && index < tiles.length) {
      tiles[index].setVisible(false);
    }
  }

  void reset() {
    // Reset all tiles
    for (GameTile tile in tiles) {
      tile.reset();
    }

    // Hide all tiles except start and first few
    for (int i = 0; i < tiles.length; i++) {
      if (i <= 1) {
        revealTile(i); // Show start and next tile
      } else {
        hideTile(i);
      }
    }
  }

  void highlightTile(int index, Color color) {
    if (index >= 0 && index < tiles.length) {
      tiles[index].setHighlight(color);
    }
  }

  void clearHighlight(int index) {
    if (index >= 0 && index < tiles.length) {
      tiles[index].clearHighlight();
    }
  }

  void clearAllHighlights() {
    for (GameTile tile in tiles) {
      tile.clearHighlight();
    }
  }

  // Get tiles within a certain range (for fog of war)
  List<int> getTilesInRange(int centerIndex, int range) {
    List<int> tilesInRange = [];

    for (int i = max(0, centerIndex - range);
        i <= min(totalTiles - 1, centerIndex + range);
        i++) {
      tilesInRange.add(i);
    }

    return tilesInRange;
  }

  // Check if a path exists between two tiles
  bool hasPathBetween(int fromIndex, int toIndex) {
    // Simple path validation
    if (fromIndex < 0 ||
        fromIndex >= totalTiles ||
        toIndex < 0 ||
        toIndex >= totalTiles) {
      return false;
    }

    // For now, allow movement to adjacent tiles or branching options
    List<int> validTargets = getBranchingOptions(fromIndex);
    return validTargets.contains(toIndex);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw board background
    final boardRect = Rect.fromLTWH(
      30,
      80,
      tilesPerRow * (tileSize + tileSpacing) + 20,
      ((totalTiles / tilesPerRow).ceil()) * (tileSize + tileSpacing) + 20,
    );

    // Board background
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, Radius.circular(10)),
      Paint()
        ..color = Color(0xFF8FBC8F).withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );

    // Board border
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, Radius.circular(10)),
      Paint()
        ..color = Color(0xFF2E7D32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw path connections (visible tiles only)
    _drawPathConnections(canvas);
  }

  void _drawPathConnections(Canvas canvas) {
    final pathPaint = Paint()
      ..color = Color(0xFF8FBC8F).withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i].isVisible && tiles[i + 1].isVisible) {
        Vector2 start = tilePositions[i] + Vector2(tileSize / 2, tileSize / 2);
        Vector2 end =
            tilePositions[i + 1] + Vector2(tileSize / 2, tileSize / 2);

        canvas.drawLine(
          Offset(start.x, start.y),
          Offset(end.x, end.y),
          pathPaint,
        );
      }
    }
  }
}
