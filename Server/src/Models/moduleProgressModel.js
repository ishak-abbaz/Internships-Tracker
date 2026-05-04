const mongoose = require('mongoose');

const moduleProgressSchema = new mongoose.Schema({
  intern_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  module_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'TrainingModule',
    required: true
  },
  status: {
    type: String,
    enum: ['In Progress', 'Completed'],
    default: 'Completed'
  },
  completed_at: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// One progress record per intern per module
moduleProgressSchema.index({ intern_id: 1, module_id: 1 }, { unique: true });

const ModuleProgress = mongoose.model('ModuleProgress', moduleProgressSchema);

module.exports = ModuleProgress;
