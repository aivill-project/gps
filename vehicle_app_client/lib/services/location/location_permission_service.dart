import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationPermissionService {
  final logger = Logger();
  final ValueNotifier<bool> permissionGranted = ValueNotifier(false);
  bool isPermissionGranted = false;

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    permissionGranted.value = status.isGranted;
  }

  Future<bool> checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w("위치 서비스가 비활성화되어 있습니다.");
      return false;
    }
    return true;
  }

  Future<Position> getCurrentPosition() async {
    if (!await checkLocationService()) {
      throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.');
    }

    if (!await Permission.location.isGranted) {
      await requestLocationPermission();
      if (!isPermissionGranted) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    try {
      logger.d("위치 정보 요청 시작");
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      logger.i("현재 위치: lat=${position.latitude}, lng=${position.longitude}");
      return position;
    } catch (e, stackTrace) {
      logger.e("위치를 가져오는데 실패했습니다", error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
