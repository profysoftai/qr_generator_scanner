import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionState { granted, denied, permanentlyDenied, restricted }

class CameraPermissionService {
  Future<CameraPermissionState> request() async {
    final status = await Permission.camera.request();
    return _map(status);
  }

  Future<CameraPermissionState> check() async {
    final status = await Permission.camera.status;
    return _map(status);
  }

  Future<void> openSettings() => openAppSettings();

  CameraPermissionState _map(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return CameraPermissionState.granted;
      case PermissionStatus.permanentlyDenied:
        return CameraPermissionState.permanentlyDenied;
      case PermissionStatus.restricted:
        return CameraPermissionState.restricted;
      default:
        return CameraPermissionState.denied;
    }
  }
}
