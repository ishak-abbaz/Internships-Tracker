const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const User = require('../Models/userModel');
const { generateVerificationToken, sendVerificationEmail } = require('../utils/sendEmail');

const VALID_ROLES = ['Student', 'Mentor', 'Admin'];

const buildError = (message, status = 500) => {
  const err = new Error(message);
  err.status = status;
  return err;
};

const sanitizeUser = (user) => ({
  id: user._id,
  full_name: user.full_name,
  email: user.email,
  phone_number: user.phone_number,
  user_role: user.user_role,
  account_status: user.account_status,
  is_email_verified: user.is_email_verified,
  created_at: user.created_at,
  updated_at: user.updated_at
});
// Method used to sanitize data got from user
const validateObjectId = (id, entityName = 'User') => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw buildError(`Invalid ${entityName} ID`, 400);
  }
};

const createUser = async ({ full_name, email, password, phone_number, user_role = 'Student' }) => {
  if (!full_name || !email || !password || !phone_number || !user_role) {
    throw buildError('Please provide all required fields', 400);
  }

  if (!VALID_ROLES.includes(user_role)) {
    throw buildError('Invalid user role', 400);
  }

  const existingUser = await User.findOne({ email: email.toLowerCase().trim() });
  if (existingUser) {
    throw buildError('Email already registered', 409);
  }

  const hashedPassword = await bcrypt.hash(password, 12);
  const emailToken = generateVerificationToken();
  const emailTokenExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

  const newUser = new User({
    full_name: full_name.trim(),
    email: email.toLowerCase().trim(),
    phone_number,
    password: hashedPassword,
    user_role,
    email_verification_token: emailToken,
    email_verification_expires: emailTokenExpiry,
    is_email_verified: false,
    account_status: user_role === 'Admin' ? 'approved' : 'pending'
  });

  await newUser.save();
  await sendVerificationEmail(newUser.email, newUser.full_name, emailToken);

  return sanitizeUser(newUser);
};

const listInterns = async ({ page = 1, limit = 10, search = '' } = {}) => {
  const safePage = Math.max(1, Number(page) || 1);
  const safeLimit = Math.min(100, Math.max(1, Number(limit) || 10));

  const query = { user_role: "Student" };

  const normalizedSearch = String(search || '').trim();
  if (normalizedSearch) {
    query.$or = [
      { full_name: { $regex: normalizedSearch, $options: 'i' } },
      { email: { $regex: normalizedSearch, $options: 'i' } }
    ];
  }

  const [interns, total] = await Promise.all([
    User.find(query)
      .sort({ created_at: -1 })
      .skip((safePage - 1) * safeLimit)
      .limit(safeLimit),
    User.countDocuments(query)
  ]);

  return {
    data: interns.map(sanitizeUser),
    pagination: {
      total,
      page: safePage,
      limit: safeLimit,
      totalPages: Math.ceil(total / safeLimit)
    }
  };
};

const getInternById = async (internId) => {
  validateObjectId(internId, 'Intern');

  const intern = await User.findOne({ _id: internId, user_role: "Student" });
  if (!intern) {
    throw buildError('Intern not found', 404);
  }

  return sanitizeUser(intern);
};

const updateInternById = async (internId, payload = {}) => {
  validateObjectId(internId, 'Intern');

  const intern = await User.findOne({ _id: internId, user_role: "Student" });
  if (!intern) {
    throw buildError('Intern not found', 404);
  }

  const updatableFields = [
    'full_name',
    'phone_number',
    'account_status',
    'is_email_verified'
  ];
  // Checkout this for any sql injection attack possible
  for (const field of updatableFields) {
    if (payload[field] !== undefined) {
      intern[field] = payload[field];
    }
  }

  if (payload.email !== undefined) {
    const normalizedEmail = String(payload.email).toLowerCase().trim();
    const existingUser = await User.findOne({ email: normalizedEmail, _id: { $ne: internId } });
    if (existingUser) {
      throw buildError('Email already registered', 409);
    }
    intern.email = normalizedEmail;
  }
  if (payload.password !== undefined) {
    intern.password = await bcrypt.hash(payload.password, 12);
  }

  await intern.save();
  return sanitizeUser(intern);
};

const deleteInternById = async (internId) => {
  validateObjectId(internId, 'Intern');

  const intern = await User.findOneAndDelete({ _id: internId, user_role: "Student" });
  if (!intern) {
    throw buildError('Intern not found', 404);
  }

  return sanitizeUser(intern);
};

module.exports = {
  createUser,
  listInterns,
  getInternById,
  updateInternById,
  deleteInternById,
  sanitizeUser
};