import 'package:flutter/material.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'models/qr_type.dart';
import 'screens/qr_type_form_screen.dart';
import 'widgets/qr_type_card.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  List<QrTypeData> _filtered = kQrTypes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final q = value.trim().toLowerCase();
    setState(() {
      _query = q;
      _filtered = q.isEmpty
          ? kQrTypes
          : kQrTypes
              .where((t) =>
                  t.title.toLowerCase().contains(q) ||
                  t.description.toLowerCase().contains(q))
              .toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearch('');
  }

  void _openForm(QrTypeData data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QrTypeFormScreen(typeData: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      appBar: AppBar(
        backgroundColor: context.colors.iosGroupedBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'QR Generator',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: context.colors.iosLabel,
            letterSpacing: 0.37,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Search bar ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: TextStyle(
                      fontSize: 15, color: context.colors.iosLabel),
                  decoration: InputDecoration(
                    hintText: 'Search QR types...',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: context.colors.iosSecondaryLabel,
                    ),
                    prefixIcon: Icon(Icons.search,
                        size: 20,
                        color: context.colors.iosSecondaryLabel),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: _clearSearch,
                            child: Icon(Icons.cancel,
                                size: 18,
                                color: context.colors.iosSecondaryLabel),
                          )
                        : null,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 9),
                    filled: true,
                    fillColor: context.colors.iosTertiaryLabel
                        .withValues(alpha: 0.12),
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
                ),
              ),
            ),
          ),

          // ── Section label ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Text(
                _query.isEmpty
                    ? 'CHOOSE A TYPE'
                    : '${_filtered.length} RESULT${_filtered.length == 1 ? '' : 'S'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.iosSecondaryLabel,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // ── Grid or empty state ─────────────────────────────
          _filtered.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: context.colors.iosSecondaryBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(Icons.search_off_rounded,
                              size: 32,
                              color: context.colors.iosSecondaryLabel),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: context.colors.iosLabel,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.iosSecondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 130,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => QrTypeCard(
                        data: _filtered[i],
                        onTap: () => _openForm(_filtered[i]),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
