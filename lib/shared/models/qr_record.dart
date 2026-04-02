class QrRecord {
  final String id;
  final String data;
  final String type; // 'scanned' | 'generated'
  final String label;
  final DateTime createdAt;
  final bool isFavorite;

  const QrRecord({
    required this.id,
    required this.data,
    required this.type,
    required this.label,
    required this.createdAt,
    this.isFavorite = false,
  });

  bool get isValid => id.isNotEmpty && data.isNotEmpty;

  QrRecord copyWith({bool? isFavorite, String? label}) {
    return QrRecord(
      id: id,
      data: data,
      type: type,
      label: label ?? this.label,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'type': type,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  /// Returns null if the JSON is malformed or missing required fields.
  static QrRecord? tryFromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String? ?? '';
      final data = json['data'] as String? ?? '';
      final type = json['type'] as String? ?? 'scanned';
      final label = json['label'] as String? ?? 'Text';
      final rawDate = json['createdAt'] as String?;
      if (id.isEmpty || data.isEmpty || rawDate == null) return null;
      return QrRecord(
        id: id,
        data: data,
        type: type,
        label: label,
        createdAt: DateTime.parse(rawDate),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  factory QrRecord.fromJson(Map<String, dynamic> json) {
    return tryFromJson(json) ??
        QrRecord(
          id: json['id']?.toString() ?? '',
          data: json['data']?.toString() ?? '',
          type: 'scanned',
          label: 'Text',
          createdAt: DateTime.now(),
        );
  }
}
