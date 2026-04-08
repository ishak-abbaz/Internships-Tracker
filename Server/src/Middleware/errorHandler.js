const logger = require('../Config/logger');

// Global error handling middleware
module.exports = (err, req, res, next) => {
  // Get status code from error (supports both err.status and err.statusCode)
  const statusCode = err.status || err.statusCode || 500;
  
  // Get error message
  const message = err.message || 'Internal server error';

  // Log the error with full details
  logger.error(`❌ [${statusCode}] ${req.method} ${req.originalUrl}:`, {
    message,
    stack: err.stack, // Where in code the error happened
    ip: req.ip,         // Client IP address
    user: req.user?._id || 'unauthenticated',
  });

  // Send consistent error response to client
  res.status(statusCode).json({
    msg: message,
    error: process.env.NODE_ENV === 'production' ? undefined : err.stack,
  });
};
