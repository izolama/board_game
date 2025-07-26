import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/my_game.dart';
import 'game/screens/menu_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board Game Adventure',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Courier', // Pixel-style font
      ),
      home: MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameWrapper extends StatefulWidget {
  @override
  _GameWrapperState createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late MyGame game;

  @override
  void initState() {
    super.initState();
    game = MyGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}
