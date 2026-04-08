
const User = require('../Models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const secretKey = process.env.JWT_SECRET;
const { generateVerificationToken, sendVerificationEmail } = require('../utils/sendEmail'); // STEP 2: Import email utilities
const { sendPasswordResetEmail } = require('../utils/sendEmail');





// Login Controller

exports.login = async (req, res) => {
  try {

    const { email, password } = req.body;

 // 1. Check user
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ msg: 'Invalid email' });

// 2. Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ msg: 'Invalid password' });


// 3. Check Email_verification
    if (!user.is_email_verified) return res.status(403).json({ msg: 'Please verify your email first' });
    
// 4. Generate JWT
    const token = jwt.sign(
      {
        id: user._id,
        role: user.user_role
      },
      secretKey,
      { expiresIn: '1d' }
    );

    //  5. Set cookie 
    res.cookie('jwt', token, {
      httpOnly: true,       // Prevent JavaScript access (XSS protection)
      secure: false,         // Only send cookie over HTTPS
      sameSite: 'Lax',       // Block cross-site sending (CSRF protection)
      maxAge: 24 * 60 * 60 * 1000 // 1 day
    });

    // this will Send the JWT token securely as a cookie to the client (Postman or browser).
    // So Postman/browser will automatically save it


    // . Return response
    res.status(200).json({
      msg: 'Login successful',
      token,
      user: {
        id: user._id,
        full_name: user.full_name,
        email: user.email,
        user_role: user.user_role
      }
    });

  } catch (err) {
    res.status(500).json({ msg: 'Login failed', error: err.message });
  }
};



// STEP 5: Email Verification controller of the email verification route:

// Verifies the user’s email using a token (usually from a link they clicked in their inbox).

exports.verifyEmail = async (req, res) => {
  try {
    const { token } = req.query;   // /verify-email?token=abc123

    if (!token) {
      return res.status(400).json({ msg: 'Verification token is required' });
    }

    // Find user with matching token that hasn't expired
    const user = await User.findOne({
      email_verification_token: token,
      email_verification_expires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ msg: 'Invalid or expired verification token' });
    }

    // Update user verification status
    user.is_email_verified = true;
    user.email_verification_token = undefined;
    user.email_verification_expires = undefined;
    await user.save(); // save changes

    res.status(200).json({ msg: 'Email verified successfully! You can now login.' });

  } catch (err) {
    res.status(500).json({ msg: 'Email verification failed', error: err.message });
  }
};




// STEP 6: Resend Verification Email Controller of the Resend email verification route:

// Resends a new verification email if the user hasn’t verified their account yet.




exports.resendVerificationEmail = async (req, res) => {
  try {
    const { email } = req.body; // Extracts the email from the request body — user input from a form or frontend

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    // Check if already verified
    if (user.is_email_verified) {
      return res.status(400).json({ msg: 'Email is already verified' });
    }

    // Generate new verification token
    const emailToken = generateVerificationToken();
    const emailTokenExpiry = Date.now() + 24 * 60 * 60 * 1000; // 24h

    // Update user with new token
    user.email_verification_token = emailToken;
    user.email_verification_expires = new Date(emailTokenExpiry);
    await user.save();

    // Send verification email
    await sendVerificationEmail(email, user.full_name, emailToken);

    res.status(200).json({ msg: 'Verification email resent successfully' });

  } catch (err) {
    res.status(500).json({ msg: 'Failed to resend verification email', error: err.message });
  }
};





exports.forgotPassword = async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ msg: 'User not found' });

  const token = crypto.randomBytes(32).toString('hex');
  user.reset_Password_Token = token;
  user.reset_Password_expires_at = Date.now() + 3600000;
  await user.save();

  const resetURL = `${process.env.BASE_URL}/reset-password/${token}`;
  await sendPasswordResetEmail(email, 'Reset your password', `Reset Link: ${resetURL}`);

  res.json({ msg: 'Reset link sent to email', token });
};


exports.resetPassword = async (req, res) => {
  const { token } = req.params;    // resetPassword/abc123(Token) INSTEAD OF verify-email?token=abc123
  const { newPassword } = req.body;

  const user = await User.findOne({
    reset_Password_Token: token,
    reset_Password_expires_at: { $gt: Date.now() }
  });

  if (!user) return res.status(400).json({ msg: 'Invalid or expired token' });



  user.password = await bcrypt.hash(newPassword, 12);
  user.reset_Password_Token = undefined;
  user.reset_Password_expires_at = undefined;
  await user.save();

  res.json({ msg: 'Password has been reset successfully' });
};
