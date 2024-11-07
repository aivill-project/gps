import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/vehicle_list_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/map_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 전역 Socket 변수
late io.Socket socket;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  connectToServer(); // 앱 실행 시 소켓 연결 초기화
  runApp(const VehicleTrackingApp());
}

// 소켓 연결 초기화 함수
void connectToServer() {
  socket = io.io('http://localhost:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });

  socket.onConnect((_) {
    print('소켓 서버에 연결되었습니다.');
  });

  // 필요한 이벤트 추가 설정 가능
  socket.on('locationUpdated', (data) {
    // 예를 들어, 수신한 데이터에 대해 처리하는 로직 추가
    print('위치 업데이트: $data');
  });
}

class VehicleTrackingApp extends StatelessWidget {
  const VehicleTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '태권월드',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MainScreen(),
    const MapScreen(),
    const VehicleListScreen(),
    const SettingsScreen(),
  ];

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text(
          '태권월드',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // 알림 화면으로 이동
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },  
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.gps_fixed),
            label: '위치 추적',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus),
            label: '차량 관리',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
