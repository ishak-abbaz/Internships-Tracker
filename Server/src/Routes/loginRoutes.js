const express = require('express');
const router = express.Router();
const { login, verifyEmail, resendVerificationEmail, forgotPassword, resetPassword } = require('../Controllers/loginController');

// Login route - user enters email and password
router.post('/api/v1/auth/login', login);

// Verify email - user clicks link from email with token
router.get('/api/v1/auth/verify-email', verifyEmail);

// Resend verification email - if user didn't receive the first email
router.post('/api/v1/auth/resend-verification', resendVerificationEmail);

// Forgot password - user requests password reset link
router.post('/api/v1/auth/forgot-password', forgotPassword);

// Reset password - user submits new password with reset token
router.post('/api/v1/auth/reset-password/:token', resetPassword);

module.exports = router;