import 'package:flutter/foundation.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/core/services/storage_service.dart';

class QrRepository extends ChangeNotifier {
  final StorageService _storage;
  List<QrRecord> _records = [];
  bool _hadCorruptedData = false;

  QrRepository(this._storage);

  bool get hadCorruptedData => _hadCorruptedData;

  List<QrRecord> get scannedRecords =>
      _records.where((r) => r.type == 'scanned').toList();

  List<QrRecord> get generatedRecords =>
      _records.where((r) => r.type == 'generated').toList();

  List<QrRecord> get favoriteRecords =>
      _records.where((r) => r.isFavorite).toList();

  List<QrRecord> get recentRecords {
    final sorted = [..._records]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<QrRecord> search(String query, {String type = 'scanned'}) {
    final q = query.toLowerCase();
    return _records
        .where((r) => r.type == type && r.data.toLowerCase().contains(q))
        .toList();
  }

  /// Returns true if an identical data+type record already exists.
  bool isDuplicate(String data, String type) {
    return _records.any((r) => r.data == data && r.type == type);
  }

  Future<void> load() async {
    final raw = await _storage.loadRecords();
    final parsed = <QrRecord>[];
    int skipped = 0;
    for (final json in raw) {
      final record = QrRecord.tryFromJson(json);
      if (record != null && record.isValid) {
        parsed.add(record);
      } else {
        skipped++;
      }
    }
    _hadCorruptedData = skipped > 0;
    _records = parsed;
    notifyListeners();
  }

  /// Returns false if the record is a duplicate and was not added.
  Future<bool> add(QrRecord record) async {
    if (!record.isValid) return false;
    if (isDuplicate(record.data, record.type)) return false;
    _records.insert(0, record);
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> toggleFavorite(String id) async {
    final index = _records.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _records[index] = _records[index].copyWith(
      isFavorite: !_records[index].isFavorite,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> clearScanned() async {
    _records.removeWhere((r) => r.type == 'scanned');
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveRecords(_records.map((r) => r.toJson()).toList());
  }
}
