const mongoose = require('mongoose');

const policySchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 255,
    },
    description: {
      type: String,
      trim: true,
      maxlength: 2000,
      default: null,
    },
    department_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Department',
      default: null,
    },
    department_code: {
      type: String,
      trim: true,
      default: null,
    },
    target_role: {
      type: String,
      enum: ['All', 'Admin', 'Mentor', 'Student'],
      default: 'All',
    },
    file_url: { type: String, required: true, trim: true },
    file_public_id: { type: String, trim: true, default: null },
    version: { type: Number, default: 1, min: 1 },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } }
);

module.exports = mongoose.model('Policy', policySchema);
