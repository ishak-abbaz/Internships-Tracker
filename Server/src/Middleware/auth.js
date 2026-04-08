const jwt = require('jsonwebtoken');
const User = require('../Models/userModel');

const secretKey = process.env.JWT_SECRET;


//  Protect middleware — for authenticated users only  // reads JWT from cookies

exports.protect = async (req, res, next) => {
  try {
    const token = req.cookies.jwt; //  Get token from cookie

    if (!token) {
      return res.status(401).json({ msg: 'Access denied. No token provided.' });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET); // or your secretKey

    // Find user
    const user = await User.findById(decoded.id).select('-password');
    if (!user) return res.status(401).json({ msg: 'User not found' });

    req.user = user;
    next();

  } catch (err) {
    res.status(401).json({ msg: 'Invalid or expired token', error: err.message });
  }
};





exports.restrictTo = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.user_role)) {
      return res.status(403).json({ msg: 'Access denied. Insufficient role.' });
    }
    next();
  };
};


// those function i use them like this :

// router.get('/dashboard', protect, restrictTo('student', 'Parent'), dashboardController.view);

