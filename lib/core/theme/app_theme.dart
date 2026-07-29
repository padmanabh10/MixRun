import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized theme for MixRun,  light "Utsav Modern" (see DESIGN.md).
///
/// The app paints its own warm-cream gradient backgrounds per screen, so the
/// theme's main job is to supply a harmonious [ColorScheme] seeded from the
/// deep-saffron primary and a `Plus Jakarta Sans` based [TextTheme] for default
/// text.
abstract final class AppTheme {
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9A4600), // Deep saffron primary.
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.goldDeep,
      secondary: AppColors.teal,
      surface: AppColors.nightTop,
      onSurface: AppColors.cocoa,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.parchmentTop,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      useMaterial3: true,
    );
  }
}
