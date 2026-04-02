import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _showFavorites = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Delete all scanned history? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<QrRepository>().clearScanned();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<QrRepository>();
    final records = _filtered(repo);
    final count = records.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.history),
        actions: [
          if (!_showFavorites && repo.scannedRecords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: AppStrings.deleteAll,
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: AppStrings.scanned,
                    selected: !_showFavorites,
                    onTap: () => setState(() {
                      _showFavorites = false;
                      _searchQuery = '';
                      _searchController.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    label: AppStrings.favorites,
                    selected: _showFavorites,
                    onTap: () => setState(() {
                      _showFavorites = true;
                      _searchQuery = '';
                      _searchController.clear();
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Item count
          if (records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$count ${count == 1 ? AppStrings.item : AppStrings.items}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          // List
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
                : ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16),
                    itemBuilder: (context, i) {
                      final r = records[i];
                      return QrListTile(
                        record: r,
                        onDelete: () =>
                            context.read<QrRepository>().delete(r.id),
                        onFavoriteToggle: () =>
                            context.read<QrRepository>().toggleFavorite(r.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
