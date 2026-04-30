const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  intern_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  mentor_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  attendance_date: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['present', 'absent', 'late', 'excused'],
    default: 'present'
  },
  notes: {
    type: String,
    trim: true,
    maxlength: 1000,
    default: null
  },
  marked_by_mentor_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

attendanceSchema.index({ intern_id: 1, attendance_date: 1 }, { unique: true });
attendanceSchema.index({ mentor_id: 1, attendance_date: 1 });

const Attendance = mongoose.model('Attendance', attendanceSchema);

module.exports = Attendance;
