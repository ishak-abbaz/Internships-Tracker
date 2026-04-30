
const { sendError } = require('../utils/response');

// Global error handling middleware
module.exports = (err, req, res, next) => {
  console.error(' Error:', err);
  return sendError(res, {
    status: 500,
    msg: 'Internal server error',
    data: { error: err.message }
  });
};
