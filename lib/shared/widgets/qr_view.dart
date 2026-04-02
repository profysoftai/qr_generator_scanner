import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrView extends StatelessWidget {
  final String data;
  final double size;
  final GlobalKey? repaintKey;

  const QrView({
    super.key,
    required this.data,
    this.size = 220,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final qr = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
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
