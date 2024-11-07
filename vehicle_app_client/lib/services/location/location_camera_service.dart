import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:logger/logger.dart';

class LocationCameraService {
  GoogleMapController? mapController;
  double _currentZoom = 18.0;
  final ValueNotifier<Set<Circle>> _circles = ValueNotifier({});
  Timer? _animationTimer;
  LatLng? _currentPosition;

  // 애니메이션 관련 상수
  static const double _baseRadius = 13.0;
  static const double _animationMinRadius = 20.0;
  static const double _animationMaxRadius = 25.0;
  double _animationRadius = _animationMinRadius;

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  double get currentZoom => _currentZoom;
  ValueNotifier<Set<Circle>> get circles => _circles;

  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    _updateCircles(false);
  }

  void updateMyLocationCircle(LatLng position) {
    _currentPosition = position;
    _updateCircles();
    if (_animationTimer == null) {
      _startAnimation();
    }
  }

  double _getAdjustedRadius(double baseRadius) {
    return baseRadius * math.pow(2, 18 - _currentZoom);
  }

  void _updateCircles([bool startAnimation = true]) {
    if (_currentPosition == null) return;

    final adjustedBaseRadius = _getAdjustedRadius(_baseRadius);
    final adjustedAnimationRadius = _getAdjustedRadius(_animationRadius);

    _circles.value = {
      Circle(
        circleId: const CircleId('base_circle'),
        center: _currentPosition!,
        radius: adjustedBaseRadius,
        fillColor: const Color.fromARGB(255, 243, 33, 33).withOpacity(0.7),
        strokeWidth: 2,
        strokeColor: Colors.white,
        zIndex: 2,
      ),
      Circle(
        circleId: const CircleId('animation_circle'),
        center: _currentPosition!,
        radius: adjustedAnimationRadius,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeWidth: 2,
        strokeColor: Colors.blue.withOpacity(0.5),
        zIndex: 1,
      ),
    };
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        _animationRadius += 0.5;
        if (_animationRadius >= _animationMaxRadius) {
          _animationRadius = _animationMinRadius;
        }
        _updateCircles(false);
      },
    );
  }

  Future<void> dispose() async {
    _animationTimer?.cancel();
    if (mapController != null) {
      mapController!.dispose();
      mapController = null;
    }
  }

  void moveCamera(LatLng target) {
    if (mapController == null) return;

    try {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: _currentZoom,
          ),
        ),
      );
    } catch (e) {
      _logger.w('카메라 이동 중 오류 발생: $e');
    }
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }
}
