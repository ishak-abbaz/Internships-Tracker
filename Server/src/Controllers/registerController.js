const User = require('../Models/userModel');
const bcrypt = require('bcryptjs');
const { generateVerificationToken, sendVerificationEmail } = require('../utils/sendEmail');

// Register Controller
exports.register = async (req, res) => {
  try {
    const { full_name, email, phone_number, password, user_role } = req.body;

    // 1. Validate required fields
    if (!full_name || !email || !phone_number || !password || !user_role) {
      return res.status(400).json({ msg: 'Please provide all required fields' });
    }

    // 2. Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ msg: 'Email already registered' });
    }

    // 3. Validate user_role (must be one of: Student, Mentor, Admin)
    const validRoles = ['Student', 'Mentor', 'Admin'];
    if (!validRoles.includes(user_role)) {
      return res.status(400).json({ msg: 'Invalid user role' });
    }

    // 4. Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // 5. Generate email verification token
    const emailToken = generateVerificationToken();
    const emailTokenExpiry = Date.now() + 24 * 60 * 60 * 1000; // 24 hours

    // 6. Create new user
    const newUser = new User({
      full_name,
      email,
      phone_number,
      password: hashedPassword,
      user_role,
      email_verification_token: emailToken,
      email_verification_expires: new Date(emailTokenExpiry),
      is_email_verified: false,
      account_status: user_role === 'Admin' ? 'approved' : 'pending'
    });

    // 7. Save user to database
    await newUser.save();

    // 8. Send verification email
    await sendVerificationEmail(email, full_name, emailToken);

    // 9. Return success response
    res.status(201).json({
      msg: 'Registration successful! Please verify your email to activate your account',
      user: {
        id: newUser._id,
        full_name: newUser.full_name,
        email: newUser.email,
        user_role: newUser.user_role,
        account_status: newUser.account_status
      }
    });

  } catch (err) {
    res.status(500).json({ msg: 'Registration failed', error: err.message });
  }
};
