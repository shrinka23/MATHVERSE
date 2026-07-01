import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/sound_manager.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soundManager = Provider.of<SoundManager>(context, listen: false);
      soundManager.playBackgroundMusic();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade700,
              Colors.pink.shade600,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated character/logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🧮',
                    style: TextStyle(fontSize: 80),
                  ),
                ),
              ).animate()
                .scale(duration: 1000.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 1500.ms),
              
              const SizedBox(height: 30),
              
              const Text(
                'Math Adventure',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black26,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
              
              const Text(
                'Learn math the fun way! 🚀',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ).animate()
                .fadeIn(delay: 400.ms),
              
              const SizedBox(height: 50),
              
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ).animate()
                .fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}