import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;
  final double spacing;
  final double opacity;

  const GridBackground({
    super.key,
    required this.child,
    this.spacing = 32.0,
    this.opacity = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Izgara çizimi
        SizedBox.expand(
          child: CustomPaint(
            painter: _GridPainter(
              color: theme.colorScheme.onSurface.withOpacity(opacity),
              spacing: spacing,
            ),
          ),
        ),
        // Üstüne gelecek içerik
        child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _GridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
