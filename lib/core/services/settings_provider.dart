import 'package:flutter/material.dart';
import 'package:qr_generator_scanner/core/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  ThemeMode _themeMode = ThemeMode.system;
  bool _saveScanHistory = true;

  SettingsProvider(this._storage);

  ThemeMode get themeMode => _themeMode;
  bool get saveScanHistory => _saveScanHistory;

  Future<void> load() async {
    final mode = await _storage.loadThemeMode();
    _themeMode = _modeFromString(mode);
    _saveScanHistory = await _storage.loadSaveScanHistory();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(_modeToString(mode));
    notifyListeners();
  }

  Future<void> setSaveScanHistory(bool value) async {
    _saveScanHistory = value;
    await _storage.saveScanHistoryEnabled(value);
    notifyListeners();
  }

  ThemeMode _modeFromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _modeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
