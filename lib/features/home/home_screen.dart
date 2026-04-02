import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/utils/app_utils.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/theme_toggle.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<QrRepository>();
    final recent = repo.recentRecords;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onNavigate: onNavigate),
              const SizedBox(height: 24),
              _QuickActions(onNavigate: onNavigate),
              const SizedBox(height: 24),
              _RecentActivity(recent: recent, onNavigate: onNavigate),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final void Function(int) onNavigate;
  const _Header({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcomeBack,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(AppStrings.welcomeSub,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const ThemeToggle(),
      ],
    );
  }
}

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
      _TileData(Icons.qr_code_scanner, AppStrings.scanQr, AppStrings.scanQrSub, 2),
      _TileData(Icons.qr_code_2, AppStrings.createQr, AppStrings.createQrSub, 1),
      _TileData(Icons.history, AppStrings.history, AppStrings.historySub, 3),
      _TileData(Icons.grid_view, AppStrings.myQrs, AppStrings.myQrsSub, 4),
      _TileData(Icons.settings, AppStrings.settings, AppStrings.settingsSub, 5),
      _TileData(Icons.flash_on, AppStrings.quickScan, AppStrings.quickScanSub, 2),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, i) => _QuickActionTile(
        data: tiles[i],
        onTap: () => onNavigate(tiles[i].navIndex),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _TileData data;
  final VoidCallback onTap;
  const _QuickActionTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, size: 28),
            const SizedBox(height: 8),
            Text(data.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              data.subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<QrRecord> recent;
  final void Function(int) onNavigate;
  const _RecentActivity({required this.recent, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentActivity,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => onNavigate(3),
              child: const Text(AppStrings.seeAll),
            ),
          ],
        ),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('No recent activity')),
          )
        else
          ...recent.map(
            (r) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Text('Tr', style: TextStyle(fontSize: 12)),
              ),
              title: Text(AppUtils.truncate(r.data)),
              subtitle: Text(AppUtils.timeAgo(r.createdAt)),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
      ],
    );
  }
}
