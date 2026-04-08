const mongoose = require('mongoose');

const scheduleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 255
  },
  department_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Department',
    default: null
  },
  intern_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  mentor_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  weekday: {
    type: String,
    enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    default: null
  },
  schedule_date: {
    type: Date,
    default: null
  },
  start_time: {
    type: String,
    required: true,
    trim: true
  },
  end_time: {
    type: String,
    required: true,
    trim: true
  },

  notes: {
    type: String,
    trim: true,
    maxlength: 1000,
    default: null
  },
  uploaded_by_admin_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  is_active: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

scheduleSchema.index({ department_id: 1, schedule_date: 1 });
scheduleSchema.index({ intern_id: 1, schedule_date: 1 });
scheduleSchema.index({ mentor_id: 1, schedule_date: 1 });

const Schedule = mongoose.model('Schedule', scheduleSchema);

module.exports = Schedule;
