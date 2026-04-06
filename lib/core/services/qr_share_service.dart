import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
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

  /// Writes bytes to a fixed temp file (overwriting each time — no accumulation).
  static Future<File?> _writeTempFile(List<int> bytes,
      {String name = 'qr_share'}) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name.png');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Shares the QR image via the system share sheet.
  /// Temp file is deleted after the share sheet is dismissed.
  static Future<bool> share(GlobalKey key,
      {String subject = 'QR Code'}) async {
    final bytes = await _capture(key);
    if (bytes == null) return false;
    final file = await _writeTempFile(bytes);
    if (file == null) return false;
    try {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: subject,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      try { file.deleteSync(); } catch (_) {}
    }
  }

  /// Saves the QR image to the device gallery using MediaStore (Android)
  /// or Photos (iOS) via the gal package.
  /// Caller MUST ensure storage permission is granted before calling this.
  static Future<bool> saveToGallery(GlobalKey key,
      {String name = 'qr_code'}) async {
    final bytes = await _capture(key);
    if (bytes == null) return false;
    final file = await _writeTempFile(bytes, name: name);
    if (file == null) return false;
    try {
      await Gal.putImage(file.path, album: 'QR Generator');
      return true;
    } catch (_) {
      return false;
    } finally {
      try { file.deleteSync(); } catch (_) {}
    }
  }
}
