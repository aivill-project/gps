import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math' as math;
import '../location/location_service.dart';

class MarkerMovementService {
  final LocationService locationService;
  final ValueNotifier<LatLng?> _destination = ValueNotifier(null);
  final ValueNotifier<bool> _isMoving = ValueNotifier(false);
  Timer? _movementTimer;
  final double movementSpeed = 0.00001;

  MarkerMovementService({required this.locationService});

  ValueNotifier<bool> get isMovingNotifier => _isMoving;
  bool get isMoving => _isMoving.value;

  void moveToPosition(LatLng position) {
    _destination.value = position;
    _startMovement();
  }

  void _startMovement() {
    if (_destination.value == null) return;
    _movementTimer?.cancel();

    final startLat = locationService.center.value.latitude;
    final startLng = locationService.center.value.longitude;
    final endLat = _destination.value!.latitude;
    final endLng = _destination.value!.longitude;

    final distance = _calculateDistance(startLat, startLng, endLat, endLng);
    final duration = (distance / movementSpeed).round();

    var elapsedTime = 0;
    _isMoving.value = true;

    _movementTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (elapsedTime >= duration) {
        timer.cancel();
        locationService.updateCurrentLocation(_destination.value!);
        _isMoving.value = false;
        return;
      }

      final progress = elapsedTime / duration;
      final newLat = startLat + (endLat - startLat) * progress;
      final newLng = startLng + (endLng - startLng) * progress;

      locationService.updateCurrentLocation(LatLng(newLat, newLng));
      elapsedTime++;
    });
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    return math
        .sqrt((lat2 - lat1) * (lat2 - lat1) + (lng2 - lng1) * (lng2 - lng1));
  }

  void dispose() {
    _movementTimer?.cancel();
  }
}
