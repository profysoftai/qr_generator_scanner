import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_generator_scanner/core/constants/app_colors.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/ad_service.dart';
import 'package:qr_generator_scanner/core/services/camera_permission_service.dart';
import 'package:qr_generator_scanner/core/services/qr_repository.dart';
import 'package:qr_generator_scanner/core/services/settings_provider.dart';
import 'package:qr_generator_scanner/core/utils/qr_parser.dart';
import 'package:qr_generator_scanner/shared/models/qr_record.dart';
import 'package:qr_generator_scanner/shared/widgets/scan_result_sheet.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  // ── State — DO NOT TOUCH ──────────────────────────────────
  final _permissionService = CameraPermissionService();
  MobileScannerController? _controller;
  CameraPermissionState _permState = CameraPermissionState.denied;
  bool _processing = false;
  bool _torchOn = false;
  bool _permChecked = false;
  bool _cameraRunning = false;

  // ── Lifecycle — DO NOT TOUCH ──────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_permState == CameraPermissionState.granted && _cameraRunning) {
        _controller?.start();
      } else {
        // User may have granted permission from device settings
        _checkPermission();
      }
    } else if (state == AppLifecycleState.paused) {
      _controller?.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  // ── Logic methods — DO NOT TOUCH ──────────────────────────
  Future<void> _checkPermission() async {
    final state = await _permissionService.check();
    if (!mounted) return;

    final wasGranted = _permState == CameraPermissionState.granted;
    final nowGranted = state == CameraPermissionState.granted;

    // Only init camera if transitioning from non-granted → granted
    if (nowGranted && !wasGranted) {
      _initCamera();
    }

    setState(() {
      _permState = state;
      _permChecked = true;
    });
  }

  Future<void> _requestPermission() async {
    final state = await _permissionService.request();
    if (!mounted) return;
    if (state == CameraPermissionState.granted) {
      _initCamera();
    }
    setState(() => _permState = state);
  }

  void _initCamera() {
    if (_controller != null) return; // already initialized
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    // _cameraRunning is NOT set here — the camera has not started yet.
    // It is set to true only in _resumeScan() and _onDetect() after a
    // confirmed successful start, so errorBuilder can always reset it.
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;

    if (!QrParser.isValid(rawValue)) {
      if (rawValue != null && rawValue.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorInvalidQr),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    _processing = true;

    // Capture providers before any await
    final settings = context.read<SettingsProvider>();
    final repo = context.read<QrRepository>();
    final value = rawValue!;
    final contentType = QrParser.detect(value);

    await _controller?.stop();
    _cameraRunning = false;

    final record = QrRecord(
      id: const Uuid().v4(),
      data: value,
      type: 'scanned',
      label: QrParser.label(contentType),
      createdAt: DateTime.now(),
    );

    if (settings.saveScanHistory) {
      await repo.add(record);
    }

    if (!mounted) return;

    // Haptic feedback on successful scan
    HapticFeedback.mediumImpact();

    // Await the sheet — it completes when dismissed by ANY means:
    // swipe down, tap outside, or "Scan Again" button.
    await ScanResultSheet.show(
      context,
      record: record,
      onScanAgain: _resumeScan,
    );

    if (!mounted) return;
    // Trigger interstitial every 3rd scan — called after sheet is fully dismissed.
    AdService.instance.onScanCompleted();

    // Always resume after sheet closes, regardless of how it was dismissed.
    // _resumeScan guards against double-start if button was already tapped.
    _resumeScan();
  }

  void _resumeScan() {
    if (!mounted || _cameraRunning) return; // already running — skip
    setState(() {
      _processing = false;
      _cameraRunning = true;
    });
    _controller?.start();
  }

  // ── UI REPLACED — logic preserved above ───────────────────
  @override
  Widget build(BuildContext context) {
    if (!_permChecked) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: context.colors.iosBlue),
        ),
      );
    }

    if (_permState != CameraPermissionState.granted) {
      return _PermissionGate(
        state: _permState,
        onRequest: _requestPermission,
        onOpenSettings: () => ph.openAppSettings(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _controller?.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Container(
                  key: ValueKey(_torchOn),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _torchOn
                        ? context.colors.iosWarning
                        : Colors.transparent,
                    border: _torchOn
                        ? null
                        : Border.all(
                            color: context.colors.iosSeparator.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                  ),
                  child: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: _torchOn ? Colors.white : context.colors.iosSecondaryLabel,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed — must be first so it receives all touch/frame events
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _CameraError(
              onRetry: () {
                _controller?.dispose();
                _controller = null;
                setState(() {
                  _processing = false;
                  _cameraRunning = false;
                });
                _initCamera();
                setState(() {});
              },
            ),
          ),
          // Overlay drawn with CustomPaint — does NOT intercept touch events
          const _ScanOverlay(),
          // Bottom hint label
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Position QR code in frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permission Gate (iOS style) ───────────────────────────────────────────────

class _PermissionGate extends StatelessWidget {
  final CameraPermissionState state;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  const _PermissionGate({
    required this.state,
    required this.onRequest,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isPermanent = state == CameraPermissionState.permanentlyDenied ||
        state == CameraPermissionState.restricted;

    return Scaffold(
      backgroundColor: context.colors.iosGroupedBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // iOS-style icon container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.colors.iosBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: context.colors.iosBlue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Camera Access\nNeeded',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.colors.iosLabel,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPermanent
                    ? AppStrings.cameraPermissionDenied
                    : AppStrings.cameraPermissionMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: context.colors.iosSecondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Primary action button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (isPermanent) {
                      onOpenSettings();
                    } else {
                      onRequest();
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
                  child: Text(
                    isPermanent
                        ? AppStrings.openSettings
                        : 'Allow Camera Access',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (isPermanent) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onOpenSettings();
                  },
                  child: Text(
                    'Open Settings',
                    style: TextStyle(
                      fontSize: 17,
                      color: context.colors.iosBlue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Camera Error (iOS style) ──────────────────────────────────────────────────

class _CameraError extends StatelessWidget {
  final VoidCallback onRetry;
  const _CameraError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.iosDestructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: context.colors.iosDestructive,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Camera Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.errorGeneric,
                style: TextStyle(
                  color: context.colors.iosSecondaryLabel,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onRetry();
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
                    'Retry',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scan Overlay (CustomPaint — no hit-test blocking) ─────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _OverlayPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 260.0;
    const radius = 20.0;
    const cornerLen = 28.0;
    const cornerThick = 4.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - cutoutSize / 2;
    final top = cy - cutoutSize / 2;
    final right = cx + cutoutSize / 2;
    final bottom = cy + cutoutSize / 2;

    // Dim background — black 60% alpha
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final cutout = RRect.fromLTRBR(
        left, top, right, bottom, const Radius.circular(radius));
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    // Corner accents — iosBlue (#007AFF)
    const iosBlue = Color(0xFF007AFF);
    final cornerPaint = Paint()
      ..color = iosBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThick
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
        Offset(left, top + cornerLen), Offset(left, top + radius), cornerPaint);
    canvas.drawLine(
        Offset(left + radius, top), Offset(left + cornerLen, top), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(right - cornerLen, top), Offset(right - radius, top),
        cornerPaint);
    canvas.drawLine(Offset(right, top + radius), Offset(right, top + cornerLen),
        cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(left, bottom - cornerLen),
        Offset(left, bottom - radius), cornerPaint);
    canvas.drawLine(Offset(left + radius, bottom),
        Offset(left + cornerLen, bottom), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(right - cornerLen, bottom),
        Offset(right - radius, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom - cornerLen),
        Offset(right, bottom - radius), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
