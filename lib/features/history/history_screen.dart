import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/empty_state.dart';
import 'package:qr_generator_scanner/shared/widgets/qr_list_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ── State — DO NOT TOUCH ──────────────────────────────────
  bool _showFavorites = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Logic — DO NOT TOUCH ──────────────────────────────────
  List<QrRecord> _filtered(QrRepository repo) {
    final base =
        _showFavorites ? repo.favoriteRecords : repo.scannedRecords;
    if (_searchQuery.isEmpty) return base;
    final q = _searchQuery.toLowerCase();
    return base.where((r) => r.data.toLowerCase().contains(q)).toList();
  }

  Future<void> _confirmClearAll() async {
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
                'Clear History',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: context.colors.iosLabel,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Delete all scanned history?\nThis cannot be undone.',
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
                  Container(
                    width: 0.5,
                    height: 44,
                    color: context.colors.iosSeparator,
                  ),
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
    if (confirm == true && mounted) {
      await context.read<QrRepository>().clearScanned();
    }
  }

  // ── UI REPLACED — logic preserved above ───────────────────
  @override
  Widget build(BuildContext context) {
    final repo = context.watch<QrRepository>();
    final records = _filtered(repo);
    final count = records.length;

    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      appBar: AppBar(
        backgroundColor: context.colors.iosGroupedBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'History',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: context.colors.iosLabel,
            letterSpacing: 0.37,
          ),
        ),
        actions: [
          if (!_showFavorites && repo.scannedRecords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: AppStrings.deleteAll,
              color: context.colors.iosDestructive,
              onPressed: () {
                HapticFeedback.lightImpact();
                _confirmClearAll();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ── iOS Segmented Control ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: context.colors.iosSecondaryBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  _buildSegment(
                    label: 'All Scanned',
                    selected: !_showFavorites,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _showFavorites = false;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                  _buildSegment(
                    label: 'Favorites',
                    selected: _showFavorites,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _showFavorites = true;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── iOS Search Bar ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: context.colors.iosSecondaryLabel,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: context.colors.iosSecondaryLabel,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Icon(
                            Icons.cancel,
                            size: 18,
                            color: context.colors.iosSecondaryLabel,
                          ),
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: context.colors.iosTertiaryLabel.withValues(alpha: 0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 16, color: context.colors.iosLabel),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // ── Item count ────────────────────────────────────
          if (records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$count ${count == 1 ? AppStrings.item : AppStrings.items}',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.iosSecondaryLabel,
                  ),
                ),
              ),
            ),

          // ── List (iOS grouped style) ──────────────────────
          Expanded(
            child: records.isEmpty
                ? EmptyState(
                    message: _searchQuery.isNotEmpty
                        ? 'No results for "$_searchQuery"'
                        : _showFavorites
                            ? AppStrings.noFavoritesYet
                            : AppStrings.noHistoryYet,
                    icon: _showFavorites ? Icons.star_border : Icons.history,
                  )
                : ClipRRect(
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

  // ── iOS Segmented Control segment builder ──────────────────
  Widget _buildSegment({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? context.colors.iosBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: context.colors.iosBlue.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : context.colors.iosSecondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}
