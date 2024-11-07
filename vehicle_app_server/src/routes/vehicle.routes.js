const express = require('express');
const router = express.Router();
const multer = require('multer');
const vehicleController = require('../controllers/vehicle.controller');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');  // 업로드 폴더 지정
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + '.' + file.originalname.split('.').pop());
  }
});

const upload = multer({ storage: storage });

// 차량 등록 라우트에 multer 미들웨어 추가
router.post('/', upload.single('vehicleImage'), vehicleController.registerVehicle);
router.get('/', vehicleController.getVehicles);
router.delete('/:id', vehicleController.deleteVehicle);

// ... 다른 라우트들 ...

module.exports = router; 