import 'package:flutter/material.dart';

class ModernAppTheme {
  static ThemeData lightTheme(ColorScheme? dynamicScheme) {
    final colorScheme = dynamicScheme ?? ColorScheme.fromSeed(seedColor: Colors.indigo);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: colorScheme.onBackground,
            displayColor: colorScheme.onBackground,
          ),
    );
  }

  static ThemeData darkTheme(ColorScheme? dynamicScheme) {
    final colorScheme = dynamicScheme ?? ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
      ),
      textTheme: Typography.material2021().white.apply(
            bodyColor: colorScheme.onBackground,
            displayColor: colorScheme.onBackground,
          ),
    );
  }
}
