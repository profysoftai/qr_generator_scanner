import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_generator_scanner/core/services/ad_service.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/utils/app_utils.dart';
import 'package:qr_generator_scanner/core/utils/qr_parser.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/empty_state.dart';
import 'package:qr_generator_scanner/shared/widgets/theme_toggle.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AdService.instance.loadBanner();
  }

  @override
  void dispose() {
    AdService.instance.disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<QrRepository>();
    final recent = repo.recentRecords;

    return ValueListenableBuilder<BannerAd?>(
      valueListenable: AdService.instance.bannerNotifier,
      builder: (context, banner, _) {
        return Scaffold(
          backgroundColor: context.colors.iosGroupedBg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onNavigate: widget.onNavigate),
                const SizedBox(height: 8),
                _QuickActions(onNavigate: widget.onNavigate),
                const SizedBox(height: 24),
                _RecentActivity(recent: recent, onNavigate: widget.onNavigate),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Banner only appears after it finishes loading — no empty space if it fails.
          bottomNavigationBar: banner != null
              ? SizedBox(
                  height: banner.size.height.toDouble(),
                  child: AdWidget(ad: banner),
                )
              : null,
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final void Function(int) onNavigate;
  const _Header({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.colors.iosLabel,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan or generate a QR code',
                  style: TextStyle(
                    fontSize: 15,
                    color: context.colors.iosSecondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const ThemeToggle(),
        ],
      ),
    );
  }

  String _greeting() => 'QR TOOLKIT PRO';
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _TileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final int navIndex;
  const _TileData(this.icon, this.title, this.subtitle, this.navIndex);
}

class _QuickActions extends StatelessWidget {
  final void Function(int) onNavigate;
  const _QuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      const _TileData(Icons.qr_code_scanner, AppStrings.scanQr, AppStrings.scanQrSub, 2),
      const _TileData(Icons.qr_code_2, AppStrings.createQr, AppStrings.createQrSub, 1),
      const _TileData(Icons.history, AppStrings.history, AppStrings.historySub, 3),
      const _TileData(Icons.grid_view, AppStrings.myQrs, AppStrings.myQrsSub, 4),
      const _TileData(Icons.settings, AppStrings.settings, AppStrings.settingsSub, 5),
      const _TileData(Icons.flash_on, AppStrings.quickScan, AppStrings.quickScanSub, 2),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.iosSecondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 130,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, i) => _QuickActionTile(
            data: tiles[i],
            onTap: () {
              HapticFeedback.lightImpact();
              onNavigate(tiles[i].navIndex);
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _TileData data;
  final VoidCallback onTap;
  const _QuickActionTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.iosSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.iosSeparator.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.iosBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    data.icon,
                    size: 22,
                    color: context.colors.iosBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.iosLabel,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.iosSecondaryLabel,
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

// ── Recent Activity ───────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  final List<QrRecord> recent;
  final void Function(int) onNavigate;
  const _RecentActivity({required this.recent, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.iosSecondaryLabel,
                  letterSpacing: 0.5,
                ),
              ),
              if (recent.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onNavigate(3);
                  },
                  child: Text(
                    AppStrings.seeAll,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.colors.iosBlue,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Content
        if (recent.isEmpty)
          const EmptyState(
            message: 'No Recent Scans',
            icon: Icons.history,
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.iosSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.iosSeparator.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(recent.length, (i) {
                final r = recent[i];
                final type = QrParser.detect(r.data);
                return Column(
                  children: [
                    _RecentRow(
                      record: r,
                      contentType: type,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onNavigate(3);
                      },
                    ),
                    if (i < recent.length - 1)
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 56,
                        color: context.colors.iosSeparator,
                      ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  final QrRecord record;
  final QrContentType contentType;
  final VoidCallback onTap;

  const _RecentRow({
    required this.record,
    required this.contentType,
    required this.onTap,
  });

  IconData _iconForType(QrContentType type) {
    switch (type) {
      case QrContentType.url:
        return Icons.link;
      case QrContentType.email:
        return Icons.email_outlined;
      case QrContentType.phone:
        return Icons.phone_outlined;
      case QrContentType.wifi:
        return Icons.wifi;
      case QrContentType.text:
        return Icons.text_snippet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Leading icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.colors.iosBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForType(contentType),
                size: 18,
                color: context.colors.iosBlue,
              ),
            ),
            const SizedBox(width: 12),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppUtils.truncate(record.data),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.colors.iosLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    QrParser.label(contentType),
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.iosSecondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing time + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppUtils.timeAgo(record.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.iosSecondaryLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: context.colors.iosSecondaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
