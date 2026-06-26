import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? color;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = color ?? scheme.surface.withOpacity(0.6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 6),
              )
            ],
            border: Border.all(
              color: scheme.onSurface.withOpacity(0.06),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
