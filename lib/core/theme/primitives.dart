import 'package:flutter/painting.dart';

/// Tier-1 colour primitives for the Hilal palette.
///
/// Each name is a hue family plus its approximate OKLCH lightness ×100, so a
/// new shade slots in by value. This is the only file in the app allowed a raw
/// colour literal. Widgets never read these directly; they read the semantic
/// slots on `AppColors`.
abstract final class Primitives {
  // Night blues: brand, dark surfaces.
  static const indigo12 = Color(0xFF0B1022);
  static const indigo16 = Color(0xFF0E1426);
  static const indigo22 = Color(0xFF18213A);
  static const indigo27 = Color(0xFF1E2A4A);
  static const indigo31 = Color(0xFF22305A);
  static const indigo35 = Color(0xFF26304D);

  // Ink and muted text.
  static const slate24 = Color(0xFF1A1F2E);
  static const slate50 = Color(0xFF5E6475);
  static const slate74 = Color(0xFFA9AEBD);

  // Ivory grounds.
  static const ivory89 = Color(0xFFE7E0CF);
  static const ivory93 = Color(0xFFECE7DA);
  static const ivory96 = Color(0xFFF6F2E9);
  static const ivory99 = Color(0xFFFFFDF8);

  // Moon gold.
  static const gold38 = Color(0xFF6B4A0E);
  static const gold75 = Color(0xFFD9A441);
  static const gold80 = Color(0xFFE6B85C);
  static const gold92 = Color(0xFFF1E4C4);
  static const gold30 = Color(0xFF3A2C10);

  // Fasting-day hues, light and dark variants.
  static const violet40 = Color(0xFF5B3A8C);
  static const violet74 = Color(0xFFB49AE0);
  static const clay48 = Color(0xFFA8452F);
  static const clay72 = Color(0xFFE08A6E);
  static const teal50 = Color(0xFF1F7A72);
  static const teal76 = Color(0xFF5FC2B5);
  static const moon86 = Color(0xFFCDD3DF);
  static const moon91 = Color(0xFFDDE2EC);
  static const moon32 = Color(0xFF343C52);

  // Daytime sky.
  static const sky68 = Color(0xFF7FA7D6);

  // Errors.
  static const red45 = Color(0xFFB3261E);
  static const red80 = Color(0xFFF2B8B5);
  static const red20 = Color(0xFF601410);

  static const white = Color(0xFFFFFFFF);
}
