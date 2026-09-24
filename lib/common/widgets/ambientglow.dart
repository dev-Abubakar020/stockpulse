import 'package:flutter/material.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.glowColor,
  });

  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Top Right Glow
          Positioned(
            top: -100,
            right: -80,
            child: _GlowOrb(
              size: 320,
              color: glowColor,
            ),
          ),

          // Bottom Left Glow
          Positioned(
            bottom: 0,
            left: -80,
            child: _GlowOrb(
              size: 300,
              color: glowColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}