const socketIO = require('socket.io');

class MapSocket {
  constructor(io) {
    this.io = io;
    this.setupSocketHandlers();
  }

  setupSocketHandlers() {
    this.io.on('connection', (socket) => {
      console.log('Client connected to map socket');

      // 차량 위치 업데이트 수신 및 브로드캐스트
      socket.on('vehicle:location', (data) => {
        this.io.emit('vehicle:location:update', data);
      });

      // 새로운 마커 생성
      socket.on('marker:create', (markerData) => {
        this.io.emit('marker:new', markerData);
      });

      socket.on('disconnect', () => {
        console.log('Client disconnected from map socket');
      });
    });
  }
}

module.exports = MapSocket;