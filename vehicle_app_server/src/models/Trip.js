const mongoose = require('mongoose');

const TripSchema = new mongoose.Schema({
  vehicle: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicle',
    required: true
  },
  startTime: {
    type: Date,
    required: true
  },
  endTime: {
    type: Date
  },
  route: [{
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true
    },
    timestamp: {
      type: Date,
      required: true
    }
  }],
  passengers: [{
    student: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Student'
    },
    boardingTime: Date,
    alightingTime: Date
  }],
  status: {
    type: String,
    enum: ['진행중', '완료'],
    default: '진행중'
  }
}, {
  timestamps: true
});

TripSchema.index({ 'route.coordinates': '2dsphere' });

module.exports = mongoose.model('Trip', TripSchema); 