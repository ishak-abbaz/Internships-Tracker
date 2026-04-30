const mongoose = require('mongoose');
const User = require('./userModel');

const mentorSchema = new mongoose.Schema({
  department_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Department',
    default: null
  },
  specialization: {
    type: String,
    trim: true,
    maxlength: 255,
    default: null
  },
});

mentorSchema.index({ department_id: 1 });

const Mentor = User.discriminator('Mentor', mentorSchema, 'Mentor');

module.exports = Mentor;
