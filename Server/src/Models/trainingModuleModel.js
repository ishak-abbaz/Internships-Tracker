const mongoose = require('mongoose');

const trainingModuleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  description: {
    type: String,
    required: true,
    trim: true,
    maxlength: 1000
  },
  url: {
    type: String,
    required: true,
    trim: true
  },
  department_code: {
    type: String,
    required: true,
    trim: true,
    uppercase: true,
    maxlength: 20
  },
  created_by_mentor_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  is_active: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Composite index for unique module per department
trainingModuleSchema.index({ title: 1, department_code: 1 }, { unique: true });
trainingModuleSchema.index({ department_code: 1 });
trainingModuleSchema.index({ created_by_mentor_id: 1 });

const TrainingModule = mongoose.model('TrainingModule', trainingModuleSchema);

module.exports = TrainingModule;
