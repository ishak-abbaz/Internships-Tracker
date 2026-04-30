const User = require('../Models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET;
const { sendSuccess, sendError } = require('../utils/response');
// Register Controller
exports.register = async (req, res) => {
  try {
    const { full_name, email, password, passwordConfirm } = req.body;
// 1. Validate inputs first
if (!email.includes("@"))
  return sendError(res, { status: 400, msg: 'Invalid email' });
if (password.length < 6)
  return sendError(res, { status: 400, msg: 'Password too short' });
if (password !== passwordConfirm)
  return sendError(res, { status: 400, msg: 'Passwords do not match' });

// 2. Then check database
const existingUser = await User.findOne({ email });
if (existingUser)
  return sendError(res, { status: 400, msg: 'Email already exists' });

    // 3. Hash password
    const hashedPassword = await bcrypt.hash(password, 12); // 12 is for strength

    // 4. Create user
    const user = await User.create({
      // .create =  new User(...) → creates a document instance && .save() → saves it to the database
      full_name,
      email,
      password: hashedPassword,
      is_email_verified: true, // Set to true since no verification needed
    });

    // 5. Return success
    return sendSuccess(res, {
      status: 201,
      msg: 'User created successfully.',
      data: {
        user: {
          id: user._id,
          full_name: user.full_name,
          email: user.email,
        },
      },
    });
  } catch (err) {
    return sendError(res, {
      status: 500,
      msg: 'Signup failed',
      data: { error: err.message }
    });
  }
};



// Login Controller

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. Check user
    const user = await User.findOne({ email });
    if (!user) return sendError(res, { status: 400, msg: 'Invalid email' });

    // 2. Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return sendError(res, { status: 400, msg: 'Invalid password' });

    // 3. Generate JWT
    const token = jwt.sign(
      {
        id: user._id,
        role: user.user_role,
      },
      secretKey,
      { expiresIn: "1d" }
    );

    // 4. Return response with token (for mobile apps like Flutter)
    return sendSuccess(res, {
      status: 200,
      msg: 'Login successful',
      data: {
        accessToken: token,
        user: {
          id: user._id,
          full_name: user.full_name,
          email: user.email,
          user_role: user.user_role,
        },
      },
    });
  } catch (err) {
    return sendError(res, {
      status: 500,
      msg: 'Login failed',
      data: { error: err.message }
    });
  }
};
