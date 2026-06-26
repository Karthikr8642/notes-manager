import 'package:flutter/material.dart';
import '../utils/animations.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Duration duration;

  const AnimatedFloatingActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.duration = AppAnimations.medium,
  }) : super(key: key);

  @override
  State<AnimatedFloatingActionButton> createState() => _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState extends State<AnimatedFloatingActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _scale = AppAnimations.softScale.animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton(
        backgroundColor: widget.backgroundColor ?? colorScheme.primary,
        onPressed: widget.onPressed,
        child: widget.child,
      ),
    );
  }
}
