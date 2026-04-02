import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';

/// A pill-shaped three-mode theme toggle.
/// Cycles: Light → Dark → System on each tap.
/// - Light: white pill, sun icon on left, thumb on right
/// - Dark:  dark pill, moon icon on right, thumb on left
/// - System: dark pill, auto icon centred, thumb centred
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final mode = settings.themeMode;

    return _ThemeToggleInner(
      mode: mode,
      onTap: () {
        final next = mode == ThemeMode.light
            ? ThemeMode.dark
            : mode == ThemeMode.dark
                ? ThemeMode.system
                : ThemeMode.light;
        context.read<SettingsProvider>().setThemeMode(next);
      },
    );
  }
}

class _ThemeToggleInner extends StatelessWidget {
  final ThemeMode mode;
  final VoidCallback onTap;

  const _ThemeToggleInner({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Dimensions
    const double width = 64;
    const double height = 32;
    const double thumbSize = 24;
    const double padding = 4;

    // Thumb position: left=light, right=dark, centre=system
    final double thumbLeft = mode == ThemeMode.light
        ? padding
        : mode == ThemeMode.dark
            ? width - thumbSize - padding
            : (width - thumbSize) / 2;

    // Track colour
    final bool isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final Color trackColor = isDark
        ? const Color(0xFF2E2E2E)
        : const Color(0xFFF0F0F0);
    final Color thumbColor = isDark
        ? const Color(0xFF1A1A1A)
        : Colors.white;
    final Color iconColor = isDark ? Colors.white : const Color(0xFF2E2E2E);

    // Icon shown inside the track (opposite side from thumb)
    final Widget trackIcon = _trackIcon(mode, iconColor);

    return Semantics(
      label: _semanticsLabel(mode),
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track icon (sun / moon / auto)
              trackIcon,
              // Animated thumb
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                left: thumbLeft,
                top: padding,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  // Thumb icon (opposite of track icon)
                  child: Center(
                    child: _thumbIcon(mode, iconColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Icon drawn inside the track background (visible when thumb is away)
  Widget _trackIcon(ThemeMode mode, Color color) {
    switch (mode) {
      case ThemeMode.light:
        // Light mode: moon on the right side of track
        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(Icons.dark_mode_outlined, size: 14, color: color),
          ),
        );
      case ThemeMode.dark:
        // Dark mode: sun on the left side of track
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(Icons.light_mode_outlined, size: 14, color: color),
          ),
        );
      default:
        // System: auto icon centred
        return Center(
          child: Icon(Icons.brightness_auto_outlined, size: 14, color: color),
        );
    }
  }

  /// Icon drawn inside the thumb circle
  Widget _thumbIcon(ThemeMode mode, Color color) {
    switch (mode) {
      case ThemeMode.light:
        return Icon(Icons.light_mode, size: 14, color: color);
      case ThemeMode.dark:
        return Icon(Icons.dark_mode, size: 14, color: color);
      default:
        return Icon(Icons.brightness_auto, size: 14, color: color);
    }
  }

  String _semanticsLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light theme active. Tap to switch to Dark.';
      case ThemeMode.dark:
        return 'Dark theme active. Tap to switch to System.';
      default:
        return 'System theme active. Tap to switch to Light.';
    }
  }
}
