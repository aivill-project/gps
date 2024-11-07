const express = require('express');
const connectDB = require('./src/config/database');
const app = express();
const http = require('http').createServer(app);
const cors = require('cors');
const io = require('socket.io')(http, {
  cors: {
    origin: "*",  // Flutter 클라이언트 주소로 수정
    methods: ["GET", "POST", "DELETE", "PUT"]
  }
});

const vehicleRoutes = require('./src/routes/vehicle.routes');
const studentRoutes = require('./src/routes/student.routes');

connectDB();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/vehicles', vehicleRoutes);
app.use('/api/students', studentRoutes);
// Socket.IO 연결 처리
io.on('connection', (socket) => {
  console.log('클라이언트가 연결되었습니다.');

  socket.on('updateVehicleLocation', (data) => {
    console.log('차량 위치 업데이트 수신:', {
      vehicleId: data.vehicleId,
      latitude: data.location.latitude,
      longitude: data.location.longitude,
      students: data.students
      });
  });
  // 위치 업데이트 수신 및 브로드캐스트
  socket.on('updateLocation', (location) => {
    // 받은 위치 데이터를 다른 모든 클라이언트에게 전송
    socket.broadcast.emit('locationUpdated', location);
  });

  socket.on('disconnect', () => {
    console.log('클라이언트가 연결을 해제했습니다.');
  });
});

const PORT = process.env.PORT || 3000;
http.listen(PORT, () => {
  console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
});