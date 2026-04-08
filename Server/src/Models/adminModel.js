const mongoose = require('mongoose');
const User = require('./userModel');

const adminSchema = new mongoose.Schema({
  organization_name: {
    type: String,
    trim: true,
    maxlength: 255,
    default: null
  },
  admin_scope: {
    type: String,
    enum: ['hr', 'university'],
    default: 'hr'
  }
});

adminSchema.index({ admin_scope: 1 });

const Admin = User.discriminator('Admin', adminSchema);

module.exports = Admin;
