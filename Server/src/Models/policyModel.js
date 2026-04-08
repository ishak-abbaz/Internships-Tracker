const mongoose = require('mongoose');

const policySchema = new mongoose.Schema({
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
  target_role: {
    type: String,
    enum: ['All', 'Admin', 'Mentor', 'student'],
    default: 'All'
  },
  file_url: {
    type: String,
    required: true,
    trim: true
  },
  uploaded_by_admin_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
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

policySchema.index({ department_id: 1, is_active: 1 });
policySchema.index({ target_role: 1, is_active: 1 });

const Policy = mongoose.model('Policy', policySchema);

module.exports = Policy;
