import 'package:flutter/material.dart';
import 'menu_screen.dart';

class FinishScreen extends StatelessWidget {
  final int totalSteps;
  final Duration gameTime;

  const FinishScreen({
    Key? key,
    required this.totalSteps,
    required this.gameTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500), // Orange
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Victory Animation Container
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🏆',
                    style: TextStyle(fontSize: 80),
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // Congratulations Text
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
                child: Column(
                  children: [
                    Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You reached the finish line!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // Game Statistics
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Game Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('🚶', style: TextStyle(fontSize: 24)),
                            Text('$totalSteps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Steps', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('⏱️', style: TextStyle(fontSize: 24)),
                            Text('${gameTime.inMinutes}:${(gameTime.inSeconds % 60).toString().padLeft(2, '0')}', 
                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Time', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MenuScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text('Play Again'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MenuScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text('Main Menu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
