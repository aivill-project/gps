const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect('mongodb://localhost:27017/vehicle_db', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`MongoDB 연결 성공: ${conn.connection.host}`);

    // 연결 이벤트 리스너
    mongoose.connection.on('connected', () => {
      console.log('Mongoose가 MongoDB에 연결됨');
    });

    mongoose.connection.on('error', (err) => {
      console.error('Mongoose 연결 에러:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('Mongoose 연결이 끊어짐');
    });

  } catch (error) {
    console.error('MongoDB 연결 실패:', error);
    process.exit(1);
  }
};

module.exports = connectDB;