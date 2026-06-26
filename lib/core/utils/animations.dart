import 'package:flutter/animation.dart';

class AppAnimations {
  AppAnimations._();

  static const Curve smoothEase = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Curve spring = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Duration short = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 360);
  static const Duration long = Duration(milliseconds: 520);

  static final Tween<double> softScale = Tween(begin: 0.96, end: 1.0);
  static final Tween<double> fadeIn = Tween(begin: 0.0, end: 1.0);
}
