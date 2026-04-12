const express = require('express');
const router = express.Router();
const { login, verifyEmail, resendVerificationEmail, forgotPassword, resetPassword, register } = require('../Controllers/authController');

// Login route - user enters email and password
router.post('/login', login);

// Verify email - user clicks link from email with token
router.get('/verify-email', verifyEmail);

// Resend verification email - if user didn't receive the first email
router.post('/resend-verification', resendVerificationEmail);

// Forgot password - user requests password reset link
router.post('/forgot-password', forgotPassword);

// Reset password - user submits new password with reset token
router.post('/reset-password/:token', resetPassword);

// Register route - new user signs up (email, password, name, phone, role)
router.post('/register', register);

module.exports = router;
