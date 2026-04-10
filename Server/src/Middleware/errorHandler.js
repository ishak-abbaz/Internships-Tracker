
const jwt = require('jsonwebtoken');
const User = require('../Models/userModel');

// Global error handling middleware
module.exports = (err, req, res, next) => {
  console.error(' Error:', err);
  res.status(500).json({
    msg: 'Internal server error',
    error: err.message
  });
};
