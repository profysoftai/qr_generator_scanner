import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/services/ad_service.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/services/qr_share_service.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/gallery_save_mixin.dart';
import 'package:qr_generator_scanner/shared/widgets/qr_view.dart';
import '../models/qr_type.dart';
import '../services/qr_format_service.dart';

class QrPreviewScreen extends StatefulWidget {
  final QrTypeData typeData;
  final String qrData;

  const QrPreviewScreen({
    super.key,
    required this.typeData,
    required this.qrData,
  });

  @override
  State<QrPreviewScreen> createState() => _QrPreviewScreenState();
}

class _QrPreviewScreenState extends State<QrPreviewScreen>
    with GallerySaveMixin {
  final _repaintKey = GlobalKey();
  bool _saved = false;
  bool _isSaving = false;

  Future<void> _save() async {
    if (_saved) return;
    final repo = context.read<QrRepository>();
    if (repo.isDuplicate(widget.qrData, 'generated')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This QR code is already saved.')),
      );
      setState(() => _saved = true);
      return;
    }
    final added = await repo.add(QrRecord(
      id: const Uuid().v4(),
      data: widget.qrData,
      type: 'generated',
      label: QrFormatService.label(widget.typeData.type),
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    if (added) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code saved to My QRs')),
      );
    }
  }

  Future<void> _share() async {
    final ok =
        await QrShareService.share(_repaintKey, subject: widget.qrData);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share QR code. Try again.')),
      );
    }
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await saveToGalleryWithPermission(_repaintKey);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      appBar: AppBar(
        backgroundColor: context.colors.iosGroupedBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            // Show interstitial every time user leaves QR preview —
            // natural break after completing a QR generation.
            AdService.instance.onGenerateCompleted();
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.arrow_back_ios_new,
                size: 20, color: context.colors.iosBlue),
          ),
        ),
        title: Text(
          widget.typeData.title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.colors.iosLabel,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Type badge ──────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.typeData.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.typeData.icon,
                      size: 16, color: widget.typeData.color),
                  const SizedBox(width: 6),
                  Text(
                    widget.typeData.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.typeData.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── QR Card ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.iosSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.iosSeparator.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  QrView(
                    data: widget.qrData,
                    size: 220,
                    repaintKey: _repaintKey,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.iosSecondaryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.qrData,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.iosSecondaryLabel,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Save to My QRs ──────────────────────────────
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saved ? null : () { HapticFeedback.lightImpact(); _save(); },
                icon: Icon(_saved ? Icons.check_rounded : Icons.bookmark_add_outlined, size: 20),
                label: Text(
                  _saved ? 'Saved to My QRs' : 'Save to My QRs',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved ? context.colors.iosSuccess : context.colors.iosBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: context.colors.iosSuccess.withValues(alpha: 0.8),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Copy | Share | Gallery ──────────────────────
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(ClipboardData(text: widget.qrData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy', style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.iosBlue,
                        side: BorderSide(color: context.colors.iosBlue, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () { HapticFeedback.lightImpact(); _share(); },
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Share', style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.iosBlue,
                        side: BorderSide(color: context.colors.iosBlue, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : () { HapticFeedback.lightImpact(); _saveToGallery(); },
                      icon: _isSaving
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.iosBlue),
                            )
                          : const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Gallery', style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.iosBlue,
                        side: BorderSide(color: context.colors.iosBlue, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
