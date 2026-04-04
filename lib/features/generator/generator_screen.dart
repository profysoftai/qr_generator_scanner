import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/services/qr_share_service.dart';
import 'package:qr_generator_scanner/core/utils/qr_parser.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/empty_state.dart';
import 'package:qr_generator_scanner/shared/widgets/gallery_save_mixin.dart';
import 'package:qr_generator_scanner/shared/widgets/qr_view.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen>
    with GallerySaveMixin {
  // ── State — DO NOT TOUCH ──────────────────────────────────
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _repaintKey = GlobalKey();
  String _qrData = '';
  bool _saved = false;
  bool _isSaving = false;
  String? _inputError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Logic methods — DO NOT TOUCH ──────────────────────────
  void _generate() {
    HapticFeedback.lightImpact();
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _inputError = AppStrings.errorEmptyInput);
      return;
    }
    if (!QrParser.isValid(text)) {
      setState(() => _inputError = AppStrings.errorInvalidQr);
      return;
    }
    setState(() {
      _qrData = text;
      _saved = false;
      _inputError = null;
    });
  }

  Future<void> _save() async {
    if (_qrData.isEmpty || _saved) return;
    final repo = context.read<QrRepository>();
    if (repo.isDuplicate(_qrData, 'generated')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.duplicateWarning)),
      );
      setState(() => _saved = true);
      return;
    }
    final contentType = QrParser.detect(_qrData);
    final added = await repo.add(QrRecord(
      id: Uuid().v4(),
      data: _qrData,
      type: 'generated',
      label: QrParser.label(contentType),
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    if (added) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR code saved to My QRs')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.errorGeneric)),
      );
    }
  }

  Future<void> _copyData() async {
    if (_qrData.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _qrData));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Copied to clipboard')));
  }

  Future<void> _share() async {
    final ok = await QrShareService.share(_repaintKey, subject: _qrData);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.errorShare)));
    }
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await saveToGalleryWithPermission(_repaintKey);
    if (mounted) setState(() => _isSaving = false);
  }

  // ── UI REPLACED — logic preserved above ───────────────────
  @override
  Widget build(BuildContext context) {
    final contentType = _qrData.isNotEmpty ? QrParser.detect(_qrData) : null;

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Input Section (grouped card style) ─────────
              Container(
                decoration: BoxDecoration(
                  color: context.colors.iosSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.iosSeparator.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter text, URL, email...',
                        hintStyle: TextStyle(
                          color: context.colors.iosSecondaryLabel,
                          fontSize: 16,
                        ),
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        errorText: _inputError,
                        errorStyle: TextStyle(
                          color: context.colors.iosDestructive,
                          fontSize: 12,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.iosLabel,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      onChanged: (_) {
                        if (_inputError != null) {
                          setState(() => _inputError = null);
                        }
                      },
                      onSubmitted: (_) => _generate(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // ── Generate Button ────────────────────────────
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _generate();
                  },
                  icon: Icon(Icons.qr_code_2, size: 20),
                  label: Text(
                    'Generate QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.iosBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // ── QR Preview or Empty State ──────────────────
              if (_qrData.isEmpty)
                EmptyState(
                  message: 'No QR Code Yet',
                  icon: Icons.qr_code_2,
                )
              else
                _buildQrPreview(contentType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrPreview(QrContentType? contentType) {
    return Column(
      children: [
        // ── QR Card ─────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.iosSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.iosSeparator.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              // Content type badge
              if (contentType != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.iosBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          QrParser.icon(contentType),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 4),
                        Text(
                          QrParser.label(contentType),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.colors.iosBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // QR image — wrapped in RepaintBoundary via repaintKey
              Center(
                child: QrView(
                  data: _qrData,
                  size: 220,
                  repaintKey: _repaintKey,
                ),
              ),

              SizedBox(height: 16),

              // Data preview
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.iosSecondaryBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _qrData,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.iosSecondaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // ── Row 1: Save to My QRs ───────────────────────────
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saved
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    _save();
                  },
            icon: Icon(
              _saved ? Icons.check_rounded : Icons.bookmark_add_outlined,
              size: 20,
            ),
            label: Text(
              _saved ? 'Saved' : 'Save to My QRs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _saved ? context.colors.iosSuccess : context.colors.iosBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: context.colors.iosSuccess.withValues(alpha: 0.8),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: 10),

        // ── Row 2: Copy | Share | Gallery ───────────────────
        Row(
          children: [
            // Copy
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _copyData();
                  },
                  icon: Icon(Icons.copy_rounded, size: 16),
                  label: Text('Copy', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.iosBlue,
                    side: BorderSide(color: context.colors.iosBlue, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Share
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _share();
                  },
                  icon: Icon(Icons.share_outlined, size: 16),
                  label: Text('Share', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.iosBlue,
                    side: BorderSide(color: context.colors.iosBlue, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Gallery
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          _saveToGallery();
                        },
                  icon: _isSaving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.iosBlue,
                          ),
                        )
                      : Icon(Icons.download_rounded, size: 16),
                  label: Text('Gallery', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.iosBlue,
                    side: BorderSide(color: context.colors.iosBlue, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
