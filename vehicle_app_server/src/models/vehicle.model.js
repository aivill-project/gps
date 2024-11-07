const mongoose = require('mongoose');

const VehicleSchema = new mongoose.Schema({
  vehicleNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  model: {
    type: String,
    required: true,
    trim: true
  },
  capacity: {
    type: Number,
    required: true,
    min: 1
  },
  imageUrl: {
    type: String,
    required: false
  },
  status: {
    type: String,
    enum: ['운행중', '운행종료', '대기중'],
    default: '대기중'
  },
  currentLocation: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      default: [0, 0]
    }
  },
  currentPassengers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Student'
  }]
}, {
  timestamps: true
});

VehicleSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Vehicle', VehicleSchema); 