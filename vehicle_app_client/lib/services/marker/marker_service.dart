import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math' as math;
import '../location/location_service.dart';
import 'marker_ui_service.dart';
import '../../../main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/api_config.dart';

class MarkerService {
  final LocationService locationService;
  final ValueNotifier<Set<Marker>> _markers = ValueNotifier({});
  final MarkerUIService _markerUIService;
  final ValueNotifier<bool> _isMoving = ValueNotifier(false);
  Timer? _movementTimer;
  GoogleMapController? _mapController;
  final double movementSpeed = 0.00002;
  final ValueNotifier<Set<Circle>> _markerCircles = ValueNotifier({});
  static const double markerRadius = 100.0; // 100m 반경
  final String apiUrl = '${ApiConfig.baseUrl}/markers'; // 서버 URL
  
  MarkerService({required this.locationService})
      : _markerUIService = MarkerUIService();

  ValueNotifier<Set<Marker>> get markers => _markers;
  ValueNotifier<bool> get isMovingNotifier => _isMoving;
  bool get isMoving => _isMoving.value;
  ValueNotifier<Set<Circle>> get markerCircles => _markerCircles;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void onWheelClick(Offset offset) async {
    print('휠 클릭 감지: $offset');
    if (_mapController == null) {
      print('맵 컨트롤러가 초기화되지 않았습니다.');
      return;
    }

    try {
      final ScreenCoordinate screenCoordinate = ScreenCoordinate(
        x: offset.dx.round(),
        y: offset.dy.round(),
      );
      print('스크린 좌표 변환: $screenCoordinate');

      final LatLng position = await _mapController!.getLatLng(screenCoordinate);
      print('위치 좌표 변환: $position');
      
      await _createMarker(position);
    } catch (e) {
      print('마커 생성 중 오류 발생: $e');
    }
  }

  void onRightClick(Offset offset) async {
    if (_mapController == null) return;

    final ScreenCoordinate screenCoordinate = ScreenCoordinate(
      x: offset.dx.round(),
      y: offset.dy.round(),
    );

    final LatLng position = await _mapController!.getLatLng(screenCoordinate);
    _startMovement(position);
  }

  Future<void> _createMarker(LatLng position) async {
    print('마커 생성 시도: $position');
    try {
      final String? markerName = await _markerUIService.showMarkerNameDialog(
        context: navigatorKey.currentContext!
      );
      
      if (markerName == null || markerName.trim().isEmpty) {
        print('마커 생성 취소됨');
        return;
      }

      // 서버에 마커 데이터 저장
      final response = await http.post(
        Uri.parse('$apiUrl/markers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'position': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'title': markerName,
          'description': '', // 필요한 경우 설명 추가
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('마커 저장 실패: ${response.body}');
      }

      final markerData = jsonDecode(response.body);
      final markerId = MarkerId(markerData['_id']);
      
      BitmapDescriptor customMarkerIcon = await _markerUIService.createCustomMarkerIcon(markerName);

      final newMarker = Marker(
        markerId: markerId,
        position: position,
        icon: customMarkerIcon,
        onTap: () => _showMarkerInfo(markerId, markerName, position),
      );

      final newMarkers = {..._markers.value};
      newMarkers.add(newMarker);
      _markers.value = newMarkers;
      print('마커 생성 완료: $markerName');
      
    } catch (e) {
      print('마커 생성 실패: $e');
    }
  }

  void _showMarkerInfo(MarkerId markerId, String name, LatLng position) {
    _markerCircles.value = {
      Circle(
        circleId: CircleId('marker_circle_${markerId.value}'),
        center: position,
        radius: markerRadius,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue.withOpacity(0.5),
        strokeWidth: 2,
      ),
    };

    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '장소 이름',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteMarker(markerId);
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '위치: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      _markerCircles.value = {};
    });
  }

  void _deleteMarker(MarkerId markerId) async {
    final bool? shouldDelete = await _markerUIService.showDeleteConfirmDialog();
    if (shouldDelete == true) {
      try {
        final response = await http.delete(
          Uri.parse('$apiUrl/markers/${markerId.value}'),
        );

        if (response.statusCode != 200) {
          throw Exception('마커 삭제 실패: ${response.body}');
        }

        final newMarkers = Set<Marker>.from(_markers.value);
        newMarkers.removeWhere((marker) => marker.markerId == markerId);
        _markers.value = newMarkers;
      } catch (e) {
        print('마커 삭제 실패: $e');
      }
    }
  }

  void _startMovement(LatLng destination) {
    _movementTimer?.cancel();

    final startLat = locationService.center.value.latitude;
    final startLng = locationService.center.value.longitude;
    final endLat = destination.latitude;
    final endLng = destination.longitude;

    final distance = _calculateDistance(startLat, startLng, endLat, endLng);
    final duration = (distance / movementSpeed).round();

    var elapsedTime = 0;
    _isMoving.value = true;

    _movementTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (elapsedTime >= duration) {
        timer.cancel();
        locationService.updateCurrentLocation(destination);
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

  Future<void> loadSavedMarkers() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/markers'));
      
      if (response.statusCode != 200) {
        throw Exception('마커 로딩 실패: ${response.body}');
      }

      final List<dynamic> markersJson = jsonDecode(response.body);
      final newMarkers = <Marker>{};
      
      for (var markerData in markersJson) {
        final customMarkerIcon = await _markerUIService.createCustomMarkerIcon(markerData['title']);
        
        newMarkers.add(Marker(
          markerId: MarkerId(markerData['_id']),
          position: LatLng(
            markerData['position']['latitude'],
            markerData['position']['longitude'],
          ),
          icon: customMarkerIcon,
          onTap: () => _showMarkerInfo(
            MarkerId(markerData['_id']),
            markerData['title'],
            LatLng(
              markerData['position']['latitude'],
              markerData['position']['longitude'],
            ),
          ),
        ));
      }
      
      _markers.value = newMarkers;
    } catch (e) {
      print('마커 로딩 실패: $e');
    }
  }

  Future<void> createMarker(LatLng position, BuildContext context) async {
    print('마커 생성 시도: $position');
    try {
      final String? markerName = await _markerUIService.showMarkerNameDialog(
        context: context
      );
      
      if (markerName == null || markerName.trim().isEmpty) {
        print('마커 생성 취소됨');
        return;
      }

      // 서버에 마커 데이터 저장
      final response = await http.post(
        Uri.parse('$apiUrl/markers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'position': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'title': markerName,
          'description': '', // 필요한 경우 설명 추가
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('마커 저장 실패: ${response.body}');
      }

      final markerData = jsonDecode(response.body);
      final markerId = MarkerId(markerData['_id']);
      
      BitmapDescriptor customMarkerIcon = await _markerUIService.createCustomMarkerIcon(markerName);

      final newMarker = Marker(
        markerId: markerId,
        position: position,
        icon: customMarkerIcon,
        onTap: () => _showMarkerInfo(markerId, markerName, position),
      );

      final newMarkers = {..._markers.value};
      newMarkers.add(newMarker);
      _markers.value = newMarkers;
      print('마커 생성 완료: $markerName');
      
    } catch (e) {
      print('마커 생성 실패: $e');
    }
  }
}
