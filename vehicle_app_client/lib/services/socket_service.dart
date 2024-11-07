import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  void initSocket() {
    socket = IO.io('http://localhost:3000', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build()
    );
    
    socket.connect();
    
    socket.onConnect((_) => print('Socket 연결됨'));
    socket.onDisconnect((_) => print('Socket 연결 해제'));
    socket.onError((err) => print('Socket 에러: $err'));
  }
}