import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/shared/widgets/empty_state.dart';
import 'package:qr_generator_scanner/shared/widgets/qr_list_tile.dart';

class MyQrScreen extends StatelessWidget {
  final VoidCallback? onCreateQr;

  const MyQrScreen({super.key, this.onCreateQr});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<QrRepository>();
    final records = repo.generatedRecords;

    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      appBar: AppBar(
        backgroundColor: context.colors.iosGroupedBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'My QR Codes',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: context.colors.iosLabel,
            letterSpacing: 0.37,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: context.colors.iosBlue,
            onPressed: () {
              if (onCreateQr != null) {
                HapticFeedback.lightImpact();
                onCreateQr!();
              }
            },
          ),
        ],
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyState(
                    message: 'No QR Codes Yet',
                    icon: Icons.qr_code_2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your generated QR codes will appear here',
                    style: TextStyle(
                      fontSize: 15,
                      color: context.colors.iosSecondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (onCreateQr != null) {
                            HapticFeedback.lightImpact();
                            onCreateQr!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.iosBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create QR Code',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Section header ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${records.length} QR CODES',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.colors.iosSecondaryLabel,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                // ── List (iOS grouped style) ──────────────────────────────────
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: records.length,
                      separatorBuilder: (_, i) => Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 60,
                        color: context.colors.iosSeparator,
                      ),
                      itemBuilder: (context, i) {
                        final r = records[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: context.colors.iosSurface,
                            border: Border(
                              left: BorderSide(
                                color: context.colors.iosSeparator.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                              right: BorderSide(
                                color: context.colors.iosSeparator.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                              top: i == 0
                                  ? BorderSide(
                                      color: context.colors.iosSeparator.withValues(alpha: 0.3),
                                      width: 0.5,
                                    )
                                  : BorderSide.none,
                              bottom: i == records.length - 1
                                  ? BorderSide(
                                      color: context.colors.iosSeparator.withValues(alpha: 0.3),
                                      width: 0.5,
                                    )
                                  : BorderSide.none,
                            ),
                          ),
                          child: QrListTile(
                            record: r,
                            onDelete: () =>
                                context.read<QrRepository>().delete(r.id),
                            onFavoriteToggle: () =>
                                context.read<QrRepository>().toggleFavorite(r.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
