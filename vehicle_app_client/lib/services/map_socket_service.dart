import 'dart:async';
import './socket_service.dart';

class MapSocketService {
  final _socketService = SocketService();
  final _locationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get locationStream => _locationController.stream;

  void init() {
    _socketService.socket.on('vehicle:location:update', (data) {
      _locationController.add(data);
    });

    _socketService.socket.on('marker:new', (data) {
      // 새로운 마커 처리
    });
  }

  void updateVehicleLocation(Map<String, dynamic> location) {
    _socketService.socket.emit('vehicle:location', location);
  }

  void dispose() {
    _locationController.close();
  }
}