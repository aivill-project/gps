const express = require('express');
const router = express.Router();
const markerController = require('../controllers/marker.controller');

// 마커 라우트
router.post('/markers', markerController.createMarker);
router.get('/markers', markerController.getAllMarkers);
router.get('/markers/:id', markerController.getMarkerById);
router.put('/markers/:id', markerController.updateMarker);
router.delete('/markers/:id', markerController.deleteMarker);

module.exports = router; 