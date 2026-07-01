import 'package:flutter/material.dart';

class GameStateProvider extends ChangeNotifier {
  int _currentLevel = 1;
  int _currentQuestion = 0;
  int _score = 0;
  int _stars = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  bool _isGameOver = false;
  bool _isLevelComplete = false;
  
  int get currentLevel => _currentLevel;
  int get currentQuestion => _currentQuestion;
  int get score => _score;
  int get stars => _stars;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  bool get isGameOver => _isGameOver;
  bool get isLevelComplete => _isLevelComplete;

  void startNewGame() {
    _currentLevel = 1;
    _currentQuestion = 0;
    _score = 0;
    _stars = 0;
    _combo = 0;
    _maxCombo = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _isGameOver = false;
    _isLevelComplete = false;
    notifyListeners();
  }

  void startNewLevel() {
    _currentQuestion = 0;
    _isLevelComplete = false;
    notifyListeners();
  }

  void answerQuestion(bool isCorrect) {
    if (isCorrect) {
      _correctAnswers++;
      _combo++;
      if (_combo > _maxCombo) {
        _maxCombo = _combo;
      }
      
      // Bonus points for combo
      int points = 10 + (_combo ~/ 3) * 5;
      _score += points;
      
      // Star for every 5 correct answers in a row
      if (_combo % 5 == 0) {
        _stars++;
      }
    } else {
      _wrongAnswers++;
      _combo = 0;
    }
    _currentQuestion++;
    notifyListeners();
  }

  void completeLevel() {
    _isLevelComplete = true;
    // Bonus stars for level completion
    if (_correctAnswers >= 8) {
      _stars += 3;
    } else if (_correctAnswers >= 6) {
      _stars += 2;
    } else if (_correctAnswers >= 4) {
      _stars += 1;
    }
    notifyListeners();
  }

  void nextLevel() {
    _currentLevel++;
    _currentQuestion = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _isLevelComplete = false;
    _combo = 0;
    notifyListeners();
  }

  void gameOver() {
    _isGameOver = true;
    notifyListeners();
  }

  void reset() {
    _currentLevel = 1;
    _currentQuestion = 0;
    _score = 0;
    _stars = 0;
    _combo = 0;
    _maxCombo = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _isGameOver = false;
    _isLevelComplete = false;
    notifyListeners();
  }

  int get questionsPerLevel {
    if (_currentLevel <= 10) return 5;
    if (_currentLevel <= 20) return 6;
    if (_currentLevel <= 30) return 7;
    if (_currentLevel <= 40) return 8;
    return 10;
  }

  String getLevelType() {
    if (_currentLevel <= 10) return 'addition';
    if (_currentLevel <= 20) return 'subtraction';
    if (_currentLevel <= 30) return 'multiplication';
    if (_currentLevel <= 40) return 'division';
    return 'algebra';
  }

  String getLevelEmoji() {
    if (_currentLevel <= 10) return '➕';
    if (_currentLevel <= 20) return '➖';
    if (_currentLevel <= 30) return '✖️';
    if (_currentLevel <= 40) return '➗';
    return '🔢';
  }

  String getLevelName() {
    if (_currentLevel <= 10) return 'Addition';
    if (_currentLevel <= 20) return 'Subtraction';
    if (_currentLevel <= 30) return 'Multiplication';
    if (_currentLevel <= 40) return 'Division';
    return 'Algebra';
  }
}