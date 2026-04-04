import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';
import 'package:qr_generator_scanner/features/settings/privacy_policy_screen.dart';
import 'package:qr_generator_scanner/features/settings/terms_of_use_screen.dart';
import 'package:qr_generator_scanner/features/settings/faq_help_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      appBar: AppBar(
        backgroundColor: context.colors.iosGroupedBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: context.colors.iosLabel,
            letterSpacing: 0.37,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 8, bottom: 40),
        children: [
          // ── APPEARANCE section ─────────────────────────────
          _SectionHeader(title: 'APPEARANCE'),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.iosSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.iosSeparator.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 17,
                    color: context.colors.iosLabel,
                  ),
                ),
                SizedBox(height: 12),
                _ThemeSelector(current: settings.themeMode),
              ],
            ),
          ),

          SizedBox(height: 28),

          // ── PREFERENCES section ────────────────────────────
          _SectionHeader(title: 'PREFERENCES'),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.iosSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.iosSeparator.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save Scan History',
                          style: TextStyle(
                            fontSize: 17,
                            color: context.colors.iosLabel,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Keep a log of all scanned QR codes',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.iosSecondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: settings.saveScanHistory,
                    activeTrackColor: context.colors.iosBlue,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      context.read<SettingsProvider>().setSaveScanHistory(v);
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 28),

          // ── ABOUT section ──────────────────────────────────
          _SectionHeader(title: 'ABOUT'),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.iosSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.iosSeparator.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                // Version
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Version',
                        style: TextStyle(
                          fontSize: 17,
                          color: context.colors.iosLabel,
                        ),
                      ),
                      Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 17,
                          color: context.colors.iosSecondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.colors.iosSeparator.withValues(alpha: 0.5),
                  indent: 16,
                ),
                // Privacy Policy — in-app navigation
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 17,
                            color: context.colors.iosLabel,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: context.colors.iosSecondaryLabel,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.colors.iosSeparator.withValues(alpha: 0.5),
                  indent: 16,
                ),
                // Terms of Use — in-app navigation
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsOfUseScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terms of Use',
                          style: TextStyle(
                            fontSize: 17,
                            color: context.colors.iosLabel,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: context.colors.iosSecondaryLabel,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.colors.iosSeparator.withValues(alpha: 0.5),
                  indent: 16,
                ),
                // FAQ / Help — in-app navigation
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FaqHelpScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FAQ / Help',
                          style: TextStyle(
                            fontSize: 17,
                            color: context.colors.iosLabel,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: context.colors.iosSecondaryLabel,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: context.colors.iosSecondaryLabel,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ── iOS Theme Selector (Segmented Control) ────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  const _ThemeSelector({required this.current});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ThemeMode.system, 'System', Icons.phone_iphone),
      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
    ];

    return Container(
      height: 32,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.iosSecondaryBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: options.map((opt) {
          final (mode, label, icon) = opt;
          final selected = current == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<SettingsProvider>().setThemeMode(mode);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? context.colors.iosBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: context.colors.iosBlue.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: selected
                          ? Colors.white
                          : context.colors.iosSecondaryLabel,
                    ),
                    SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : context.colors.iosSecondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
