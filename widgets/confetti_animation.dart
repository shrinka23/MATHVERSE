import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  const ConfettiAnimation({Key? key}) : super(key: key);

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiPiece> _pieces = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    for (int i = 0; i < 50; i++) {
      _pieces.add(ConfettiPiece(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 4 + _random.nextDouble() * 8,
        speed: 0.5 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * 3.14,
        color: [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.pink,
          Colors.orange,
        ][_random.nextInt(7)],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(
              pieces: _pieces,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class ConfettiPiece {
  double x;
  double y;
  final double size;
  final double speed;
  double rotation;
  final Color color;

  ConfettiPiece({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.color,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;

  ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      final paint = Paint()
        ..color = piece.color
        ..style = PaintingStyle.fill;
      
      piece.rotation += 0.05;
      
      final yOffset = (progress * piece.speed * size.height) % size.height;
      final xOffset = sin(progress * 3 * 3.14 + piece.x * 10) * 100;
      
      final x = (piece.x * size.width + xOffset) % size.width;
      final y = (piece.y * size.height + yOffset) % size.height;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation);
      
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: piece.size,
        height: piece.size * 0.6,
      );
      canvas.drawRRect(
        RRect.fromRectXY(rect, 2, 2),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}