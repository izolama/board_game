import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/board.dart';
import '../components/tile.dart';

class FogOfWar extends Component {
  // Visibility configuration
  static const int baseVisibilityRange = 1; // How many tiles ahead are visible
  static const int extendedVisibilityRange = 2; // Extended range for special abilities
  
  // Fog state
  Set<int> visibleTiles = <int>{};
  Set<int> exploredTiles = <int>{}; // Tiles that have been visited before
  
  // Visual effects
  Map<int, double> fogOpacity = <int, double>{};
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update fog opacity animations
    _updateFogAnimations(dt);
  }
  
  void _updateFogAnimations(double dt) {
    // Animate fog opacity changes
    fogOpacity.forEach((tileIndex, opacity) {
      // Fade in/out effects can be handled here
    });
  }
  
  void revealTile(int tileIndex) {
    if (!visibleTiles.contains(tileIndex)) {
      visibleTiles.add(tileIndex);
      exploredTiles.add(tileIndex);
      
      // Set fog opacity for fade-in effect
      fogOpacity[tileIndex] = 0.0;
      
      // Trigger reveal animation
      _animateReveal(tileIndex);
    }
  }
  
  void hideTile(int tileIndex) {
    if (visibleTiles.contains(tileIndex)) {
      visibleTiles.remove(tileIndex);
      
      // Set fog opacity for fade-out effect
      fogOpacity[tileIndex] = 0.8;
      
      // Trigger hide animation
      _animateHide(tileIndex);
    }
  }
  
  void _animateReveal(int tileIndex) {
    // This would typically animate the tile's visibility
    // For now, we'll just set it as visible immediately
    fogOpacity[tileIndex] = 0.0;
  }
  
  void _animateHide(int tileIndex) {
    // This would typically animate the tile becoming foggy
    fogOpacity[tileIndex] = 0.8;
  }
  
  void updateVisibility(int playerPosition, Board board) {
    // Clear current visibility
    Set<int> newVisibleTiles = <int>{};
    
    // Always show current tile
    newVisibleTiles.add(playerPosition);
    
    // Show tiles within visibility range
    for (int i = 1; i <= baseVisibilityRange; i++) {
      int nextTile = playerPosition + i;
      if (nextTile < Board.totalTiles) {
        newVisibleTiles.add(nextTile);
      }
    }
    
    // Show branching options if current tile is a branch
    GameTile currentTile = board.getTile(playerPosition);
    if (currentTile.tileType == TileType.branch) {
      List<int> branchOptions = board.getBranchingOptions(playerPosition);
      newVisibleTiles.addAll(branchOptions);
      
      // Also show tiles after branch options
      for (int branchTile in branchOptions) {
        for (int i = 1; i <= baseVisibilityRange; i++) {
          int nextTile = branchTile + i;
          if (nextTile < Board.totalTiles) {
            newVisibleTiles.add(nextTile);
          }
        }
      }
    }
    
    // Update visibility
    _updateTileVisibility(newVisibleTiles, board);
  }
  
  void _updateTileVisibility(Set<int> newVisibleTiles, Board board) {
    // Hide tiles that are no longer visible
    for (int tileIndex in visibleTiles) {
      if (!newVisibleTiles.contains(tileIndex)) {
        board.hideTile(tileIndex);
        hideTile(tileIndex);
      }
    }
    
    // Show newly visible tiles
    for (int tileIndex in newVisibleTiles) {
      if (!visibleTiles.contains(tileIndex)) {
        board.revealTile(tileIndex);
        revealTile(tileIndex);
      }
    }
    
    visibleTiles = newVisibleTiles;
  }
  
  bool isTileVisible(int tileIndex) {
    return visibleTiles.contains(tileIndex);
  }
  
  bool isTileExplored(int tileIndex) {
    return exploredTiles.contains(tileIndex);
  }
  
  void extendVisibility(int playerPosition, Board board) {
    // Temporarily extend visibility range (special ability)
    Set<int> extendedVisibleTiles = Set.from(visibleTiles);
    
    // Add extended range tiles
    for (int i = baseVisibilityRange + 1; i <= extendedVisibilityRange; i++) {
      int nextTile = playerPosition + i;
      if (nextTile < Board.totalTiles) {
        extendedVisibleTiles.add(nextTile);
      }
    }
    
    // Update visibility with extended range
    _updateTileVisibility(extendedVisibleTiles, board);
    
    // Schedule return to normal visibility
    Future.delayed(Duration(seconds: 3), () {
      updateVisibility(playerPosition, board);
    });
  }
  
  void revealPath(int fromTile, int toTile, Board board) {
    // Reveal a path between two tiles (for pathfinding preview)
    for (int i = fromTile; i <= toTile && i < Board.totalTiles; i++) {
      if (!visibleTiles.contains(i)) {
        board.revealTile(i);
        revealTile(i);
        
        // Mark as temporary visibility
        Future.delayed(Duration(seconds: 2), () {
          if (!_isInNormalVisibilityRange(i, fromTile)) {
            board.hideTile(i);
            hideTile(i);
          }
        });
      }
    }
  }
  
  bool _isInNormalVisibilityRange(int tileIndex, int playerPosition) {
    return (tileIndex >= playerPosition && 
            tileIndex <= playerPosition + baseVisibilityRange);
  }
  
  void highlightVisibleTiles(Board board, Color color) {
    // Highlight all currently visible tiles
    for (int tileIndex in visibleTiles) {
      board.highlightTile(tileIndex, color);
    }
    
    // Clear highlights after delay
    Future.delayed(Duration(seconds: 1), () {
      board.clearAllHighlights();
    });
  }
  
  void showExploredTiles(Board board) {
    // Temporarily show all explored tiles with reduced opacity
    for (int tileIndex in exploredTiles) {
      if (!visibleTiles.contains(tileIndex)) {
        board.getTile(tileIndex).opacity = 0.5;
        board.revealTile(tileIndex);
      }
    }
    
    // Hide them again after delay
    Future.delayed(Duration(seconds: 3), () {
      for (int tileIndex in exploredTiles) {
        if (!visibleTiles.contains(tileIndex)) {
          board.getTile(tileIndex).opacity = 0.3;
          board.hideTile(tileIndex);
        }
      }
    });
  }
  
  double getFogOpacity(int tileIndex) {
    return fogOpacity[tileIndex] ?? 0.8;
  }
  
  void setFogOpacity(int tileIndex, double opacity) {
    fogOpacity[tileIndex] = opacity;
  }
  
  void createFogEffect(int tileIndex, Board board) {
    // Create visual fog effect on a tile
    GameTile tile = board.getTile(tileIndex);
    
    // Add fog overlay effect
    tile.add(
      ColorEffect(
        Colors.grey.withOpacity(0.7),
        EffectController(duration: 0.5),
        opacityFrom: 0.0,
        opacityTo: 0.7,
      ),
    );
  }
  
  void clearFogEffect(int tileIndex, Board board) {
    // Remove fog effect from a tile
    GameTile tile = board.getTile(tileIndex);
    
    // Remove fog overlay
    tile.children.whereType<ColorEffect>().forEach((effect) {
      if (effect.color == Colors.grey.withOpacity(0.7)) {
        effect.removeFromParent();
      }
    });
  }
  
  Map<String, dynamic> getVisibilityStats() {
    return {
      'visibleTiles': visibleTiles.length,
      'exploredTiles': exploredTiles.length,
      'totalTiles': Board.totalTiles,
      'explorationPercentage': (exploredTiles.length / Board.totalTiles * 100).round(),
    };
  }
  
  void reset() {
    visibleTiles.clear();
    exploredTiles.clear();
    fogOpacity.clear();
    
    // Reveal starting tiles
    revealTile(0); // Start tile
    revealTile(1); // First tile ahead
  }
  
  // Special fog of war abilities
  void scoutAhead(int playerPosition, Board board) {
    // Temporarily reveal tiles further ahead
    for (int i = baseVisibilityRange + 1; i <= baseVisibilityRange + 3; i++) {
      int scoutTile = playerPosition + i;
      if (scoutTile < Board.totalTiles) {
        board.revealTile(scoutTile);
        board.highlightTile(scoutTile, Colors.blue.withOpacity(0.5));
        
        // Hide after scouting duration
        Future.delayed(Duration(seconds: 5), () {
          if (!visibleTiles.contains(scoutTile)) {
            board.hideTile(scoutTile);
          }
          board.clearHighlight(scoutTile);
        });
      }
    }
  }
  
  void illuminateArea(int centerTile, int radius, Board board) {
    // Illuminate an area around a specific tile
    for (int i = centerTile - radius; i <= centerTile + radius; i++) {
      if (i >= 0 && i < Board.totalTiles) {
        board.revealTile(i);
        board.highlightTile(i, Colors.yellow.withOpacity(0.3));
        
        // Fade illumination after duration
        Future.delayed(Duration(seconds: 4), () {
          if (!visibleTiles.contains(i)) {
            board.hideTile(i);
          }
          board.clearHighlight(i);
        });
      }
    }
  }
}
