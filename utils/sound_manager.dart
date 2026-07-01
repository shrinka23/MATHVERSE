import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundManager extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  SoundManager() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load from shared preferences
    _isSoundEnabled = true;
    _isMusicEnabled = true;
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    if (!_isMusicEnabled) {
      _audioPlayer.stop();
    }
    notifyListeners();
  }

  Future<void> playCorrectSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('audio/correct_answer.mp3'));
    } catch (e) {
      // Silently fail if asset doesn't exist
    }
  }

  Future<void> playWrongSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('audio/wrong_answer.mp3'));
    } catch (e) {
      // Silently fail if asset doesn't exist
    }
  }

  Future<void> playLevelUpSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('audio/level_up.mp3'));
    } catch (e) {
      // Silently fail if asset doesn't exist
    }
  }

  Future<void> playGameOverSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('audio/game_over.mp3'));
    } catch (e) {
      // Silently fail if asset doesn't exist
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      // Silently fail if asset doesn't exist
    }
  }

  void stopBackgroundMusic() {
    _audioPlayer.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}