const mongoose = require('mongoose');

const evaluationSchema = new mongoose.Schema({
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
  week_label: {
    type: String,
    trim: true,
    maxlength: 50,
    default: null
  },
  overall_mark: {
    type: Number,
    required: true,
    min: 0,
    max: 100
  },
  feedback: {
    type: String,
    trim: true,
    maxlength: 2000,
    default: null
  },
  evaluated_at: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

evaluationSchema.index({ intern_id: 1, evaluated_at: -1 });
evaluationSchema.index({ mentor_id: 1, evaluated_at: -1 });

const Evaluation = mongoose.model('Evaluation', evaluationSchema);

module.exports = Evaluation;
