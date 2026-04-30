const jwt = require('jsonwebtoken');
const User = require('../Models/userModel');
const { sendError } = require('../utils/response');

const secretKey = process.env.JWT_SECRET;


//  Protect middleware — for authenticated users only  // reads JWT from cookies

exports.protect = async (req, res, next) => {
  try {
    // Get token from Authorization header (for mobile apps like Flutter)
    // Format: Authorization: Bearer <token>
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return sendError(res, { status: 401, msg: 'Access denied. No token provided.' });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET); // or your secretKey

    // Find user
    const user = await User.findById(decoded.id).select('-password');
    if (!user) return sendError(res, { status: 401, msg: 'User not found' });

    req.user = user;
    next();

  } catch (err) {
    return sendError(res, {
      status: 401,
      msg: 'Invalid or expired token',
      data: { error: err.message }
    });
  }
};


exports.restrictTo = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.user_role)) {
      return sendError(res, { status: 403, msg: 'Access denied. Insufficient role.' });
    }
    next();
  };
};

