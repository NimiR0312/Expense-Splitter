import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ================= LIGHT THEME (NAVY BLUE) =================
  static const Color navyPrimary = Color(0xFF0F2042); // Deep Royal Navy
  static const Color navySecondary = Color(0xFF1E3A8A); // Mid Navy Blue
  static const Color navyAccent = Color(0xFF2563EB); // Vibrant Accent Blue
  static const Color navyLight = Color(0xFFE0E7FF); // Soft Tint Navy

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // ================= DARK THEME (TURQUOISE / CYAN) =================
  static const Color turquoisePrimary = Color(0xFF14B8A6); // Vibrant Teal/Turquoise
  static const Color turquoiseSecondary = Color(0xFF0D9488); // Deep Teal
  static const Color turquoiseAccent = Color(0xFF2DD4BF); // Bright Electric Turquoise
  static const Color turquoiseLight = Color(0xFF134E4A); // Muted Dark Teal Tint

  static const Color darkBackground = Color(0xFF090D16); // Obsidian Midnight
  static const Color darkSurface = Color(0xFF111827); // Deep Charcoal
  static const Color darkCard = Color(0xFF1E293B); // Slate Dark Surface
  static const Color darkBorder = Color(0xFF334155);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // ================= FUNCTIONAL STATUS COLORS =================
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color danger = Color(0xFFEF4444); // Crimson Rose
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Backwards compatibility aliases
  static const primary = navyPrimary;
  static const secondary = success;
  static const admin = warning;
  static const background = lightBackground;
  static const card = lightCard;
}
