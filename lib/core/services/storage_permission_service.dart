import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum StoragePermissionState {
  granted,       // permission held — safe to write
  denied,        // denied this session — can re-request
  permanentlyDenied, // user ticked "Don't ask again" — must open Settings
  notRequired,   // Android 10–12 Downloads folder needs no permission
}

class StoragePermissionService {
  /// Returns the correct [Permission] to request for saving to Downloads,
  /// or null when no permission is required (Android 10–12).
  static Future<Permission?> _requiredPermission() async {
    if (!Platform.isAndroid) return null; // iOS handled via share sheet
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    if (sdk <= 28) return Permission.storage;          // Android ≤ 9
    if (sdk <= 32) return null;                        // Android 10–12: no permission needed for Downloads
    return Permission.photos;                          // Android 13+: READ_MEDIA_IMAGES
  }

  /// Checks current state without prompting.
  Future<StoragePermissionState> check() async {
    final perm = await _requiredPermission();
    if (perm == null) return StoragePermissionState.notRequired;
    return _map(await perm.status);
  }

  /// Requests permission. Returns the resulting state.
  Future<StoragePermissionState> request() async {
    final perm = await _requiredPermission();
    if (perm == null) return StoragePermissionState.notRequired;
    return _map(await perm.request());
  }

  StoragePermissionState _map(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return StoragePermissionState.granted;
      case PermissionStatus.permanentlyDenied:
        return StoragePermissionState.permanentlyDenied;
      default:
        return StoragePermissionState.denied;
    }
  }
}
