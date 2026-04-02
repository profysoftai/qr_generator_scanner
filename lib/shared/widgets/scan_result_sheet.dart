import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/connectivity_service.dart';
import 'package:qr_generator_scanner/core/utils/qr_parser.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';

class ScanResultSheet extends StatelessWidget {
  final QrRecord record;
  final VoidCallback onScanAgain;

  const ScanResultSheet({
    super.key,
    required this.record,
    required this.onScanAgain,
  });

  static Future<void> show(
    BuildContext context, {
    required QrRecord record,
    required VoidCallback onScanAgain,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ScanResultSheet(record: record, onScanAgain: onScanAgain),
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    final connectivity = ConnectivityService();
    final online = await connectivity.isOnline();

    if (!context.mounted) return;

    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorOffline)),
      );
      return;
    }

    final uri = Uri.tryParse(record.data);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorInvalidQr)),
      );
      return;
    }

    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;

    if (!canLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorGeneric)),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final type = QrParser.detect(record.data);
    final typeLabel = QrParser.label(type);
    final typeIcon = QrParser.icon(type);
    final isUrl = type == QrContentType.url;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(typeIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                typeLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Scan Result',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(record.data,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: record.data));
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
              if (isUrl) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openUrl(context),
                    icon: const Icon(Icons.open_in_browser, size: 18),
                    label: const Text('Open'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onScanAgain();
              },
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Scan Again'),
            ),
          ),
        ],
      ),
    );
  }
}
