import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_share_service.dart';
import 'package:qr_generator_scanner/core/utils/app_utils.dart';
import 'package:qr_generator_scanner/core/utils/qr_parser.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/gallery_save_mixin.dart';
import 'package:qr_generator_scanner/shared/widgets/qr_view.dart';

class QrListTile extends StatelessWidget {
  final QrRecord record;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;

  const QrListTile({
    super.key,
    required this.record,
    required this.onDelete,
    required this.onFavoriteToggle,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: context.colors.iosSurface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete Item',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: context.colors.iosLabel,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This item will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.iosSecondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 0.5, thickness: 0.5, color: context.colors.iosSeparator),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          color: context.colors.iosBlue,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 0.5, height: 44, color: context.colors.iosSeparator),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 17,
                          color: context.colors.iosDestructive,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) onDelete();
  }

  void _showDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.iosGroupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _QrDetailSheet(
        record: record,
        onDelete: () {
          Navigator.pop(context);
          onDelete();
        },
        onFavoriteToggle: onFavoriteToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = QrParser.detect(record.data);
    return ListTile(
      onTap: () => _showDetail(context),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.colors.iosBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            QrParser.icon(type),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      title: Text(
        AppUtils.truncate(record.data),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: context.colors.iosLabel,
        ),
      ),
      subtitle: Text(
        '${QrParser.label(type)} · ${AppUtils.timeAgo(record.createdAt)}',
        style: TextStyle(
          fontSize: 13,
          color: context.colors.iosSecondaryLabel,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              record.isFavorite ? Icons.star : Icons.star_border,
              size: 20,
              color: record.isFavorite ? context.colors.iosWarning : context.colors.iosSecondaryLabel,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              onFavoriteToggle();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: context.colors.iosDestructive,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _confirmDelete(context);
            },
          ),
        ],
      ),
    );
  }
}

class _QrDetailSheet extends StatefulWidget {
  final QrRecord record;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;

  const _QrDetailSheet({
    required this.record,
    required this.onDelete,
    required this.onFavoriteToggle,
  });

  @override
  State<_QrDetailSheet> createState() => _QrDetailSheetState();
}

class _QrDetailSheetState extends State<_QrDetailSheet> with GallerySaveMixin {
  final _repaintKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: context.colors.iosSurface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete Item',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: context.colors.iosLabel,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This item will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.iosSecondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 0.5, thickness: 0.5, color: context.colors.iosSeparator),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          color: context.colors.iosBlue,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 0.5, height: 44, color: context.colors.iosSeparator),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 17,
                          color: context.colors.iosDestructive,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) widget.onDelete();
  }

  Future<void> _share() async {
    final ok = await QrShareService.share(
      _repaintKey,
      subject: widget.record.data,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorShare)),
      );
    }
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    await saveToGalleryWithPermission(_repaintKey, messenger: messenger);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final type = QrParser.detect(widget.record.data);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.iosBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      QrParser.icon(type),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      QrParser.label(type),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.iosBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  widget.record.isFavorite ? Icons.star : Icons.star_border,
                  color: widget.record.isFavorite ? context.colors.iosWarning : context.colors.iosSecondaryLabel,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onFavoriteToggle();
                  Navigator.pop(context);
                },
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.iosSecondaryBg,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, size: 18, color: context.colors.iosSecondaryLabel),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // QR image
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.iosSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.iosSeparator.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: QrView(
              data: widget.record.data,
              size: 200,
              repaintKey: _repaintKey,
            ),
          ),
          const SizedBox(height: 20),
          
          // Data preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.iosSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.iosSeparator.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.record.data,
                  style: TextStyle(
                    fontSize: 15,
                    color: context.colors.iosLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppUtils.timeAgo(widget.record.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.iosSecondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Row 1: Copy | Delete
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await Clipboard.setData(ClipboardData(text: widget.record.data));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.iosBlue,
                      side: BorderSide(color: context.colors.iosBlue, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _confirmDelete(context);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.iosDestructive,
                      side: BorderSide(color: context.colors.iosDestructive, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 2: Share | Gallery
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _share();
                    },
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text(AppStrings.shareQr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.iosBlue,
                      side: BorderSide(color: context.colors.iosBlue, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : () {
                      HapticFeedback.lightImpact();
                      _saveToGallery();
                    },
                    icon: _isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.iosBlue),
                          )
                        : const Icon(Icons.download_rounded, size: 18),
                    label: const Text(AppStrings.saveToGallery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.iosBlue,
                      side: BorderSide(color: context.colors.iosBlue, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
