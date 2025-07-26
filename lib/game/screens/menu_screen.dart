import 'package:flutter/material.dart';
import '../../main.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFF98FB98), // Pale green
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Title
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Board Game\nAdventure',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              
              // Start Game Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GameWrapper()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Start Adventure',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Instructions
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🌱 Plant seeds to gain energy\n🎲 Roll dice to move forward\n🛤️ Choose your path wisely\n🏁 Reach the finish line!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
