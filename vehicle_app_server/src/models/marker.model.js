const mongoose = require('mongoose');

const markerSchema = new mongoose.Schema({
  position: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true }
  },
  title: { type: String, default: '새 마커' },
  description: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Marker', markerSchema);