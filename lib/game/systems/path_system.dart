import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../my_game.dart';
import '../components/board.dart';
import '../components/tile.dart';

class PathSystem extends Component {
  // Path selection state
  bool isShowingBranchOptions = false;
  int currentBranchTile = -1;
  List<int> availableOptions = [];
  
  // UI Components for path selection
  List<PathOptionButton> optionButtons = [];
  late RectangleComponent selectionBackground;
  late TextComponent instructionText;
  
  // Path preview
  List<int> previewPath = [];
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _initializeUI();
  }
  
  Future<void> _initializeUI() async {
    // Create selection background
    selectionBackground = RectangleComponent(
      size: Vector2(400, 200),
      position: Vector2(50, 200),
      paint: Paint()
        ..color = Colors.black.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );
    
    selectionBackground.add(
      RectangleComponent(
        size: Vector2(400, 200),
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );
    
    // Create instruction text
    instructionText = TextComponent(
      text: 'Choose your path:',
      position: Vector2(70, 220),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    // Initially hidden
    selectionBackground.opacity = 0.0;
    instructionText.opacity = 0.0;
  }
  
  void showBranchingOptions(MyGame gameRef, int branchTileIndex) {
    if (isShowingBranchOptions) return;
    
    isShowingBranchOptions = true;
    currentBranchTile = branchTileIndex;
    
    // Get available branching options
    availableOptions = gameRef.board.getBranchingOptions(branchTileIndex);
    
    // Create option buttons
    _createOptionButtons(gameRef);
    
    // Show UI
    _showSelectionUI(gameRef);
    
    // Highlight available paths
    _highlightAvailablePaths(gameRef);
  }
  
  void _createOptionButtons(MyGame gameRef) {
    optionButtons.clear();
    
    for (int i = 0; i < availableOptions.length; i++) {
      int targetTile = availableOptions[i];
      String direction = _getDirectionName(currentBranchTile, targetTile);
      
      PathOptionButton button = PathOptionButton(
        text: direction,
        position: Vector2(80 + (i * 120), 260),
        onPressed: () => _selectPath(gameRef, targetTile),
        targetTile: targetTile,
      );
      
      optionButtons.add(button);
    }
  }
  
  String _getDirectionName(int fromTile, int toTile) {
    // Calculate direction based on tile positions
    int fromRow = fromTile ~/ Board.tilesPerRow;
    int fromCol = fromTile % Board.tilesPerRow;
    int toRow = toTile ~/ Board.tilesPerRow;
    int toCol = toTile % Board.tilesPerRow;
    
    if (toRow > fromRow) {
      if (toCol > fromCol) {
        return 'Right ↗';
      } else if (toCol < fromCol) {
        return 'Left ↖';
      } else {
        return 'Forward ↑';
      }
    } else if (toRow == fromRow) {
      if (toCol > fromCol) {
        return 'Right →';
      } else if (toCol < fromCol) {
        return 'Left ←';
      } else {
        return 'Stay';
      }
    } else {
      return 'Forward ↑';
    }
  }
  
  void _showSelectionUI(MyGame gameRef) {
    // Add UI components to game
    gameRef.add(selectionBackground);
    gameRef.add(instructionText);
    
    for (PathOptionButton button in optionButtons) {
      gameRef.add(button);
    }
    
    // Fade in animation
    selectionBackground.add(
      OpacityEffect.fadeIn(
        EffectController(duration: 0.3),
      ),
    );
    
    instructionText.add(
      OpacityEffect.fadeIn(
        EffectController(duration: 0.3),
      ),
    );
    
    for (PathOptionButton button in optionButtons) {
      button.add(
        OpacityEffect.fadeIn(
          EffectController(duration: 0.3, startDelay: 0.1),
        ),
      );
    }
  }
  
  void _highlightAvailablePaths(MyGame gameRef) {
    // Highlight available path options
    for (int tileIndex in availableOptions) {
      gameRef.board.highlightTile(tileIndex, Colors.blue.withOpacity(0.6));
      
      // Show preview of path ahead
      _showPathPreview(gameRef, tileIndex);
    }
  }
  
  void _showPathPreview(MyGame gameRef, int startTile) {
    // Show a few tiles ahead on this path
    for (int i = 1; i <= 3; i++) {
      int previewTile = startTile + i;
      if (previewTile < Board.totalTiles) {
        gameRef.board.highlightTile(previewTile, Colors.cyan.withOpacity(0.3));
        previewPath.add(previewTile);
      }
    }
  }
  
  void _selectPath(MyGame gameRef, int selectedTile) {
    if (!isShowingBranchOptions) return;
    
    // Move player to selected tile
    gameRef.player.moveToTile(selectedTile);
    
    // Update fog of war
    gameRef.fogOfWar.updateVisibility(selectedTile, gameRef.board);
    
    // Handle tile effect
    GameTile tile = gameRef.board.getTile(selectedTile);
    tile.triggerTileEffect();
    
    // Hide selection UI
    _hideSelectionUI(gameRef);
    
    // Clear highlights
    _clearPathHighlights(gameRef);
    
    // Reset state
    _resetBranchingState();
  }
  
  void _hideSelectionUI(MyGame gameRef) {
    // Fade out animation
    selectionBackground.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
        onComplete: () => selectionBackground.removeFromParent(),
      ),
    );
    
    instructionText.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
        onComplete: () => instructionText.removeFromParent(),
      ),
    );
    
    for (PathOptionButton button in optionButtons) {
      button.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.3),
          onComplete: () => button.removeFromParent(),
        ),
      );
    }
  }
  
  void _clearPathHighlights(MyGame gameRef) {
    // Clear all path highlights
    gameRef.board.clearAllHighlights();
    
    // Clear preview path
    previewPath.clear();
  }
  
  void _resetBranchingState() {
    isShowingBranchOptions = false;
    currentBranchTile = -1;
    availableOptions.clear();
    optionButtons.clear();
  }
  
  bool isPathSelectionActive() {
    return isShowingBranchOptions;
  }
  
  void cancelPathSelection(MyGame gameRef) {
    if (isShowingBranchOptions) {
      _hideSelectionUI(gameRef);
      _clearPathHighlights(gameRef);
      _resetBranchingState();
    }
  }
  
  // Path finding and validation
  bool isValidPath(int fromTile, int toTile, Board board) {
    // Check if there's a valid path between tiles
    List<int> validTargets = board.getBranchingOptions(fromTile);
    return validTargets.contains(toTile);
  }
  
  List<int> findShortestPath(int fromTile, int toTile, Board board) {
    // Simple pathfinding algorithm
    List<int> path = [];
    
    if (fromTile == toTile) {
      return [fromTile];
    }
    
    // For now, simple linear path
    int current = fromTile;
    while (current < toTile && current < Board.totalTiles - 1) {
      path.add(current);
      current++;
    }
    path.add(toTile);
    
    return path;
  }
  
  void showPathPreview(MyGame gameRef, int fromTile, int toTile) {
    // Show preview of selected path
    List<int> path = findShortestPath(fromTile, toTile, gameRef.board);
    
    for (int i = 0; i < path.length; i++) {
      int tileIndex = path[i];
      Color previewColor = Colors.yellow.withOpacity(0.5 - (i * 0.1));
      gameRef.board.highlightTile(tileIndex, previewColor);
    }
    
    // Clear preview after delay
    Future.delayed(Duration(seconds: 2), () {
      for (int tileIndex in path) {
        gameRef.board.clearHighlight(tileIndex);
      }
    });
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update option buttons
    for (PathOptionButton button in optionButtons) {
      button.update(dt);
    }
  }
  
  void reset() {
    _resetBranchingState();
    previewPath.clear();
  }
}

class PathOptionButton extends RectangleComponent {
  final String text;
  final VoidCallback onPressed;
  final int targetTile;
  
  late TextComponent textComponent;
  bool isHovered = false;
  bool isPressed = false;
  
  PathOptionButton({
    required this.text,
    required Vector2 position,
    required this.onPressed,
    required this.targetTile,
  }) : super(
    size: Vector2(100, 40),
    position: position,
    paint: Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill,
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Add border
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );
    
    // Add text
    textComponent = TextComponent(
      text: text,
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(textComponent);
    
    // Add hitbox for interaction
    add(RectangleHitbox());
  }
  
  void onHover() {
    if (!isHovered) {
      isHovered = true;
      paint.color = Colors.blue.shade700;
      
      // Scale effect
      add(
        ScaleEffect.by(
          Vector2.all(1.05),
          EffectController(duration: 0.1),
        ),
      );
    }
  }
  
  void onHoverExit() {
    if (isHovered) {
      isHovered = false;
      paint.color = Colors.blue;
      
      // Reset scale
      add(
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.1),
        ),
      );
    }
  }
  
  void onTap() {
    if (!isPressed) {
      isPressed = true;
      
      // Press animation
      add(
        ScaleEffect.by(
          Vector2.all(0.95),
          EffectController(
            duration: 0.05,
            reverseDuration: 0.05,
          ),
          onComplete: () {
            isPressed = false;
            onPressed();
          },
        ),
      );
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Add glow effect when hovered
    if (isHovered) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-2, -2, size.x + 4, size.y + 4),
          Radius.circular(4),
        ),
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }
}
