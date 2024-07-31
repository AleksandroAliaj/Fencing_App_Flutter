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
          children: [
            TextField(
              controller: _player1Controller,
              decoration: const InputDecoration(
                labelText: 'Giocatore 1',
              ),
            ),
            TextField(
              controller: _player2Controller,
              decoration: const InputDecoration(
                labelText: 'Giocatore 2',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      _player1Controller.text.isEmpty
                          ? 'Giocatore 1'
                          : _player1Controller.text,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      '$_player1Score',
                      style: const TextStyle(fontSize: 40),
                    ),
                    ElevatedButton(
                      onPressed: _incrementScore1,
                      child: const Text('+1 punto'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _player2Controller.text.isEmpty
                          ? 'Giocatore 2'
                          : _player2Controller.text,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      '$_player2Score',
                      style: const TextStyle(fontSize: 40),
                    ),
                    ElevatedButton(
                      onPressed: _incrementScore2,
                      child: const Text('+1 punto'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetScores,
              child: const Text('Resetta punteggi'),
            ),
            const SizedBox(height: 20),
            if (_player1Score == 15 || _player2Score == 15)
              Text(
                _player1Score == 15
                    ? '${_player1Controller.text.isEmpty ? 'Giocatore 1' : _player1Controller.text} ha vinto!'
                    : '${_player2Controller.text.isEmpty ? 'Giocatore 2' : _player2Controller.text} ha vinto!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
