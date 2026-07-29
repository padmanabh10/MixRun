import 'package:flutter/material.dart';

/// Central color palette for MixRun,  the **"Utsav Modern"** design system.
///
/// A "Festive Educational" aesthetic: light, airy warm-cream surfaces grounded
/// by saffron and deep-indigo accents (see DESIGN.md). Constant names follow the
/// design's roles rather than raw hues, so the same token stays meaningful as it
/// is reused across screens.
///
/// Note: several names carry historical meaning from the previous dark theme
/// (e.g. `nightTop`, `cream`). They are retained so the wider widget tree keeps
/// compiling, but their *values* now express the light Utsav palette,  the
/// "night" surfaces are warm-cream gradient stops and `cream` is the indigo ink.
abstract final class AppColors {
  // Brand accents.
  static const Color gold = Color(0xFFFF8A3D); // Saffron,  hero / primary action.
  static const Color goldLight = Color(0xFFFFA866); // Saffron highlight.
  static const Color goldDeep = Color(0xFF9A4600); // Deep saffron,  pressed / gradient end.
  static const Color orange = Color(0xFFF2722E); // Warm saffron-orange accent.
  static const Color brick = Color(0xFFC0532B); // Terracotta accent.
  static const Color teal = Color(0xFF55589B); // Indigo secondary (category accent).
  static const Color tealLight = Color(0xFF6E71B8); // Indigo secondary highlight.

  // Metallic soft gold,  used sparingly for celebratory borders / mandala work.
  static const Color metalGold = Color(0xFFD4AF37);
  static const Color metalGoldSoft = Color(0xFFE6C766);

  /// Exact cream of the bundled `logo.png` canvas,  used behind the logo on the
  /// splash and home so the artwork blends seamlessly with the background.
  static const Color logoCanvas = Color(0xFFFAEFDB);

  // Screen surfaces (warm-cream gradient stops for the "play" backgrounds).
  static const Color nightTop = Color(0xFFFFF8F0); // surface.
  static const Color nightMid = Color(0xFFFBF3E8);
  static const Color nightDeep = Color(0xFFF4EDE4); // surface-container.
  static const Color nightBase = Color(0xFFFFF8F0);
  static const Color libraryPanel = Color(0xFFF4EDE4); // surface-container panel.
  static const Color ringTrackFill = Color(0xFFEAE3D8); // pale progress track.

  // Primary ink placed on light surfaces (Deep Indigo per DESIGN.md typography).
  static const Color cream = Color(0xFF2B2D6E);

  // Light screen surfaces (cards sit on pure white above the cream canvas).
  static const Color parchmentTop = Color(0xFFFFF8F0);
  static const Color parchmentBottom = Color(0xFFF4EDE4);
  static const Color sheetTop = Color(0xFFFFFFFF);
  static const Color sheetBottom = Color(0xFFF9F3EA);
  static const Color tileTop = Color(0xFFFFFFFF);
  static const Color tileBottom = Color(0xFFF7F1E8);

  // Text on light surfaces,  Deep Indigo at descending opacities.
  static const Color cocoa = Color(0xFF2B2D6E); // Headers (100%).
  static const Color cocoaSoft = Color(0xFF3D4081); // Body (~85%).
  static const Color mutedBrown = Color(0xFF6E70A8); // Captions (~60%).
  static const Color fadedBrown = Color(0xFF9698C4); // Faded / hint.
  static const Color lockedBrown = Color(0xFFBDBFDC); // Locked / disabled.
  static const Color spiceBrown = Color(0xFF9A4600); // Deep-saffron accent text.

  // High-contrast text placed on saffron primary buttons (white per DESIGN.md).
  static const Color onGold = Color(0xFFFFFFFF);

  /// Indigo-tinted ambient shadow for elevated cards (Level 1).
  static const Color cardShadow = Color(0x0F2B2D6E); // ~6% Deep Indigo.
}
