const Vehicle = require('../models/vehicle.model');

// 차량 등록
exports.registerVehicle = async (req, res) => {
  try {
    console.log('Received request body:', req.body);  // 요청 데이터 로깅
    console.log('Received file:', req.file);         // 파일 데이터 로깅

    const { vehicleNumber, model, capacity } = req.body;
    const imageUrl = req.file ? req.file.path : null;

    // 데이터 유효성 검사 추가
    if (!vehicleNumber || !model || !capacity) {
      return res.status(400).json({ 
        success: false, 
        error: '필수 필드가 누락되었습니다' 
      });
    }

    const vehicle = new Vehicle({
      vehicleNumber,
      model,
      capacity: parseInt(capacity),  // 문자열로 올 수 있으므로 숫자로 변환
      imageUrl,
      status: '대기중',  // status 값 한글로 변경
      currentLocation: {
        type: 'Point',
        coordinates: [0, 0]
      }
    });

    await vehicle.save();
    res.status(201).json({ success: true, data: vehicle });
  } catch (error) {
    console.error('Error in registerVehicle:', error);  // 에러 로깅
    res.status(400).json({ success: false, error: error.message });
  }
};

// 차량 목록 조회
exports.getVehicles = async (req, res) => {
  try {
    const vehicles = await Vehicle.find();
    res.json({ success: true, data: vehicles });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// 특정 차량 조회
exports.getVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findById(req.params.id);
    if (!vehicle) {
      return res.status(404).json({ success: false, error: '차량을 찾을 수 없습니다' });
    }
    res.json({ success: true, data: vehicle });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// 차량 정보 업데이트
exports.updateVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findByIdAndUpdate(
      req.params.id, 
      req.body,
      { new: true, runValidators: true }
    );
    if (!vehicle) {
      return res.status(404).json({ success: false, error: '차량을 찾을 수 없습니다' });
    }
    res.json({ success: true, data: vehicle });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

// 차량 삭제
exports.deleteVehicle = async (req, res) => {
  try {
    const { id } = req.params;
    await Vehicle.findByIdAndDelete(id);
    res.status(200).json({ message: '차량이 성공적으로 삭제되었습니다.' });
  } catch (error) {
    res.status(500).json({ message: '차량 삭제 중 오류가 발생했습니다.', error: error.message });
  }
};

// 차량 위치 업데이트
exports.updateLocation = async (req, res) => {
  try {
    const { longitude, latitude } = req.body;
    
    const vehicle = await Vehicle.findByIdAndUpdate(
      req.params.id,
      {
        currentLocation: {
          type: 'Point',
          coordinates: [longitude, latitude]
        }
      },
      { new: true }
    );

    if (!vehicle) {
      return res.status(404).json({ success: false, error: '차량을 찾을 수 없습니다' });
    }

    res.json({ success: true, data: vehicle });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

// 탑승객 추가
exports.addPassenger = async (req, res) => {
  try {
    const { passengerId } = req.body;
    
    const vehicle = await Vehicle.findById(req.params.id);
    if (!vehicle) {
      return res.status(404).json({ success: false, error: '차량을 찾을 수 없습니다' });
    }

    // 수용 인원 체크
    if (vehicle.currentPassengers.length >= vehicle.capacity) {
      return res.status(400).json({ success: false, error: '차량이 만석입니다' });
    }

    // 중복 탑승 체크
    if (vehicle.currentPassengers.includes(passengerId)) {
      return res.status(400).json({ success: false, error: '이미 탑승 중인 승객입니다' });
    }

    vehicle.currentPassengers.push(passengerId);
    await vehicle.save();

    res.json({ success: true, data: vehicle });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

// 탑승객 제거
exports.removePassenger = async (req, res) => {
  try {
    const { passengerId } = req.body;
    
    const vehicle = await Vehicle.findById(req.params.id);
    if (!vehicle) {
      return res.status(404).json({ success: false, error: '차량을 찾을 수 없습니다' });
    }

    const passengerIndex = vehicle.currentPassengers.indexOf(passengerId);
    if (passengerIndex === -1) {
      return res.status(400).json({ success: false, error: '해당 승객을 찾을 수 없습니다' });
    }

    vehicle.currentPassengers.splice(passengerIndex, 1);
    await vehicle.save();

    res.json({ success: true, data: vehicle });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

// 현재 탑승객 목록 조회
exports.getPassengers = async (req, res) => {
  try {
    const vehicle = await Vehicle.findById(req.params.id)
      .populate('currentPassengers', 'name studentId'); // 탑승객 정보 포함

    if (!vehicle) {
      return res.status(404).json({ success: false, error: '차량을 찾을 수 없습니다' });
    }

    res.json({ success: true, data: vehicle.currentPassengers });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}; 