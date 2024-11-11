const Marker = require('../models/marker.model');

// 마커 컨트롤러
class MarkerController {
  // 마커 생성
  async createMarker(req, res) {
    try {
      const marker = new Marker(req.body);
      await marker.save();
      res.status(201).json(marker);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  }

  // 모든 마커 조회
  async getAllMarkers(req, res) {
    try {
      const markers = await Marker.find();
      res.json(markers);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  // 특정 마커 조회
  async getMarkerById(req, res) {
    try {
      const marker = await Marker.findById(req.params.id);
      if (!marker) {
        return res.status(404).json({ message: '마커를 찾을 수 없습니다.' });
      }
      res.json(marker);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  // 마커 수정
  async updateMarker(req, res) {
    try {
      const marker = await Marker.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true }
      );
      if (!marker) {
        return res.status(404).json({ message: '마커를 찾을 수 없습니다.' });
      }
      res.json(marker);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  }

  // 마커 삭제
  async deleteMarker(req, res) {
    try {
      const marker = await Marker.findByIdAndDelete(req.params.id);
      if (!marker) {
        return res.status(404).json({ message: '마커를 찾을 수 없습니다.' });
      }
      res.json({ message: '마커가 삭제되었습니다.' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
}

module.exports = new MarkerController();
