import 'package:flutter/material.dart';

/// Warm paper background, terracotta accent, serif headings: the Claude look.
ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFD97757),
    brightness: b,
  ).copyWith(
    primary: const Color(0xFFD97757),
    onPrimary: Colors.white,
    surface: dark ? const Color(0xFF262624) : const Color(0xFFFAF9F5),
    onSurface: dark ? const Color(0xFFF1EFE8) : const Color(0xFF29261F),
    surfaceContainerHighest:
        dark ? const Color(0xFF3A3935) : const Color(0xFFEFEDE4),
    surfaceContainerLowest:
        dark ? const Color(0xFF30302E) : const Color(0xFFFFFFFF),
    outlineVariant: dark ? const Color(0xFF454440) : const Color(0xFFE5E2D8),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontFamily: 'serif', fontSize: 18, color: scheme.onSurface),
    ),
  );
}
