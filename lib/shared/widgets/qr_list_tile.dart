import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(QrParser.icon(type),
            style: const TextStyle(fontSize: 16)),
      ),
      title: Text(
        AppUtils.truncate(record.data),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${record.label} · ${AppUtils.timeAgo(record.createdAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              record.isFavorite ? Icons.star : Icons.star_border,
              size: 20,
              color: record.isFavorite ? Colors.amber : null,
            ),
            onPressed: onFavoriteToggle,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
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
    // Capture the root ScaffoldMessenger before any await so the snackbar
    // shows on the main Scaffold even after the bottom sheet is dismissed.
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
              Text(
                '${QrParser.icon(type)}  ${QrParser.label(type)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  widget.record.isFavorite ? Icons.star : Icons.star_border,
                  color: widget.record.isFavorite ? Colors.amber : null,
                ),
                onPressed: () {
                  widget.onFavoriteToggle();
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // QR image with repaint boundary
          Center(
            child: QrView(
              data: widget.record.data,
              size: 180,
              repaintKey: _repaintKey,
            ),
          ),
          const SizedBox(height: 12),
          // Data preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(widget.record.data,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 4),
          Text(
            AppUtils.timeAgo(widget.record.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          // Row 1: Copy | Delete
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.record.data));
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Share | Save to Gallery
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(AppStrings.shareQr),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveToGallery,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined, size: 18),
                  label: const Text(AppStrings.saveToGallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
