import '../models/qr_type.dart';

class QrFormatService {
  static String build(QrType type, Map<String, String> fields) {
    switch (type) {
      case QrType.text:
        return fields['text'] ?? '';

      case QrType.email:
        final to = fields['email'] ?? '';
        final subject = Uri.encodeComponent(fields['subject'] ?? '');
        final body = Uri.encodeComponent(fields['body'] ?? '');
        return 'mailto:$to?subject=$subject&body=$body';

      case QrType.url:
        var url = fields['url'] ?? '';
        if (url.isNotEmpty &&
            !url.startsWith('http://') &&
            !url.startsWith('https://')) {
          url = 'https://$url';
        }
        return url;

      case QrType.sms:
        final phone = fields['phone'] ?? '';
        final message = fields['message'] ?? '';
        return 'SMSTO:$phone:$message';

      case QrType.location:
        final lat = fields['latitude'] ?? '';
        final lng = fields['longitude'] ?? '';
        return 'geo:$lat,$lng';

      case QrType.social:
        var url = fields['url'] ?? '';
        if (url.isNotEmpty &&
            !url.startsWith('http://') &&
            !url.startsWith('https://')) {
          url = 'https://$url';
        }
        return url;

      case QrType.appDownload:
        var url = fields['url'] ?? '';
        if (url.isNotEmpty &&
            !url.startsWith('http://') &&
            !url.startsWith('https://')) {
          url = 'https://$url';
        }
        return url;

      case QrType.upi:
        final pa = Uri.encodeComponent(fields['upiId'] ?? '');
        final pn = Uri.encodeComponent(fields['name'] ?? '');
        final am = fields['amount'] ?? '';
        final tn = Uri.encodeComponent(fields['note'] ?? '');
        final buffer = StringBuffer('upi://pay?pa=$pa&pn=$pn');
        if (am.isNotEmpty) buffer.write('&am=$am');
        if (tn.isNotEmpty) buffer.write('&tn=$tn');
        return buffer.toString();
    }
  }

  /// Returns a user-facing label for the generated QR.
  static String label(QrType type) {
    switch (type) {
      case QrType.text:
        return 'Text';
      case QrType.email:
        return 'Email';
      case QrType.url:
        return 'URL';
      case QrType.sms:
        return 'SMS';
      case QrType.location:
        return 'Location';
      case QrType.social:
        return 'Social';
      case QrType.appDownload:
        return 'App';
      case QrType.upi:
        return 'UPI';
    }
  }
}
