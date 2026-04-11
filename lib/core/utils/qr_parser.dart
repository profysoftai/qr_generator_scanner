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

  /// Returns true if the scanned value is non-empty, within QR capacity,
  /// and contains no raw control characters (\x00–\x08, \x0B–\x0C, \x0E–\x1F)
  /// that could be injected by a maliciously crafted QR code.
  static bool isValid(String? value) {
    if (value == null) return false;
    final v = value.trim();
    if (v.isEmpty || v.length > 2953) return false;
    // Allow tab (\x09), newline (\x0A), carriage return (\x0D) — legitimate
    // in multi-line text QRs. Reject all other C0 control characters.
    return !v.runes.any((r) =>
        r <= 0x1F && r != 0x09 && r != 0x0A && r != 0x0D);
  }
}
