const express = require('express');
const router = express.Router();
const { register } = require('../Controllers/registerController');

// Register route - new user signs up (email, password, name, phone, role)
router.post('/api/v1/auth/register', register);

module.exports = router;
