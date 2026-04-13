const mongoose = require('mongoose');

const internAssignmentSchema = new mongoose.Schema({
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
  department_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Department',
    required: true
  },
  assigned_by_admin_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  subject: {
    type: String,
    required: true,
    trim: true,
    maxlength: 255
  },
  status: {
    type: String,
    enum: ['pending', 'active', 'completed'],
    default: 'pending'
  },
  start_date: {
    type: Date,
    default: Date.now
  },
  end_date: {
    type: Date,
    default: null
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

internAssignmentSchema.index({ intern_id: 1, status: 1 });
internAssignmentSchema.index({ mentor_id: 1, status: 1 });
internAssignmentSchema.index({ department_id: 1, status: 1 });

const InternAssignment = mongoose.model('InternAssignment', internAssignmentSchema);

module.exports = InternAssignment;
