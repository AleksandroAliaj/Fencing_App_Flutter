// ignore_for_file: use_super_parameters, library_private_types_in_public_api, sort_child_properties_last

import 'package:flutter/material.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({Key? key}) : super(key: key);

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  int _player1Score = 0;
  int _player2Score = 0;

  void _incrementScore1() {
    setState(() {
      if (_player1Score < 15) _player1Score++;
    });
  }

  void _incrementScore2() {
    setState(() {
      if (_player2Score < 15) _player2Score++;
    });
  }

  void _resetScores() {
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segna punteggio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Section for player names
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _player1Controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nome Giocatore 1',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _player2Controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nome Giocatore 2',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Section for score display and increment buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreCard(
                  playerName: _player1Controller.text.isEmpty ? 'Giocatore 1' : _player1Controller.text,
                  score: _player1Score,
                  onIncrement: _incrementScore1,
                ),
                _buildScoreCard(
                  playerName: _player2Controller.text.isEmpty ? 'Giocatore 2' : _player2Controller.text,
                  score: _player2Score,
                  onIncrement: _incrementScore2,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Reset button
            ElevatedButton(
              onPressed: _resetScores,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              ),
              child: const Text('Resetta punteggi'),
            ),
            const SizedBox(height: 20),

            // Winner display
            if (_player1Score == 15 || _player2Score == 15)
              Text(
                _player1Score == 15
                    ? '${_player1Controller.text.isEmpty ? 'Giocatore 1' : _player1Controller.text} ha vinto!'
                    : '${_player2Controller.text.isEmpty ? 'Giocatore 2' : _player2Controller.text} ha vinto!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build score cards
  Widget _buildScoreCard({
    required String playerName,
    required int score,
    required VoidCallback onIncrement,
  }) {
    return Expanded(
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                playerName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                '$score',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onIncrement,
                child: const Text('+1 punto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
