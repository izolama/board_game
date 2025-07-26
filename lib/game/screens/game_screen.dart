import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import '../my_game.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MyGame game;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    game = MyGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              // Kembali ke menu
              Navigator.of(context).pop();
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              // Plant seed
              game.plantSeed();
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              // Roll dice
              if (game.canRollDice()) {
                game.rollDice();
              }
            } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
              // Toggle music
              game.toggleSound();
            }
          }
        },
        child: Stack(
          children: [
            // Game Canvas
            GameWidget(game: game),

            // UI Overlay
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Energy Display
                    Column(
                      children: [
                        Text('Energy',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          width: 100,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: game.player?.energy ?? 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Position Display
                    Column(
                      children: [
                        Text('Position',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${game.player?.currentTileIndex ?? 0}',
                            style: TextStyle(fontSize: 18, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Game Controls
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Plant Seed Button
                    ElevatedButton.icon(
                      onPressed: () => game.plantSeed(),
                      icon: Text('🌱'),
                      label: Text('Plant Seed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // Roll Dice Button
                    ElevatedButton.icon(
                      onPressed:
                          game.canRollDice() ? () => game.rollDice() : null,
                      icon: Text('🎲'),
                      label: Text('Roll Dice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
