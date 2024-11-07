const mongoose = require('mongoose');

const StudentSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  studentId: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  grade: {
    type: Number,
    required: true
  },
  currentVehicle: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicle',
    default: null
  },
  boardingStatus: {
    type: String,
    enum: ['승차', '하차'],
    default: '하차'
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Student', StudentSchema); 