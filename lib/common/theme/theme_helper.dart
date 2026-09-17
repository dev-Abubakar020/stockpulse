import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/utils/app_colors.dart';

/// StockPulse Theme Helper
///
/// Provides single-line conditional resolution between light and dark modes:
///
/// Example 1: Check if dark mode
/// ```dart
/// final isDark = context.isDark;
/// // or
/// final isDark = AppThemeHelper.isDarkMode(context);
/// ```
///
/// Example 2: One-liner light : dark resolver
/// ```dart
/// final color = context.themeValue(light: Colors.white, dark: Color(0xFF131D2E));
/// // or
/// final color = AppThemeHelper.value(context, light: Colors.white, dark: Colors.black);
/// ```
///
/// Example 3: Pre-resolved dynamic colors for current theme
/// ```dart
/// final theme = context.theme; // or AppThemeHelper.of(context)
/// final bg = theme.background;
/// final surface = theme.surface;
/// final text = theme.textPrimary;
/// final border = theme.border;
/// ```
///
/// Example 4: Toggle theme from anywhere (Settings switch, button, etc.)
/// ```dart
/// ThemeController.to.toggleTheme();
/// ```
class AppThemeHelper {
  final BuildContext context;
  final bool isDark;

  AppThemeHelper._(this.context, this.isDark);

  factory AppThemeHelper.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppThemeHelper._(context, isDark);
  }

  /// Check if the current context is in Dark Mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Resolves value conditionally: `isDark ? dark : light`
  static T value<T>(BuildContext context, {required T light, required T dark}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }

  /// Instance resolver: `theme.resolve(light: ..., dark: ...)`
  T resolve<T>({required T light, required T dark}) {
    return isDark ? dark : light;
  }

  // ==================== DYNAMIC RESOLVED COLORS ====================

  /// App background
  Color get background =>
      isDark ? AppColors.darkBackground : AppColors.background;

  /// Card / surface background
  Color get surface => isDark ? AppColors.darkSurface : AppColors.surface;

  /// Elevated Card surface
  Color get card => isDark ? AppColors.darkCard : AppColors.card;

  /// Muted surface for textfields and secondary containers
  Color get surfaceMuted =>
      isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;

  /// Primary heading & title text
  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  /// Secondary description text
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  /// Placeholder and hint text
  Color get textHint => isDark ? AppColors.darkTextHint : AppColors.textHint;

  /// Subtle container and field borders
  Color get border => isDark ? AppColors.darkBorder : AppColors.border;

  /// Dividing lines
  Color get divider => isDark ? AppColors.darkDivider : AppColors.divider;

  /// Primary brand accent color
  Color get primary => isDark ? AppColors.darkPrimary : AppColors.primary;

  /// Primary button & banner gradient
  LinearGradient get primaryGradient =>
      isDark ? AppColors.darkPrimaryGradient : AppColors.primaryGradient;

  /// Ambient glow highlight color
  Color get glow => isDark ? AppColors.darkGlow : AppColors.glow;

  /// Card elevation shadow color
  Color get cardShadow =>
      isDark ? AppColors.darkCardShadow : AppColors.cardShadow;

  /// Status error color
  Color get error => isDark ? AppColors.darkError : AppColors.error;
}

/// BuildContext extension for effortless theme queries
extension ThemeHelperExtension on BuildContext {
  /// Whether the current screen is in dark mode
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Access pre-resolved theme colors: `context.appTheme.background`, `context.appTheme.textPrimary`
  AppThemeHelper get appTheme => AppThemeHelper.of(this);

  /// Alias for appTheme: `context.themeColors.background`
  AppThemeHelper get themeColors => AppThemeHelper.of(this);

  /// Quick conditional value resolver:
  /// ```dart
  /// final color = context.themeValue(light: Colors.white, dark: Colors.black);
  /// ```
  T themeValue<T>({required T light, required T dark}) {
    return isDark ? dark : light;
  }
}

/// Global ThemeController for toggling and persisting Light/Dark mode with GetX
class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final storage = Get.find<LocalStorageService>();
      final savedMode = storage.isDarkMode();
      // Default to Light Mode (false)
      isDarkMode.value = savedMode ?? false;
    } catch (_) {
      isDarkMode.value = false;
    }
  }

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// Toggle between Light and Dark mode
  void toggleTheme() {
    isDarkMode.toggle();
    _persistAndApply();
  }

  /// Explicitly set dark mode on or off
  void setDarkMode(bool dark) {
    isDarkMode.value = dark;
    _persistAndApply();
  }

  void _persistAndApply() {
    try {
      final storage = Get.find<LocalStorageService>();
      storage.setDarkMode(isDarkMode.value);
    } catch (_) {}
    Get.changeThemeMode(themeMode);
  }
}
