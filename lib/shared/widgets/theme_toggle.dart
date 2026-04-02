import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    final effectiveMode = settings.themeMode == ThemeMode.system
        ? (MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light)
        : settings.themeMode;

    final isDark = effectiveMode == ThemeMode.dark;

    return Semantics(
      label: isDark
          ? 'Dark mode active. Tap to switch to Light.'
          : 'Light mode active. Tap to switch to Dark.',
      button: true,
      child: _ThemeToggleAnimated(
        isDark: isDark,
        onTap: () => context.read<SettingsProvider>().setThemeMode(
              isDark ? ThemeMode.light : ThemeMode.dark,
            ),
      ),
    );
  }
}

class _ThemeToggleAnimated extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeToggleAnimated({
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ThemeToggleAnimated> createState() => _ThemeToggleAnimatedState();
}

class _ThemeToggleAnimatedState extends State<_ThemeToggleAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // All values driven by the single controller
  late final Animation<double> _thumbSlide;
  late final Animation<Color?> _trackColor;
  late final Animation<Color?> _thumbColor;
  late final Animation<double> _sunOpacity;
  late final Animation<double> _moonOpacity;
  late final Animation<Color?> _thumbIconColor;

  static const _trackDark = Color(0xFF2E2E2E);
  static const _trackLight = Color(0xFFF0F0F0);
  static const _thumbDark = Color(0xFF1A1A1A);
  static const _thumbLight = Colors.white;
  static const _iconDark = Colors.white;
  static const _iconLight = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: widget.isDark ? 1.0 : 0.0, // 0 = light, 1 = dark
    );
    _buildAnimations();
  }

  void _buildAnimations() {
    // Thumb slides from left (0) to right (1)
    _thumbSlide = _ctrl.drive(CurveTween(curve: Curves.easeInOutCubic));

    _trackColor = ColorTween(begin: _trackLight, end: _trackDark)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _thumbColor = ColorTween(begin: _thumbLight, end: _thumbDark)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _thumbIconColor = ColorTween(begin: _iconLight, end: _iconDark)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // Sun fades in as we go dark (visible on left when dark)
    _sunOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)),
    );

    // Moon fades in as we go light (visible on right when light)
    _moonOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7)),
    );
  }

  @override
  void didUpdateWidget(_ThemeToggleAnimated old) {
    super.didUpdateWidget(old);
    if (old.isDark != widget.isDark) {
      if (widget.isDark) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double width = 80;
    const double height = 40;
    const double thumbSize = 32;
    const double padding = 4;
    const double travelDistance = width - thumbSize - padding * 2;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final thumbLeft = padding + _thumbSlide.value * travelDistance;
          final borderColor = Color.lerp(
            const Color(0xFFDDDDDD),
            const Color(0xFF444444),
            _ctrl.value,
          )!;

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: _trackColor.value,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Sun icon — left side, visible when dark
                Positioned(
                  left: padding + (thumbSize - 18) / 2,
                  top: (height - 18) / 2,
                  child: Opacity(
                    opacity: _sunOpacity.value,
                    child: const Icon(
                      Icons.light_mode_outlined,
                      size: 18,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                // Moon icon — right side, visible when light
                Positioned(
                  right: padding + (thumbSize - 18) / 2,
                  top: (height - 18) / 2,
                  child: Opacity(
                    opacity: _moonOpacity.value,
                    child: const Icon(
                      Icons.dark_mode_outlined,
                      size: 18,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: thumbLeft,
                  top: padding,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: _thumbColor.value,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isDark ? Icons.dark_mode : Icons.light_mode,
                        size: 18,
                        color: _thumbIconColor.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
