import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:qr_generator_scanner/core/constants/app_strings.dart';
import 'package:qr_generator_scanner/core/services/qr_share_service.dart';
import 'package:qr_generator_scanner/core/services/storage_permission_service.dart';

/// Mix this into any [State] that has a [GlobalKey] for a [RepaintBoundary].
/// Call [saveToGalleryWithPermission] with the repaint key.
mixin GallerySaveMixin<T extends StatefulWidget> on State<T> {
  final _storagePermService = StoragePermissionService();

  Future<void> saveToGalleryWithPermission(GlobalKey repaintKey) async {
    // 1. Check current state
    var state = await _storagePermService.check();

    // 2. Not required (Android 10–12) — go straight to save
    if (state == StoragePermissionState.notRequired) {
      await _doSave(repaintKey);
      return;
    }

    // 3. Already granted — save immediately
    if (state == StoragePermissionState.granted) {
      await _doSave(repaintKey);
      return;
    }

    // 4. Permanently denied — explain and route to Settings
    if (state == StoragePermissionState.permanentlyDenied) {
      await _showPermanentDenialDialog();
      return;
    }

    // 5. Denied (first time or previously denied) — show rationale then request
    final shouldRequest = await _showRationaleDialog();
    if (!shouldRequest || !mounted) return;

    state = await _storagePermService.request();

    if (!mounted) return;

    if (state == StoragePermissionState.granted ||
        state == StoragePermissionState.notRequired) {
      await _doSave(repaintKey);
    } else if (state == StoragePermissionState.permanentlyDenied) {
      await _showPermanentDenialDialog();
    } else {
      // Still denied after request
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.storagePermissionMsg)),
      );
    }
  }

  Future<void> _doSave(GlobalKey repaintKey) async {
    final ok = await QrShareService.saveToGallery(repaintKey);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            ok ? AppStrings.savedToGallery : AppStrings.errorSaveGallery),
      ),
    );
  }

  /// Shows a rationale dialog explaining why storage is needed.
  /// Returns true if the user taps "Grant Access".
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

  /// Shows a dialog explaining permanent denial and offers to open Settings.
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
