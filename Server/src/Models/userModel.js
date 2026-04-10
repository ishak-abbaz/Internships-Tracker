
const mongoose = require('mongoose');


// Users Schema

const user = new mongoose.Schema({
   // we use mongo db Default id
  full_name: {
    type: String,
    required: true,
    trim: true, // automatically removes spaces 
    maxlength: 255
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    maxlength: 255
  },
  user_role: {
    type: String,
    enum: ['Student', 'Admin', 'Mentor'],
    default: 'Student',
    required: true, // NOT NULL
  },
  account_status: {
    type: String,
    enum: ['pending', 'approved', 'declined'],
    default: function defaultAccountStatus() {
      return this.user_role === 'Admin' ? 'approved' : 'pending';
    },
    required: true
  },
  account_reviewed_at: {
    type: Date,
    default: null
  },
  account_reviewed_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' },
  discriminatorKey: 'user_role'
});

// Indexes for query optimization
user.index({ user_role: 1 }); // Index for role-based queries
user.index({ account_status: 1 }); // Index for registration approval workflow
user.index({ is_email_verified: 1 }); // Index for filtering verified users
user.index({ google_id: 1 }); // Index for Google OAuth lookups
user.index({ email_verification_token: 1 }); // Index for token verification
user.index({ reset_Password_Token: 1 }); // Index for password reset

// Create Model
const User = mongoose.model('User', user);


// Export model
module.exports = User;