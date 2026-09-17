import 'package:flutter/material.dart';

/// StockPulse's comprehensive Light and Dark theme color palette.
class AppColors {
  AppColors._();

  // ==================== BRAND COLORS ====================
  static const Color primary = Color(0xFF0F766E); // Deep Teal (Light)
  static const Color primaryDark = Color(0xFF115E59);
  static const Color secondary = Color(0xFF14263D); // Midnight Navy
  static const Color accent = Color(0xFFD5A84B); // Muted Gold

  // ==================== LIGHT THEME COLORS ====================
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(
    0xFFF1F5F9,
  ); // Field & card background
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x140F2A35);

  static const Color textPrimary = Color(0xFF0F172A); // High-contrast slate
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);
  static const Color glow = Color(0x1A0F766E);

  // ==================== DARK THEME COLORS ====================
  static const Color darkPrimary = Color(0xFF14B8A6); // Vibrant Teal Accent
  static const Color darkPrimaryDark = Color(0xFF0F766E);
  static const Color darkSecondary = Color(0xFF1E293B);
  static const Color darkAccent = Color(0xFFF59E0B);

  static const Color darkBackground = Color(0xFF0B111D); // Deep Obsidian
  static const Color darkSurface = Color(0xFF131D2E); // Elevated Card Slate
  static const Color darkSurfaceMuted = Color(0xFF111A2E); // Field input fill
  static const Color darkCard = Color(0xFF131D2E);
  static const Color darkCardShadow = Color(0x40000000);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextHint = Color(0xFF64748B);

  static const Color darkBorder = Color(0xFF1E2D44);
  static const Color darkDivider = Color(0xFF1A263A);
  static const Color darkGlow = Color(0x3D0F766E);
  static const Color darkError = Color(0xFFFF6B6B);

  // ==================== STATUS & BUSINESS ====================
  static const Color sales = Color(0xFF0F766E);
  static const Color purchases = Color(0xFF2563EB);
  static const Color profit = Color(0xFF15803D);
  static const Color expense = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color lowStock = warning;

  // ==================== ONBOARDING ====================
  static const Color onboardingLight = Color(0xFFEAF7F5);
  static const Color onboardingDark = Color(0xFF0B111D);

  // ==================== GRADIENTS ====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
