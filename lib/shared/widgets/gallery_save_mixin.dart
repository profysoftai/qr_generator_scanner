import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_share_service.dart';
import 'package:qr_generator_scanner/core/services/storage_permission_service.dart';

/// Mix this into any [State] that has a [GlobalKey] for a [RepaintBoundary].
/// Call [saveToGalleryWithPermission] with the repaint key.
///
/// Pass [messengerKey] when calling from a bottom sheet so the snackbar
/// appears on the parent Scaffold, not the sheet's own context.
mixin GallerySaveMixin<T extends StatefulWidget> on State<T> {
  final _storagePermService = StoragePermissionService();

  Future<void> saveToGalleryWithPermission(
    GlobalKey repaintKey, {
    ScaffoldMessengerState? messenger,
  }) async {
    // Capture messenger synchronously before any await.
    // Falls back to the widget's own context if none provided.
    final msg = messenger ?? ScaffoldMessenger.of(context);

    // 1. Check current permission state
    var permState = await _storagePermService.check();

    // 2. No permission needed (Android 10–12) — save immediately
    if (permState == StoragePermissionState.notRequired) {
      await _doSave(repaintKey, msg);
      return;
    }

    // 3. Already granted — save immediately
    if (permState == StoragePermissionState.granted) {
      await _doSave(repaintKey, msg);
      return;
    }

    // 4. Permanently denied — open Settings dialog
    if (permState == StoragePermissionState.permanentlyDenied) {
      if (!mounted) return;
      await _showPermanentDenialDialog();
      return;
    }

    // 5. Denied — show rationale then request
    if (!mounted) return;
    final shouldRequest = await _showRationaleDialog();
    if (!shouldRequest || !mounted) return;

    permState = await _storagePermService.request();

    if (!mounted) return;

    if (permState == StoragePermissionState.granted ||
        permState == StoragePermissionState.notRequired) {
      // Permission just granted — continue to save
      await _doSave(repaintKey, msg);
    } else if (permState == StoragePermissionState.permanentlyDenied) {
      await _showPermanentDenialDialog();
    } else {
      // Still denied after request
      msg.showSnackBar(
        const SnackBar(content: Text(AppStrings.storagePermissionMsg)),
      );
    }
  }

  Future<void> _doSave(GlobalKey repaintKey, ScaffoldMessengerState msg) async {
    final ok = await QrShareService.saveToGallery(repaintKey);
    // Use the pre-captured messenger — safe even if widget is unmounted
    msg.showSnackBar(
      SnackBar(
        content: Text(
          ok ? AppStrings.savedToGallery : AppStrings.errorSaveGallery,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showRationaleDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.storagePermissionTitle),
        content: const Text(AppStrings.storagePermissionMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.storagePermissionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.storagePermissionGrant),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showPermanentDenialDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.storagePermissionDeniedTitle),
        content: const Text(AppStrings.storagePermissionDenied),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.storagePermissionCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ph.openAppSettings();
            },
            child: const Text(AppStrings.storagePermissionOpenSettings),
          ),
        ],
      ),
    );
  }
}
