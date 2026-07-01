import 'dart:math';
import 'package:flutter/material.dart';

class StarAnimation extends StatefulWidget {
  const StarAnimation({Key? key}) : super(key: key);

  @override
  State<StarAnimation> createState() => _StarAnimationState();
}

class _StarAnimationState extends State<StarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 0.6 + 0.4 * sin(_controller.value * 3.14 + index * 1.2);
            return Transform.scale(
              scale: scale,
              child: const Text(
                '⭐',
                style: TextStyle(fontSize: 32),
              ),
            );
          },
        );
      }),
    );
  }
}