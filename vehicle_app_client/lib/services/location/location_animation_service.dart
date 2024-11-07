import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class LocationAnimationService {
  final ValueNotifier<double> _animationRadius = ValueNotifier(20.0);
  final ValueNotifier<Set<Circle>> _circles = ValueNotifier({});
  Timer? _animationTimer;
  LatLng? _lastCenter;
  double? _lastZoom;

  final double baseCircleRadius = 13.0;
  final double baseAnimationMaxRadius = 25.0;

  ValueListenable<Set<Circle>> get circles => _circles;

  void updateCircles(LatLng center, double currentZoom,
      [bool startAnimation = true]) {
    _lastCenter = center;
    _lastZoom = currentZoom;
    _updateCircleSet();

    if (startAnimation && _animationTimer == null) {
      _startAnimation();
    }
  }

  void _updateCircleSet() {
    if (_lastCenter == null || _lastZoom == null) return;

    final adjustedBaseRadius = _getAdjustedRadius(baseCircleRadius, _lastZoom!);
    final adjustedAnimationRadius =
        _getAdjustedRadius(_animationRadius.value, _lastZoom!);

    _circles.value = {
      Circle(
        circleId: const CircleId('current_location'),
        center: _lastCenter!,
        radius: adjustedBaseRadius,
        fillColor: const Color.fromARGB(255, 243, 33, 33).withOpacity(0.7),
        strokeWidth: 2,
        strokeColor: Colors.white,
        zIndex: 2,
      ),
      Circle(
        circleId: const CircleId('animation_circle'),
        center: _lastCenter!,
        radius: adjustedAnimationRadius,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeWidth: 2,
        strokeColor: Colors.blue.withOpacity(0.5),
        zIndex: 1,
      ),
    };
  }

  double _getAdjustedRadius(double baseRadius, double currentZoom) {
    return baseRadius * math.pow(2, 18 - currentZoom);
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (_animationRadius.value > baseAnimationMaxRadius) {
          _animationRadius.value = 20;
        } else {
          _animationRadius.value += 1;
        }
        _updateCircleSet(); // 애니메이션 상태가 변경될 때마다 원 업데이트
      },
    );
  }

  void dispose() {
    _animationTimer?.cancel();
  }
}
