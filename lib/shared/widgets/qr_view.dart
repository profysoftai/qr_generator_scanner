import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';

class QrView extends StatelessWidget {
  final String data;
  final double size;
  final GlobalKey? repaintKey;

  QrView({
    super.key,
    required this.data,
    this.size = 220,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final qr = Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Strict iOS 12px grouped border
        border: Border.all(
          color: context.colors.iosSeparator.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.transparent,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );

    if (repaintKey != null) {
      return RepaintBoundary(key: repaintKey, child: qr);
    }
    return qr;
  }
}
