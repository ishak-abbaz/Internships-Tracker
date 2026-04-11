const mongoose = require('mongoose');
const User = require('./userModel');

const internSchema = new mongoose.Schema({
  university_id: {
    type: String,
    trim: true,
    maxlength: 100,
    default: null
  },
  department_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Department',
    default: null
  },
  mentor_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  is_validated_by_admin: {
    type: Boolean,
    default: false
  },
  work_id: {
    type: Number,
    trim: true,
    unique: true,
    sparse: true,
    default: null
  },
  id_photo_url: {
    type: String,
    trim: true,
    default: '/uploads/default-intern-photo.png'
  }
});

internSchema.index({ mentor_id: 1 });
internSchema.index({ department_id: 1 });

const Intern = User.discriminator('Intern', internSchema, 'Student');

module.exports = Intern;
