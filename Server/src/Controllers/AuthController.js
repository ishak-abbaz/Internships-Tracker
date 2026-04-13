const User = require('../Models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET;
// Register Controller
exports.register = async (req, res) => {
  try {
    const { full_name, email, password, passwordConfirm } = req.body;
// 1. Validate inputs first
if (!email.includes("@"))
  return res.status(400).json({ msg: "Invalid email" });
if (password.length < 6)
  return res.status(400).json({ msg: "Password too short" });
if (password !== passwordConfirm)
  return res.status(400).json({ msg: "Passwords do not match" });

// 2. Then check database
const existingUser = await User.findOne({ email });
if (existingUser)
  return res.status(400).json({ msg: "Email already exists" });

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
    res.status(201).json({
      msg: "User created successfully.",
      user: {
        id: user._id,
        full_name: user.full_name,
        email: user.email,
      },
    });
  } catch (err) {
    res.status(500).json({ msg: "Signup failed", error: err.message });
  }
};



// Login Controller

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. Check user
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ msg: "Invalid email" });

    // 2. Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ msg: "Invalid password" });

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
    res.status(200).json({
      msg: "Login successful",
      accessToken: token,
      user: {
        id: user._id,
        full_name: user.full_name,
        email: user.email,
        user_role: user.user_role,
      },
    });
  } catch (err) {
    res.status(500).json({ msg: "Login failed", error: err.message });
  }
};
