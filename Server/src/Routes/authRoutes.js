const express = require('express');
const router = express.Router();
const { login,register } = require('../Controllers/AuthController');
const { protect, restrictTo } = require('../Middleware/auth');

// Login route - user enters email and password
router.post('/login', login);

router.post('/register', register);

module.exports = router;
