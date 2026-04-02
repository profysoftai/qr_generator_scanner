import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
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
  final _permissionService = CameraPermissionService();
  MobileScannerController? _controller;
  CameraPermissionState _permState = CameraPermissionState.denied;
  bool _processing = false;
  bool _torchOn = false;
  bool _permChecked = false;
  bool _cameraRunning = false;

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
    _cameraRunning = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;

    if (!QrParser.isValid(rawValue)) {
      // Silently ignore empty/noise frames — only show error for non-null invalid
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
      await repo.add(record); // duplicate returns false but we still show result
    }

    if (!mounted) return;

    await ScanResultSheet.show(
      context,
      record: record,
      onScanAgain: _resumeScan,
    );
  }

  void _resumeScan() {
    if (!mounted) return;
    setState(() {
      _processing = false;
      _cameraRunning = true;
    });
    _controller?.start();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        title: const Text(
          AppStrings.scanQr,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: _torchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              _controller?.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
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
            errorBuilder: (context, error, child) => _CameraError(
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
          // Hint label
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  AppStrings.alignQrFrame,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permission Gate ───────────────────────────────────────────────────────────

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 72),
              const SizedBox(height: 20),
              Text(
                AppStrings.cameraPermissionTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPermanent
                    ? AppStrings.cameraPermissionDenied
                    : AppStrings.cameraPermissionMsg,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isPermanent ? onOpenSettings : onRequest,
                  child: Text(
                    isPermanent
                        ? AppStrings.openSettings
                        : AppStrings.grantPermission,
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

// ── Camera Error ──────────────────────────────────────────────────────────────

class _CameraError extends StatelessWidget {
  final VoidCallback onRetry;
  const _CameraError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text(
              AppStrings.errorGeneric,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
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
    const cutoutSize = 240.0;
    const radius = 16.0;
    const cornerLen = 24.0;
    const cornerThick = 3.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - cutoutSize / 2;
    final top = cy - cutoutSize / 2;
    final right = cx + cutoutSize / 2;
    final bottom = cy + cutoutSize / 2;

    // Dim background
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final cutout = RRect.fromLTRBR(
        left, top, right, bottom, const Radius.circular(radius));
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    // White border around cutout
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cutout, borderPaint);

    // Corner accents
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThick
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top + radius), cornerPaint);
    canvas.drawLine(Offset(left + radius, top), Offset(left + cornerLen, top), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(right - cornerLen, top), Offset(right - radius, top), cornerPaint);
    canvas.drawLine(Offset(right, top + radius), Offset(right, top + cornerLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(left, bottom - cornerLen), Offset(left, bottom - radius), cornerPaint);
    canvas.drawLine(Offset(left + radius, bottom), Offset(left + cornerLen, bottom), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(right - cornerLen, bottom), Offset(right - radius, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom - cornerLen), Offset(right, bottom - radius), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
