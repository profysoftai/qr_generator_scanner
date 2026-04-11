import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import '../models/qr_type.dart';
import '../services/qr_format_service.dart';
import 'qr_preview_screen.dart';

class QrTypeFormScreen extends StatefulWidget {
  final QrTypeData typeData;

  const QrTypeFormScreen({super.key, required this.typeData});

  @override
  State<QrTypeFormScreen> createState() => _QrTypeFormScreenState();
}

class _QrTypeFormScreenState extends State<QrTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    for (final key in _fieldKeys(widget.typeData.type)) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _fieldKeys(QrType type) {
    switch (type) {
      case QrType.text:
        return ['text'];
      case QrType.email:
        return ['email', 'subject', 'body'];
      case QrType.url:
        return ['url'];
      case QrType.sms:
        return ['phone', 'message'];
      case QrType.location:
        return ['latitude', 'longitude'];
      case QrType.social:
        return ['url'];
      case QrType.appDownload:
        return ['url'];
      case QrType.upi:
        return ['upiHandle', 'upiProvider', 'name', 'amount', 'note'];
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    var fields = _controllers.map((k, v) => MapEntry(k, v.text.trim()));
    // Combine upiHandle + upiProvider into upiId for QrFormatService
    if (widget.typeData.type == QrType.upi) {
      final handle = fields['upiHandle'] ?? '';
      final provider = fields['upiProvider'] ?? '';
      fields = Map.from(fields)..[('upiId')] = '$handle@$provider';
    }
    final qrData = QrFormatService.build(widget.typeData.type, fields);
    if (qrData.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrPreviewScreen(
          typeData: widget.typeData,
          qrData: qrData,
        ),
      ),
    );
  }

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Enable in Settings.'),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        _controllers['latitude']!.text =
            position.latitude.toStringAsFixed(6);
        _controllers['longitude']!.text =
            position.longitude.toStringAsFixed(6);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch location. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      appBar: AppBar(
        backgroundColor: context.colors.iosGroupedBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.arrow_back_ios_new,
                size: 20, color: context.colors.iosBlue),
          ),
        ),
        title: Text(
          widget.typeData.title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.colors.iosLabel,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Type header card ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.typeData.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.typeData.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: widget.typeData.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.typeData.icon,
                            size: 22, color: widget.typeData.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.typeData.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.colors.iosLabel,
                              ),
                            ),
                            Text(
                              widget.typeData.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.iosSecondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Form fields ───────────────────────────────
                _buildFields(widget.typeData.type),

                const SizedBox(height: 28),

                // ── Generate button ───────────────────────────
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.qr_code_2, size: 20),
                    label: const Text(
                      'Generate QR Code',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.typeData.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFields(QrType type) {
    switch (type) {
      case QrType.text:
        return _card([
          _field(
            key: 'text',
            label: 'Text',
            hint: 'Enter any text or message...',
            maxLines: 5,
            validator: _required,
          ),
        ]);

      case QrType.email:
        return _card([
          _field(
            key: 'email',
            label: 'Email Address',
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          _divider(),
          _field(
            key: 'subject',
            label: 'Subject',
            hint: 'Email subject (optional)',
          ),
          _divider(),
          _field(
            key: 'body',
            label: 'Message',
            hint: 'Email body (optional)',
            maxLines: 4,
          ),
        ]);

      case QrType.url:
        return _card([
          _field(
            key: 'url',
            label: 'Website URL',
            hint: 'https://example.com',
            keyboardType: TextInputType.url,
            validator: _validateUrl,
          ),
        ]);

      case QrType.sms:
        return _card([
          _field(
            key: 'phone',
            label: 'Phone Number',
            hint: '+91 9876543210',
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          _divider(),
          _field(
            key: 'message',
            label: 'Message',
            hint: 'SMS message text...',
            maxLines: 4,
            validator: _required,
          ),
        ]);

      case QrType.location:
        return Column(
          children: [
            _card([
              _field(
                key: 'latitude',
                label: 'Latitude',
                hint: '28.613939',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                validator: _validateLatitude,
              ),
              _divider(),
              _field(
                key: 'longitude',
                label: 'Longitude',
                hint: '77.209023',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                validator: _validateLongitude,
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _fetchingLocation ? null : _fetchLocation,
                icon: _fetchingLocation
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.typeData.color),
                      )
                    : Icon(Icons.my_location_rounded,
                        size: 18, color: widget.typeData.color),
                label: Text(
                  _fetchingLocation ? 'Fetching...' : 'Use Current Location',
                  style: TextStyle(
                      fontSize: 14,
                      color: widget.typeData.color,
                      fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.typeData.color, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );

      case QrType.social:
        return _card([
          _field(
            key: 'url',
            label: 'Profile URL',
            hint: 'https://instagram.com/username',
            keyboardType: TextInputType.url,
            validator: _validateUrl,
          ),
        ]);

      case QrType.appDownload:
        return _card([
          _field(
            key: 'url',
            label: 'Store Link',
            hint: 'https://play.google.com/store/apps/...',
            keyboardType: TextInputType.url,
            validator: _validateUrl,
          ),
        ]);

      case QrType.upi:
        return _card([
          _upiIdField(),
          _divider(),
          _field(
            key: 'name',
            label: 'Payee Name',
            hint: 'Recipient name',
            validator: _required,
          ),
          _divider(),
          _field(
            key: 'amount',
            label: 'Amount (optional)',
            hint: '100.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateAmount,
          ),
          _divider(),
          _field(
            key: 'note',
            label: 'Note (optional)',
            hint: 'Payment note',
          ),
        ]);
    }
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.iosSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.iosSeparator.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => Divider(
        height: 0.5,
        thickness: 0.5,
        indent: 16,
        color: context.colors.iosSeparator,
      );

  // ── UPI ID split field (handle @ provider) ───────────────────────────────
  Widget _upiIdField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPI ID',
            style: TextStyle(
              fontSize: 15,
              color: context.colors.iosSecondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle (before @)
              Expanded(
                child: TextFormField(
                  controller: _controllers['upiHandle'],
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16, color: context.colors.iosLabel),
                  decoration: InputDecoration(
                    hintText: 'abcd',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: context.colors.iosTertiaryLabel,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosSeparator,
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosSeparator,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosBlue,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosDestructive,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosDestructive,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: context.colors.iosSecondaryBg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    errorStyle: TextStyle(
                      fontSize: 12,
                      color: context.colors.iosDestructive,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim().contains('@')) return 'No @ needed';
                    return null;
                  },
                ),
              ),
              // Fixed @ symbol
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Text(
                  '@',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.iosBlue,
                  ),
                ),
              ),
              // Provider (after @)
              Expanded(
                child: TextFormField(
                  controller: _controllers['upiProvider'],
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16, color: context.colors.iosLabel),
                  decoration: InputDecoration(
                    hintText: 'ybl',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: context.colors.iosTertiaryLabel,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosSeparator,
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosSeparator,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosBlue,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosDestructive,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: context.colors.iosDestructive,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: context.colors.iosSecondaryBg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    errorStyle: TextStyle(
                      fontSize: 12,
                      color: context.colors.iosDestructive,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim().contains('@')) return 'No @ needed';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String key,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(fontSize: 16, color: context.colors.iosLabel),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 15,
            color: context.colors.iosSecondaryLabel,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15,
            color: context.colors.iosTertiaryLabel,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          errorStyle: TextStyle(
            fontSize: 12,
            color: context.colors.iosDestructive,
          ),
        ),
      ),
    );
  }

  // ── Validators ──────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required.' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address.';
    return null;
  }

  String? _validateUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'URL is required.';
    var url = v.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) return 'Enter a valid URL.';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required.';
    final digits = v.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  String? _validateLatitude(String? v) {
    if (v == null || v.trim().isEmpty) return 'Latitude is required.';
    final d = double.tryParse(v.trim());
    if (d == null || d < -90 || d > 90) return 'Enter a valid latitude (-90 to 90).';
    return null;
  }

  String? _validateLongitude(String? v) {
    if (v == null || v.trim().isEmpty) return 'Longitude is required.';
    final d = double.tryParse(v.trim());
    if (d == null || d < -180 || d > 180) return 'Enter a valid longitude (-180 to 180).';
    return null;
  }

  String? _validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final d = double.tryParse(v.trim());
    if (d == null || d < 0) return 'Enter a valid amount.';
    return null;
  }
}
