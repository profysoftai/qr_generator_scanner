import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrShareService {
  /// Waits for the next frame then captures the [RepaintBoundary] as PNG bytes.
  static Future<List<int>?> _capture(GlobalKey key) async {
    // Resolve render object synchronously before any await
    final boundary = key.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    // Wait one frame so the boundary is fully painted
    await Future.delayed(Duration.zero);

    try {
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 120));
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _writeTempFile(List<int> bytes,
      {String name = 'qr_code'}) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Shares the QR image via the system share sheet.
  static Future<bool> share(GlobalKey key,
      {String subject = 'QR Code'}) async {
    final bytes = await _capture(key);
    if (bytes == null) return false;
    final path = await _writeTempFile(bytes);
    if (path == null) return false;
    try {
      await Share.shareXFiles(
        [XFile(path, mimeType: 'image/png')],
        subject: subject,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Saves the QR image to Downloads (Android) or share sheet (iOS).
  /// Caller MUST ensure storage permission is granted before calling this.
  static Future<bool> saveToGallery(GlobalKey key,
      {String name = 'qr_code'}) async {
    final bytes = await _capture(key);
    if (bytes == null) return false;
    try {
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Download');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        final file = File(
            '${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        return true;
      } else {
        final path = await _writeTempFile(bytes, name: name);
        if (path == null) return false;
        await Share.shareXFiles(
          [XFile(path, mimeType: 'image/png')],
          subject: 'Save QR Code',
        );
        return true;
      }
    } catch (_) {
      return false;
    }
  }
}
