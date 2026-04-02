import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/shared/widgets/qr_list_tile.dart';

class MyQrScreen extends StatelessWidget {
  final VoidCallback? onCreateQr;

  const MyQrScreen({super.key, this.onCreateQr});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<QrRepository>();
    final records = repo.generatedRecords;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myQrs)),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 80,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noQrCodesYet,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noQrCodesSub,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onCreateQr,
                    child: const Text(AppStrings.createQrBtn),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: records.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (context, i) {
                final r = records[i];
                return QrListTile(
                  record: r,
                  onDelete: () => context.read<QrRepository>().delete(r.id),
                  onFavoriteToggle: () =>
                      context.read<QrRepository>().toggleFavorite(r.id),
                );
              },
            ),
    );
  }
}
