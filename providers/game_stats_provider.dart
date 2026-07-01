import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_stats.dart';

class GameStatsProvider extends ChangeNotifier {
  GameStats _stats = GameStats();
  SharedPreferences? _prefs;

  GameStatsProvider() {
    _loadStats();
  }

  GameStats get stats => _stats;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadStats() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString('game_stats');
    if (jsonString != null) {
      try {
        final decoded = jsonDecode(jsonString);
        if (decoded is Map<String, dynamic>) {
          _stats = GameStats.fromJson(decoded);
        } else if (decoded is Map) {
          _stats = GameStats.fromJson(Map<String, dynamic>.from(decoded));
        }
        notifyListeners();
      } catch (e) {
        // ignore and keep defaults
      }
    }
  }

  Future<void> saveStats() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('game_stats', jsonEncode(_stats.toJson()));
      notifyListeners();
    } catch (e) {
      // ignore write errors
    }
  }

  void updateStats(GameStats newStats) {
    _stats = newStats;
    saveStats();
    notifyListeners();
  }

  void resetStats() {
    _stats = GameStats();
    saveStats();
    notifyListeners();
  }

  void addGameResult({
    required int score,
    required int correct,
    required int wrong,
    required Map<String, int> operationCorrect,
    required Map<String, int> operationWrong,
  }) {
    final newHistory = List<int>.from(_stats.scoreHistory)..add(score);
    final accumulatedCorrect = Map<String, int>.from(_stats.operationCorrect);
    final accumulatedWrong = Map<String, int>.from(_stats.operationWrong);

    operationCorrect.forEach((operation, value) {
      accumulatedCorrect[operation] = (accumulatedCorrect[operation] ?? 0) + value;
    });
    operationWrong.forEach((operation, value) {
      accumulatedWrong[operation] = (accumulatedWrong[operation] ?? 0) + value;
    });

    _stats = _stats.copyWith(
      totalQuestions: _stats.totalQuestions + correct + wrong,
      correctAnswers: _stats.correctAnswers + correct,
      wrongAnswers: _stats.wrongAnswers + wrong,
      operationCorrect: accumulatedCorrect,
      operationWrong: accumulatedWrong,
      scoreHistory: newHistory,
    );
    saveStats();
    notifyListeners();
  }
}
