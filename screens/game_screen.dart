import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_state.dart';
import '../providers/game_stats_provider.dart';
import '../utils/level_manager.dart';
import '../utils/sound_manager.dart';
import '../widgets/floating_particles.dart';
import '../widgets/star_animation.dart';
import '../widgets/confetti_animation.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  Map<String, dynamic> _currentQuestion = {};
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _showLevelUp = false;
  bool _showConfetti = false;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  
  final Map<String, int> _operationCorrect = {
    'addition': 0,
    'subtraction': 0,
    'multiplication': 0,
    'division': 0,
    'algebra': 0,
  };
  final Map<String, int> _operationWrong = {
    'addition': 0,
    'subtraction': 0,
    'multiplication': 0,
    'division': 0,
    'algebra': 0,
  };
  
  List<int> _options = [];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _generateQuestion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    _currentQuestion = LevelManager.generateQuestion(gameState.currentLevel);
    _isAnswered = false;
    _answerController.clear();
    _generateOptions();
    setState(() {});
  }

  void _generateOptions() {
    final random = Random();
    final correctAnswer = _currentQuestion['answer'] as int;
    _options = [correctAnswer];
    
    while (_options.length < 4) {
      int option = correctAnswer + random.nextInt(21) - 10;
      if (option >= 0 && !_options.contains(option) && option != correctAnswer) {
        _options.add(option);
      }
    }
    _options.shuffle();
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    final soundManager = Provider.of<SoundManager>(context, listen: false);
    
    setState(() {
      _isAnswered = true;
      _isCorrect = _options[selectedIndex] == _currentQuestion['answer'];
    });
    
    if (_isCorrect) {
      soundManager.playCorrectSound();
      _bounceController.forward(from: 0);
      
      final operation = _currentQuestion['operation'] as String;
      _operationCorrect[operation] = (_operationCorrect[operation] ?? 0) + 1;
      gameState.answerQuestion(true);
      
      // Show confetti for good performance
      if (gameState.combo > 0 && gameState.combo % 3 == 0) {
        setState(() {
          _showConfetti = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _showConfetti = false;
          });
        });
      }
    } else {
      soundManager.playWrongSound();
      final operation = _currentQuestion['operation'] as String;
      _operationWrong[operation] = (_operationWrong[operation] ?? 0) + 1;
      gameState.answerQuestion(false);
    }
  }

  void _nextQuestion() {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    
    if (gameState.currentQuestion >= gameState.questionsPerLevel) {
      // Level complete
      gameState.completeLevel();
      _showLevelUpAnimation();
    } else {
      _generateQuestion();
      _focusNode.requestFocus();
    }
  }

  void _showLevelUpAnimation() {
    final soundManager = Provider.of<SoundManager>(context, listen: false);
    soundManager.playLevelUpSound();
    
    setState(() {
      _showLevelUp = true;
      _showConfetti = true;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showLevelUp = false;
        _showConfetti = false;
      });
      _goToNextLevel();
    });
  }

  void _goToNextLevel() {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    final statsProvider = Provider.of<GameStatsProvider>(context, listen: false);
    final stats = statsProvider.stats;
    
    // Save stats
    statsProvider.addGameResult(
      score: gameState.score,
      correct: gameState.correctAnswers,
      wrong: gameState.wrongAnswers,
      operationCorrect: _operationCorrect,
      operationWrong: _operationWrong,
    );
    
    // Update highest level
    if (gameState.currentLevel > stats.highestLevel) {
      statsProvider.updateStats(stats.copyWith(
        highestLevel: gameState.currentLevel,
        totalStars: stats.totalStars + gameState.stars,
      ));
    }
    
    // Check if all levels complete
    if (gameState.currentLevel >= 50) {
      _showGameOver();
      return;
    }
    
    gameState.nextLevel();
    _generateQuestion();
  }

  void _showGameOver() {
    final soundManager = Provider.of<SoundManager>(context, listen: false);
    soundManager.playGameOverSound();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🎉 Congratulations!',
          style: TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You completed all 50 levels!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              '🌟 You\'re a math genius! 🌟',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('⭐ Stars'),
                      Text(
                        '${Provider.of<GameStateProvider>(context).stars}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('🏆 Score'),
                      Text(
                        '${Provider.of<GameStateProvider>(context).score}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<GameStateProvider>(context, listen: false).reset();
              _generateQuestion();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final progress = gameState.currentQuestion / gameState.questionsPerLevel;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                  Colors.pink.shade100,
                ],
              ),
            ),
          ),
          
          // Floating particles background
          const FloatingParticles(),
          
          // Confetti
          if (_showConfetti) const ConfettiAnimation(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header
                  _buildHeader(gameState),
                  
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  _buildProgressBar(progress, gameState),
                  
                  const SizedBox(height: 20),
                  
                  // Level Info
                  _buildLevelInfo(gameState),
                  
                  const SizedBox(height: 16),
                  
                  // Question Card
                  _buildQuestionCard(gameState),
                  
                  const Spacer(),
                  
                  // Options
                  if (!_isAnswered)
                    _buildOptions()
                  else
                    _buildAnswerFeedback(),
                  
                  const SizedBox(height: 16),
                  
                  // Next Button
                  if (_isAnswered)
                    _buildNextButton(),
                  
                  // Level Up Animation
                  if (_showLevelUp)
                    _buildLevelUpAnimation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '⭐',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${gameState.stars}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🔥 ${gameState.combo}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '✅',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${gameState.correctAnswers}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '❌',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${gameState.wrongAnswers}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, GameStateProvider gameState) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${gameState.currentLevel}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              '${gameState.currentQuestion}/${gameState.questionsPerLevel}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.white.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.blue;
    if (progress < 0.6) return Colors.orange;
    if (progress < 0.8) return Colors.purple;
    return Colors.green;
  }

  Widget _buildLevelInfo(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${gameState.getLevelEmoji()} ',
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            gameState.getLevelName(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Level ${gameState.currentLevel}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(GameStateProvider gameState) {
    final isAlgebra = gameState.currentLevel > 40;
    final displayText = _currentQuestion['text'] as String? ?? '?';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
        border: _isAnswered
            ? Border.all(
                color: _isCorrect ? Colors.green : Colors.red,
                width: 4,
              )
            : null,
      ),
      child: Column(
        children: [
          if (isAlgebra)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🧮 Algebra',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isAnswered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isCorrect ? '✅' : '❌',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCorrect
                        ? 'Correct! +${10 + (gameState.combo ~/ 3) * 5} points'
                        : 'Oops! Answer: ${_currentQuestion['displayAnswer']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate(
      target: _isAnswered ? 1 : 0,
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: 300.ms,
    );
  }

  Widget _buildOptions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _options.length,
      itemBuilder: (context, index) {
        return _buildOptionButton(index);
      },
    );
  }

  Widget _buildOptionButton(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return ElevatedButton(
          onPressed: () => _checkAnswer(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            '${_options[index]}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerFeedback() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isCorrect ? '🎉 Great Job!' : '💪 Keep Trying!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green : Colors.orange,
            ),
          ),
          if (_isCorrect && Provider.of<GameStateProvider>(context).combo >= 3)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                '🔥🔥🔥',
                style: TextStyle(fontSize: 24),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Next Question ➜',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelUpAnimation() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 60),
              ).animate()
                .scale(
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .rotate(
                  duration: 1000.ms,
                  curve: Curves.linear,
                ),
              const SizedBox(height: 16),
              Text(
                'Level ${Provider.of<GameStateProvider>(context).currentLevel} Complete!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'re on fire! 🔥',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              const StarAnimation(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('⭐ Stars'),
                        Text(
                          '${Provider.of<GameStateProvider>(context).stars}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('📊 Score'),
                        Text(
                          '${Provider.of<GameStateProvider>(context).score}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('🔥 Combo'),
                        Text(
                          '${Provider.of<GameStateProvider>(context).maxCombo}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}