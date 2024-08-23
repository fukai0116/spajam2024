import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数当てゲーム',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NumberGuessingGame(),
    );
  }
}

class NumberGuessingGame extends StatefulWidget {
  @override
  _NumberGuessingGameState createState() => _NumberGuessingGameState();
}

class _NumberGuessingGameState extends State<NumberGuessingGame> {
  final Random _random = Random();
  int _targetNumber = 0;
  String _message = '';
  int _attempts = 0;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _targetNumber = _random.nextInt(100) + 1;
      _message = '1から100までの数字を当ててください';
      _attempts = 0;
      _controller.clear();
    });
  }

  void _checkGuess() {
    int? guess = int.tryParse(_controller.text);
    if (guess == null) {
      setState(() {
        _message = '有効な数字を入力してください';
      });
      return;
    }

    setState(() {
      _attempts++;
      if (guess == _targetNumber) {
        _message = 'おめでとう！$_attemptsの試行で数字を当てました！';
      } else if (guess < _targetNumber) {
        _message = 'もっと大きい数字です';
      } else {
        _message = 'もっと小さい数字です';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('数当てゲーム'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _message,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '数字を入力',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('推測する'),
              onPressed: _checkGuess,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('新しいゲームを開始'),
              onPressed: _startNewGame,
            ),
          ],
        ),
      ),
    );
  }
}