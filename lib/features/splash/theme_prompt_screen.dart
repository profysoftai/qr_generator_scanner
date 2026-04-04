import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';
import 'package:qr_generator_scanner/features/splash/splash_screen.dart';

class ThemePromptScreen extends StatelessWidget {
  const ThemePromptScreen({super.key});

  void _onThemeSelected(BuildContext context, ThemeMode mode) async {
    HapticFeedback.mediumImpact();
    // Save theme
    await context.read<SettingsProvider>().setThemeMode(mode);
    
    // Slight delay to allow theme switch to paint
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (!context.mounted) return;
    
    // Navigate to splash screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon or illustration, standard iOS look
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.iosBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 40,
                  color: context.colors.iosBlue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Choose Your Theme',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.colors.iosLabel,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You can always change this later in settings.',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.iosSecondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Options
              _ThemeOptionTile(
                icon: Icons.light_mode_rounded,
                title: 'Light',
                onTap: () => _onThemeSelected(context, ThemeMode.light),
              ),
              const SizedBox(height: 16),
              _ThemeOptionTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark',
                onTap: () => _onThemeSelected(context, ThemeMode.dark),
              ),
              const SizedBox(height: 16),
              _ThemeOptionTile(
                icon: Icons.brightness_auto_rounded,
                title: 'System Default',
                onTap: () => _onThemeSelected(context, ThemeMode.system),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: context.colors.iosSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.iosSeparator.withValues(alpha: 0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: context.colors.iosBlue,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.colors.iosLabel,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.iosSecondaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
