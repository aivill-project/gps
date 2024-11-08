import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ParentCommunicationService {
  final io.Socket socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  ParentCommunicationService({required this.socket}) {
    _initializeSocketListeners();
  }

  void _initializeSocketListeners() {
    socket.on('student:pickup', (data) {
      _sendAutomaticMessage(
        '${data['studentName']}님이 승차했습니다.',
        data['parentId'],
      );
    });

    socket.on('student:dropoff', (data) {
      _sendAutomaticMessage(
        '${data['studentName']}님이 하차했습니다.',
        data['parentId'],
      );
    });
  }

  Future<void> _sendAutomaticMessage(String message, String parentId) async {
    socket.emit('message:send', {
      'parentId': parentId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendDelayNotification(String parentId, int delayMinutes, String reason) async {
    final message = '운행이 약 $delayMinutes분 지연될 예정입니다.\n사유: $reason';
    await _sendAutomaticMessage(message, parentId);
  }

  Future<String> getEstimatedArrivalTime(LatLng currentLocation, LatLng destination) async {
    // 여기에 도착 예정 시간 계산 로직 구현
    return '15분';
  }

  Future<void> sendDropOffNotification(String parentId, String studentName) async {
    // TODO: 실제 알림 전송 로직 구현
    await Future.delayed(const Duration(seconds: 1)); // 임시 지연
  }

  void dispose() {
    _messageController.close();
  }
}