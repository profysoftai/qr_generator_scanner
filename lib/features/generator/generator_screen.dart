import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/services/qr_share_service.dart';
import 'package:qr_generator_scanner/core/utils/qr_parser.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/gallery_save_mixin.dart';
import 'package:qr_generator_scanner/shared/widgets/qr_view.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen>
    with GallerySaveMixin {
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

  void _generate() {
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
        const SnackBar(content: Text(AppStrings.duplicateWarning)),
      );
      setState(() => _saved = true);
      return;
    }
    final contentType = QrParser.detect(_qrData);
    final added = await repo.add(QrRecord(
      id: const Uuid().v4(),
      data: _qrData,
      type: 'generated',
      label: QrParser.label(contentType),
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    if (added) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code saved to My QRs')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorGeneric)),
      );
    }
  }

  Future<void> _copyData() async {
    if (_qrData.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _qrData));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  Future<void> _share() async {
    final ok = await QrShareService.share(_repaintKey, subject: _qrData);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.errorShare)));
    }
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await saveToGalleryWithPermission(_repaintKey);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final contentType = _qrData.isNotEmpty ? QrParser.detect(_qrData) : null;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.generateQr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'e.g. https://example.com or Hello World',
                  labelText: AppStrings.enterTextOrUrl,
                  border: const OutlineInputBorder(),
                  errorText: _inputError,
                ),
                onChanged: (_) {
                  if (_inputError != null) {
                    setState(() => _inputError = null);
                  }
                },
                onSubmitted: (_) => _generate(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.qr_code_2),
                label: const Text(AppStrings.generateQrCode),
              ),
              const SizedBox(height: 32),
              if (_qrData.isEmpty)
                Column(
                  children: [
                    Icon(Icons.qr_code_2,
                        size: 80,
                        color: Theme.of(context).colorScheme.outlineVariant),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.qrWillAppear,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Content type badge
                    if (contentType != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(QrParser.icon(contentType),
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              QrParser.label(contentType),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                          ],
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
                    const SizedBox(height: 20),
                    // Row 1: Copy Data | Save to My QRs
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyData,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy Data'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saved ? null : _save,
                            icon: Icon(
                                _saved ? Icons.check : Icons.save_outlined,
                                size: 18),
                            label: Text(_saved ? 'Saved' : 'Save to My QRs'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row 2: Share | Save to Gallery
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _share,
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text(AppStrings.shareQr),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSaving ? null : _saveToGallery,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.download_outlined,
                                    size: 18),
                            label: const Text(AppStrings.saveToGallery),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
