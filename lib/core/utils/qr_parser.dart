enum QrContentType { url, email, phone, wifi, text }

class QrParser {
  static QrContentType detect(String value) {
    final v = value.trim();
    if (v.isEmpty) return QrContentType.text;
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return QrContentType.url;
    }
    if (v.startsWith('mailto:') ||
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return QrContentType.email;
    }
    if (v.startsWith('tel:') || RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(v)) {
      return QrContentType.phone;
    }
    if (v.startsWith('WIFI:')) return QrContentType.wifi;
    return QrContentType.text;
  }

  static String label(QrContentType type) {
    switch (type) {
      case QrContentType.url:
        return 'URL';
      case QrContentType.email:
        return 'Email';
      case QrContentType.phone:
        return 'Phone';
      case QrContentType.wifi:
        return 'Wi-Fi';
      case QrContentType.text:
        return 'Text';
    }
  }

  static String icon(QrContentType type) {
    switch (type) {
      case QrContentType.url:
        return '🔗';
      case QrContentType.email:
        return '✉️';
      case QrContentType.phone:
        return '📞';
      case QrContentType.wifi:
        return '📶';
      case QrContentType.text:
        return '📝';
    }
  }

  /// Returns true if the scanned value is non-empty and printable.
  static bool isValid(String? value) {
    if (value == null) return false;
    final v = value.trim();
    return v.isNotEmpty && v.length <= 2953; // QR max capacity
  }
}
