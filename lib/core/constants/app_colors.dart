import 'package:flutter/material.dart';

extension AppColorsExtension on BuildContext {
  AppColorsData get colors => AppColorsData(Theme.of(this).brightness == Brightness.dark);
}

class AppColorsData {
  final bool isDark;
  const AppColorsData(this.isDark);

  Color get iosBlue => isDark ? AppColors.iosBlueDark : AppColors.iosBlueLight;
  Color get iosBackground => isDark ? AppColors.iosBackgroundDark : AppColors.iosBackgroundLight;
  Color get iosSurface => isDark ? AppColors.iosSurfaceDark : AppColors.iosSurfaceLight;
  Color get iosSecondaryBg => isDark ? AppColors.iosSecondaryBgDark : AppColors.iosSecondaryBgLight;
  Color get iosGroupedBg => isDark ? AppColors.iosGroupedBgDark : AppColors.iosGroupedBgLight;
  Color get iosLabel => isDark ? AppColors.iosLabelDark : AppColors.iosLabelLight;
  Color get iosSecondaryLabel => isDark ? AppColors.iosSecondaryLabelDark : AppColors.iosSecondaryLabelLight;
  Color get iosTertiaryLabel => isDark ? AppColors.iosTertiaryLabelDark : AppColors.iosTertiaryLabelLight;
  Color get iosSeparator => isDark ? AppColors.iosSeparatorDark : AppColors.iosSeparatorLight;
  Color get iosDestructive => isDark ? AppColors.iosDestructiveDark : AppColors.iosDestructiveLight;
  Color get iosSuccess => isDark ? AppColors.iosSuccessDark : AppColors.iosSuccessLight;
  Color get iosWarning => isDark ? AppColors.iosWarningDark : AppColors.iosWarningLight;
}

/// iOS Human Interface Guidelines color tokens.
class AppColors {
  AppColors._();

  // ── Light Mode ───────────────────────────────────────────────
  static const iosBlueLight = Color(0xFF007AFF);
  static const iosBackgroundLight = Color(0xFFF2F2F7);
  static const iosSurfaceLight = Color(0xFFFFFFFF);
  static const iosSecondaryBgLight = Color(0xFFEFEFF4);
  static const iosGroupedBgLight = Color(0xFFF2F2F7);

  static const iosLabelLight = Color(0xFF000000);
  static const iosSecondaryLabelLight = Color(0xFF8E8E93);
  static const iosTertiaryLabelLight = Color(0xFFC7C7CC);
  static const iosSeparatorLight = Color(0xFFC6C6C8);

  static const iosDestructiveLight = Color(0xFFFF3B30);
  static const iosSuccessLight = Color(0xFF34C759);
  static const iosWarningLight = Color(0xFFFF9500);

  // ── Dark mode overrides ───────────────────────────────────
  static const iosBlueDark = Color(0xFF0A84FF);
  static const iosBackgroundDark = Color(0xFF000000);
  static const iosSurfaceDark = Color(0xFF1C1C1E);
  static const iosSecondaryBgDark = Color(0xFF2C2C2E);
  static const iosGroupedBgDark = Color(0xFF1C1C1E);
  
  static const iosLabelDark = Color(0xFFFFFFFF);
  static const iosSecondaryLabelDark = Color(0xFF8E8E93);
  static const iosTertiaryLabelDark = Color(0xFF48484A);
  static const iosSeparatorDark = Color(0xFF38383A);
  
  static const iosDestructiveDark = Color(0xFFFF453A);
  static const iosSuccessDark = Color(0xFF30D158);
  static const iosWarningDark = Color(0xFFFF9F0A);
}
