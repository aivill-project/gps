import 'package:flutter/material.dart';
import '../services/location/location_service.dart';
import '../services/marker/marker_service.dart';
import '../widgets/map_widget.dart';
import '../widgets/student_list_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/vehicle.dart';
import '../services/parent_communication_service.dart';
import '../widgets/delay_notification_dialog.dart';

class DrivingMapScreen extends StatefulWidget {
  final Vehicle vehicle;
  final List<Map<String, dynamic>> initialStudents;

  const DrivingMapScreen({
    super.key,
    required this.vehicle,
    required this.initialStudents,
  });

  @override
  State<DrivingMapScreen> createState() => _DrivingMapScreenState();
}

class _DrivingMapScreenState extends State<DrivingMapScreen> {
  final LocationService _locationService = LocationService();
  late final MarkerService _markerService;
  io.Socket? socket;
  List<Map<String, dynamic>> students = [];
  final String serverUrl = 'http://localhost:3000';
  bool _isMapInitialized = false;
  late final ParentCommunicationService _parentCommunicationService;

  @override
  void initState() {
    super.initState();
    students = List.from(widget.initialStudents);
    _markerService = MarkerService(locationService: _locationService);
    _initializeSocket();
    _parentCommunicationService = ParentCommunicationService(socket: socket!);
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _locationService.requestLocationPermission();
    if (mounted) {
      setState(() {
        _isMapInitialized = true;
      });
    }
    _startLocationTracking();
    _showStartDrivingMessage();
  }

  void _initializeSocket() {
    socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();

    socket!.onConnect((_) {
      print('운행 소켓 연결됨');
    });
  }

  void _startLocationTracking() async {
    print('운행 시작 - 차량: ${widget.vehicle.id}, 학생들: $students');
    
    await _locationService.startLocationUpdates();
    
    _locationService.locationStream.listen(
      (position) {
        print('새로운 위치 수신: ${position.latitude}, ${position.longitude}');
        socket?.emit('updateVehicleLocation', {
          'vehicleId': widget.vehicle.id,
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'students': students,
        });
      },
      onError: (error) => print('위치 스트림 에러: $error'),
    );
  }

  void _showStartDrivingMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('운행을 시작합니다')),
      );
    });
  }

  void _showDelayNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => DelayNotificationDialog(
        onSubmit: (minutes, reason) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          // 모든 학부모에게 지연 알림 전송
          for (final student in students) {
            await _parentCommunicationService.sendDelayNotification(
              student['parentId'],
              minutes,
              reason,
            );
          }
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('지연 알림이 전송되었습니다')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('운행 중'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_important),
            onPressed: () => _showDelayNotificationDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _locationService.isPermissionGranted
                ? _locationService.getCurrentLocation
                : _locationService.requestLocationPermission,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isMapInitialized)
            MapWidget(
              locationService: _locationService,
              markerService: _markerService,
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_isMapInitialized)
            Positioned(
              top: 16,
              right: 16,
              child: StudentListWidget(
                students: students,
                onDropOff: (student) {
                  setState(() {
                    students = List.from(students)..removeWhere((s) => s['id'] == student['id']);
                  });
                },
                parentCommunicationService: _parentCommunicationService,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('운행 종료 - 차량: ${widget.vehicle.id}');
    _locationService.dispose();
    if (socket?.connected == true) {
      socket?.disconnect();
    }
    _markerService.dispose();
    super.dispose();
  }
} 