import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _recordsKey = 'qr_records';
  static const _saveScanHistoryKey = 'save_scan_history';
  static const _themeKey = 'theme_mode';

  Future<void> saveRecords(List<Map<String, dynamic>> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recordsKey, jsonEncode(records));
    } catch (_) {
      // Silently fail — data will be re-saved on next write
    }
  }

  /// Returns empty list on any decode failure (corrupted data fallback).
  Future<List<Map<String, dynamic>>> loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_recordsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveScanHistoryEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_saveScanHistoryKey, value);
    } catch (_) {}
  }

  Future<bool> loadSaveScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_saveScanHistoryKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> saveThemeMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode);
    } catch (_) {}
  }

  Future<String> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_themeKey) ?? 'system';
    } catch (_) {
      return 'system';
    }
  }
}
