import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_stats.dart';
import '../providers/game_stats_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<GameStatsProvider>(context);
    final stats = statsProvider.stats;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade800,
              Colors.pink.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      '📊 Statistics',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Overall Stats
                        _buildOverallStats(stats),
                        const SizedBox(height: 16),
                        
                        // Operation Performance
                        _buildOperationPerformance(stats),
                        const SizedBox(height: 16),
                        
                        // Progress Chart
                        _buildProgressChart(stats),
                        const SizedBox(height: 16),
                        
                        // Score History
                        _buildScoreHistory(stats),
                        const SizedBox(height: 16),
                        
                        // Achievements
                        _buildAchievements(stats),
                        const SizedBox(height: 16),
                        
                        // Clear Data
                        _buildClearButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats(GameStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Overall Performance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '⭐ Stars',
                  stats.totalStars.toString(),
                  Colors.amber,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '🏆 Highest Level',
                  stats.highestLevel.toString(),
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '🎯 Accuracy',
                  '${stats.accuracy.toStringAsFixed(0)}%',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '📚 Questions',
                  stats.totalQuestions.toString(),
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '✅ Correct',
                  stats.correctAnswers.toString(),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '❌ Wrong',
                  stats.wrongAnswers.toString(),
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationPerformance(GameStats stats) {
    final opAccuracy = stats.operationAccuracy;
    final opNames = {
      'addition': '➕ Addition',
      'subtraction': '➖ Subtraction',
      'multiplication': '✖️ Multiplication',
      'division': '➗ Division',
      'algebra': '🔢 Algebra',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Performance by Operation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...opNames.entries.map((entry) {
            final op = entry.key;
            final name = entry.value;
            final accuracy = opAccuracy[op] ?? 0;
            final total = (stats.operationCorrect[op] ?? 0) + 
                         (stats.operationWrong[op] ?? 0);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$total questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${accuracy.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accuracy >= 70 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: accuracy / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accuracy >= 70 ? Colors.green : Colors.orange,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate()
      .fadeIn(delay: 200.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildProgressChart(GameStats stats) {
    if (stats.scoreHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '🎮 Play some games to see your progress!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Progress Chart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: stats.scoreHistory.length.toDouble() - 1,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: stats.scoreHistory.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 4,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.purple,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 400.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildScoreHistory(GameStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Recent Scores',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (stats.scoreHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No scores yet! 🎮',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...stats.scoreHistory.reversed.take(10).map((score) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 30,
                      decoration: BoxDecoration(
                        color: score >= 70 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Score: $score',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(
                      score >= 70 ? Icons.star : Icons.school,
                      color: score >= 70 ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate()
      .fadeIn(delay: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildAchievements(GameStats stats) {
    final achievements = [
      {
        'icon': '🌟',
        'title': 'First Steps',
        'description': 'Complete your first game',
        'unlocked': stats.totalQuestions > 0,
      },
      {
        'icon': '⭐',
        'title': 'Star Collector',
        'description': 'Earn 10 stars',
        'unlocked': stats.totalStars >= 10,
      },
      {
        'icon': '🏆',
        'title': 'Level Master',
        'description': 'Reach level 25',
        'unlocked': stats.highestLevel >= 25,
      },
      {
        'icon': '🔥',
        'title': 'On Fire!',
        'description': 'Get 10 correct in a row',
        'unlocked': false, // Would need combo tracking
      },
      {
        'icon': '🎯',
        'title': 'Perfect Accuracy',
        'description': 'Achieve 90% accuracy',
        'unlocked': stats.accuracy >= 90 && stats.totalQuestions > 10,
      },
      {
        'icon': '👑',
        'title': 'Math Champion',
        'description': 'Complete all 50 levels',
        'unlocked': stats.highestLevel >= 50,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏅 Achievements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final unlocked = achievement['unlocked'] as bool;
              
              return Container(
                decoration: BoxDecoration(
                  color: unlocked ? Colors.white : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: unlocked ? Colors.pink.shade300 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : 0.3,
                      child: Text(
                        achievement['icon'] as String,
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['title'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: unlocked ? Colors.pink.shade900 : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      unlocked ? '✅' : '🔒',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 800.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildClearButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                '⚠️ Clear All Data?',
                style: TextStyle(color: Colors.red),
              ),
              content: const Text(
                'This will permanently delete all your game statistics. Are you sure?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                    onPressed: () {
                    final statsProvider = Provider.of<GameStatsProvider>(context, listen: false);
                    statsProvider.resetStats();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🗑️ Data cleared!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Clear Data'),
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text('🗑️ Clear All Data'),
      ),
    ).animate()
      .fadeIn(delay: 1000.ms)
      .slideY(begin: 0.2, end: 0);
  }
}