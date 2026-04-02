import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(AppStrings.theme,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _ThemeSelector(current: settings.themeMode),
          const SizedBox(height: 28),
          Text(AppStrings.preferences,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(AppStrings.saveScanHistory),
            value: settings.saveScanHistory,
            onChanged: (v) =>
                context.read<SettingsProvider>().setSaveScanHistory(v),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  const _ThemeSelector({required this.current});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ThemeMode.light, AppStrings.light, Icons.light_mode_outlined),
      (ThemeMode.system, AppStrings.system, Icons.settings_outlined),
      (ThemeMode.dark, AppStrings.dark, Icons.dark_mode_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: options.map((opt) {
          final (mode, label, icon) = opt;
          final selected = current == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<SettingsProvider>().setThemeMode(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected)
                      const Icon(Icons.check, size: 14),
                    if (selected) const SizedBox(width: 4),
                    Icon(icon, size: 16),
                    const SizedBox(width: 4),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
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
