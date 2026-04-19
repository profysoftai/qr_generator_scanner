import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
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
      backgroundColor: context.colors.iosGroupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ScanResultSheet(record: record, onScanAgain: onScanAgain),
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(record.data);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorInvalidQr)),
      );
      return;
    }

    // Only https:// is allowed — network_security_config.xml blocks all HTTP
    // at the OS level. Also blocks javascript:, file:///, intent://, data: etc.
    if (uri.scheme != 'https') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorInvalidQr)),
      );
      return;
    }

    // ── Connectivity check ─────────────────────────────────────────────────
    final connectivity = context.read<ConnectivityService>();
    final online = await connectivity.isOnline();
    if (!context.mounted) return;

    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorOffline)),
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

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = QrParser.detect(record.data);
    final typeLabel = QrParser.label(type);
    final typeIcon = QrParser.icon(type);
    final isUrl = type == QrContentType.url;
    final uri = Uri.tryParse(record.data);
    final isHttps = isUrl && uri != null && uri.scheme == 'https';
    final isHttp  = isUrl && uri != null && uri.scheme == 'http';

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    Text(typeIcon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      typeLabel,
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
          const SizedBox(height: 16),
          Text(
            'Scan Result',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.colors.iosLabel,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.iosSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: context.colors.iosSeparator.withValues(alpha: 0.3),
                  width: 0.5),
            ),
            child: Text(
              record.data,
              style: TextStyle(
                fontSize: 16,
                color: context.colors.iosLabel,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await Clipboard.setData(ClipboardData(text: record.data));
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              // Open button — only for https:// links
              if (isHttps) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _openUrl(context);
                      },
                      icon: const Icon(Icons.open_in_browser, size: 18),
                      label: const Text('Open'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.iosBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // HTTP warning — shown instead of Open button for http:// links
          if (isHttp)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(Icons.lock_open_rounded,
                      size: 15, color: context.colors.iosWarning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This link uses HTTP and cannot be opened securely.',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.iosWarning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                onScanAgain();
              },
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text(
                'Scan Again',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.iosSurface,
                foregroundColor: context.colors.iosBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.colors.iosBlue, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
