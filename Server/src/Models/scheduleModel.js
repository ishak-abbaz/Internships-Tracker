const mongoose = require('mongoose');

const scheduleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 255
  },
  description: {
    type: String,
    trim: true,
    maxlength: 2000,
    default: null
  },
  department_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Department',
    default: null
  },
  department_code: {
    type: String,
    trim: true,
    maxlength: 20,
    default: null
  },
  academic_year: {
    type: String,
    trim: true,
    default: null
  },
  group: {
    type: String,
    trim: true,
    default: null
  },
  teacher_name: {
    type: String,
    trim: true,
    default: null
  },
  module_name: {
    type: String,
    trim: true,
    default: null
  },
  file_url: {
    type: String,
    required: true,
    trim: true
  },
  file_public_id: {
    type: String,
    default: null,
    trim: true
  },
  uploaded_by_admin_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    default: null
  },
  version: {
    type: Number,
    default: 1,
    min: 1
  },
  is_active: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

scheduleSchema.index({ department_id: 1, is_active: 1 });

const Schedule = mongoose.model('Schedule', scheduleSchema);

module.exports = Schedule;
