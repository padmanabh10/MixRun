import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography helpers for MixRun's two type families (DESIGN.md "Utsav Modern").
///
/// `Bricolage Grotesque` is the high-character display face used for headings,
/// numbers and buttons; `Plus Jakarta Sans` is the rounded, friendly body face
/// used for descriptions and inputs.
///
/// Neither Latin face ships Devanagari glyphs, so `Baloo 2` / `Mukta` are kept
/// as `fontFamilyFallback`. This preserves the bilingual experience: Hindi text
/// renders with full Indic support while Latin text uses the Utsav faces.
abstract final class AppText {
  /// Lazily-resolved Devanagari fallback family names.
  static final String _displayFallback = GoogleFonts.baloo2().fontFamily!;
  static final String _bodyFallback = GoogleFonts.mukta().fontFamily!;

  /// A `Bricolage Grotesque` style. Used for titles, labels and interactive
  /// elements.
  static TextStyle display({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      textStyle: TextStyle(fontFamilyFallback: <String>[_displayFallback]),
    );
  }

  /// A `Plus Jakarta Sans` style. Used for body copy and text fields.
  static TextStyle body({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      textStyle: TextStyle(fontFamilyFallback: <String>[_bodyFallback]),
    );
  }
}
