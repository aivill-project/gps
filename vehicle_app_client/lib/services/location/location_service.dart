import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_permission_service.dart';
import 'location_animation_service.dart';
import 'package:logger/logger.dart';
import 'dart:async';

class LocationService {
  final LocationPermissionService _permissionService;
  final LocationAnimationService _animationService;
  final _logger = Logger();
  GoogleMapController? _mapController;
  double _currentZoom = 18.0;
  
  // 초기값을 제거하고 late로 선언
  final ValueNotifier<LatLng> _center = ValueNotifier(const LatLng(37.5665, 126.9780));

  final _locationController = StreamController<LatLng>.broadcast();
  Stream<LatLng> get locationStream => _locationController.stream;

  Timer? _locationTimer;

  LocationService()
      : _permissionService = LocationPermissionService(),
        _animationService = LocationAnimationService();

  ValueListenable<LatLng> get center => _center;
  ValueListenable<Set<Circle>> get circles => _animationService.circles;
  bool get isPermissionGranted => _permissionService.isPermissionGranted;

  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    _animationService.updateCircles(_center.value, _currentZoom);
  }

  Future<void> requestLocationPermission() async {
    await _permissionService.requestLocationPermission();
    if (_permissionService.isPermissionGranted) {
      await getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await _permissionService.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);
      _center.value = newLocation;
      _animationService.updateCircles(newLocation, _currentZoom);
      moveCamera(newLocation);
      _locationController.add(newLocation);
      _logger.d("현재 위치 업데이트: ${newLocation.latitude}, ${newLocation.longitude}");
    } catch (e) {
      _logger.e("위치 업데이트 실패", error: e);
    }
  }

  void moveCamera(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: _currentZoom,
        ),
      ),
    );
  }

  void updateCurrentLocation(LatLng position) {
    _center.value = position;
    _animationService.updateCircles(position, _currentZoom);
    moveCamera(position);
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_permissionService.isPermissionGranted) {
      getCurrentLocation();
    }
  }

  Future<void> startLocationUpdates() async {
    _logger.d("위치 업데이트 시작");
    
    // 권한 확인
    if (!_permissionService.isPermissionGranted) {
      _logger.w("위치 권한이 없습니다. 권한을 요청합니다.");
      await requestLocationPermission();
    }

    // 현재 위치로 초기화
    await getCurrentLocation();
    
    // 이전 타이머가 있다면 취소
    _locationTimer?.cancel();
    
    // 주기적으로 위치 업데이트
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final position = await _permissionService.getCurrentPosition();
        final location = LatLng(position.latitude, position.longitude);
        _logger.d("새로운 위치: ${location.latitude}, ${location.longitude}");
        _locationController.add(location);
        updateCurrentLocation(location);  // 지도 업데이트도 함께 수행
      } catch (e) {
        _logger.e("위치 업데이트 실패", error: e);
      }
    });
  }

  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  void dispose() {
    stopLocationUpdates();
    _animationService.dispose();
    _mapController?.dispose();
    _locationController.close();
  }
}
