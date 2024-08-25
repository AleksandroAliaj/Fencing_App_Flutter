// ignore_for_file: use_super_parameters, library_private_types_in_public_api, sort_child_properties_last

import 'dart:async';
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
  int _remainingSeconds = 180; // 3 minutes
  Timer? _timer;
  bool _isGameOver = false;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      if (_isTimerRunning) {
        _timer?.cancel();
        _isTimerRunning = false;
      } else {
        _startTimer();
        _isTimerRunning = true;
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isGameOver = true;
          _isTimerRunning = false;
        }
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _remainingSeconds = 180;
      _isTimerRunning = false;
      _isGameOver = false;
    });
  }

  void _incrementScore(int playerIndex) {
    if (_isGameOver) return;
    setState(() {
      if (playerIndex == 1 && _player1Score < 15) {
        _player1Score++;
      } else if (playerIndex == 2 && _player2Score < 15) {
        _player2Score++;
      }
      if (_player1Score == 15 || _player2Score == 15) {
        _timer?.cancel();
        _isGameOver = true;
        _isTimerRunning = false;
      }
    });
  }

  void _resetGame() {
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
      _remainingSeconds = 180;
      _isGameOver = false;
      _isTimerRunning = false;
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getWinnerText() {
    if (_player1Score > _player2Score) {
      return '${_player1Controller.text.isEmpty ? 'Giocatore 1' : _player1Controller.text} ha vinto!';
    } else if (_player2Score > _player1Score) {
      return '${_player2Controller.text.isEmpty ? 'Giocatore 2' : _player2Controller.text} ha vinto!';
    } else {
      return 'Pareggio!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segna punteggio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerDisplay(),
              const SizedBox(height: 20),
              _buildTimerControls(),
              const SizedBox(height: 20),
              _buildPlayerNameInputs(),
              const SizedBox(height: 20),
              _buildScoreCards(),
              const SizedBox(height: 20),
              _buildResetButton(),
              const SizedBox(height: 20),
              if (_isGameOver) _buildWinnerDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _remainingSeconds <= 30 ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _isGameOver ? null : _toggleTimer,
          child: Text(
            _isTimerRunning ? 'Pausa' : 'Avvia',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTimerRunning ? Colors.orange : Colors.green,
          ),
        ),
        ElevatedButton(
          onPressed: _isGameOver ? null : _resetTimer,
          child: const Text(
            'Resetta Timer',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerNameInputs() {
    return Column(
      children: [
        TextField(
          controller: _player1Controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelText: 'Nome Giocatore 1',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _player2Controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelText: 'Nome Giocatore 2',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreCard(
          playerName: _player1Controller.text.isEmpty ? 'Giocatore 1' : _player1Controller.text,
          score: _player1Score,
          onIncrement: () => _incrementScore(1),
          color: Colors.blue,
        ),
        _buildScoreCard(
          playerName: _player2Controller.text.isEmpty ? 'Giocatore 2' : _player2Controller.text,
          score: _player2Score,
          onIncrement: () => _incrementScore(2),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required String playerName,
    required int score,
    required VoidCallback onIncrement,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isGameOver ? null : onIncrement,
                child: const Text(
                  '+1 punto',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  backgroundColor: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _resetGame,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        backgroundColor: Colors.red,
      ),
      child: const Text(
        'Nuova Partita',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildWinnerDisplay() {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _getWinnerText(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}