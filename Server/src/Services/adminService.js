const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const User = require('../Models/userModel');
const Intern = require('../Models/internModel');
const Mentor = require('../Models/mentorModel');
const Admin = require('../Models/adminModel');
const { generateVerificationToken, sendVerificationEmail } = require('../utils/sendEmail');

const VALID_ROLES = ['Student', 'Mentor', 'Admin'];

const buildError = (message, status = 500) => {
  const err = new Error(message);
  err.status = status;
  return err;
};

const sanitizeUser = (user) => {
  const sanitized = {
    id: user._id,
    full_name: user.full_name,
    email: user.email,
    user_role: user.user_role,
    account_status: user.account_status,
    is_email_verified: user.is_email_verified,
    created_at: user.created_at,
    updated_at: user.updated_at
  };

  // Add role-specific fields
  if (user.user_role === 'Student') {
    sanitized.university_id = user.university_id || null;
    sanitized.department_id = user.department_id || null;
    sanitized.mentor_id = user.mentor_id || null;
    sanitized.is_validated_by_admin = user.is_validated_by_admin || false;
    sanitized.work_id = user.work_id || null;
    sanitized.id_photo_url = user.id_photo_url || '/uploads/default-intern-photo.png';
  }

  if (user.user_role === 'Mentor') {
    sanitized.department_id = user.department_id;
    sanitized.specialization = user.specialization;
  }

  if (user.user_role === 'Admin') {
    sanitized.admin_scope = user.admin_scope || 'hr';
  }

  return sanitized;
};
// Method used to sanitize data got from user
const validateObjectId = (id, entityName = 'User') => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw buildError(`Invalid ${entityName} ID`, 400);
  }
};

const createUser = async ({ full_name, email, password, user_role = 'Student', department_id = null, mentor_id = null, specialization = null, admin_scope = null }) => {
  
    if (!full_name || !email || !password || !user_role) {
    throw buildError('Please provide all required fields', 400);
  }

  if (!VALID_ROLES.includes(user_role)) {
    throw buildError('Invalid user role', 400);
  }

  // Validate role-specific fields
  if (user_role === 'Student') {
    // Validate department_id if provided
    if (department_id && !mongoose.Types.ObjectId.isValid(department_id)) {
      throw buildError('Invalid department_id', 400);
    }
    // Validate mentor_id if provided
    if (mentor_id && !mongoose.Types.ObjectId.isValid(mentor_id)) {
      throw buildError('Invalid mentor_id', 400);
    }
  }

  if (user_role === 'Mentor') {
    if (!department_id || !specialization) {
      throw buildError('Mentor requires department_id and specialization', 400);
    }
    if (!mongoose.Types.ObjectId.isValid(department_id)) {
      throw buildError('Invalid department_id', 400);
    }
  }

  if (user_role === 'Admin') {
    if (!admin_scope) {
      throw buildError('Admin requires admin_scope (hr or university)', 400);
    }
    if (!['hr', 'university'].includes(admin_scope)) {
      throw buildError('admin_scope must be either "hr" or "university"', 400);
    }
  }

  const existingUser = await User.findOne({ email: email.toLowerCase().trim() });
  if (existingUser) {
    throw buildError('Email already registered', 409);
  }

  const hashedPassword = await bcrypt.hash(password, 12);
  const emailToken = generateVerificationToken();
  const emailTokenExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

  const newUserData = {
    full_name: full_name.trim(),
    email: email.toLowerCase().trim(),
    password: hashedPassword,
    user_role,
    email_verification_token: emailToken,
    email_verification_expires: emailTokenExpiry,
    is_email_verified: false,
    account_status: user_role === 'Admin' || user_role === 'Mentor' ? 'approved' : 'pending'
  };

  // Add role-specific fields
  if (user_role === 'Student') {
    if (department_id) newUserData.department_id = department_id;
    if (mentor_id) newUserData.mentor_id = mentor_id;
  }

  if (user_role === 'Mentor') {
    newUserData.department_id = department_id;
    newUserData.specialization = specialization;
  }

  if (user_role === 'Admin') {
    newUserData.admin_scope = admin_scope;
  }

  // Create user with appropriate model based on role
  let newUser;
  if (user_role === 'Mentor') {
    newUser = new Mentor(newUserData);
  } else if (user_role === 'Admin') {
    newUser = new Admin(newUserData);
  } else if (user_role === 'Student') {
    newUser = new Intern(newUserData);
  } else {
    newUser = new User(newUserData);
  }

  await newUser.save();
  // await sendVerificationEmail(newUser.email, newUser.full_name, emailToken);

  return sanitizeUser(newUser);
};

const listInterns = async ({ page = 1, limit = 10, search = '', include = '' } = {}) => {
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

  // Parse include parameter to determine what to populate
  const includeFields = include ? String(include).split(',').map(f => f.trim()).filter(f => f) : [];
  
  let userQuery = User.find(query)
    .sort({ created_at: -1 })
    .skip((safePage - 1) * safeLimit)
    .limit(safeLimit);

  // Apply conditional population
  if (includeFields.includes('department')) {
    userQuery = userQuery.populate('department_id', 'name code _id');
  }
  if (includeFields.includes('mentor')) {
    userQuery = userQuery.populate('mentor_id', 'full_name email _id');
  }

  const [interns, total] = await Promise.all([
    userQuery,
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

const getInternById = async (internId, include = '') => {
  validateObjectId(internId, 'Intern');

  // Parse include parameter to determine what to populate
  const includeFields = include ? String(include).split(',').map(f => f.trim()).filter(f => f) : [];

  let query = User.findOne({ _id: internId, user_role: "Student" });

  // Apply conditional population
  if (includeFields.includes('department')) {
    query = query.populate('department_id', 'name code _id');
  }
  if (includeFields.includes('mentor')) {
    query = query.populate('mentor_id', 'full_name email _id');
  }

  const intern = await query;
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

  // Validate mentor_id if provided
  if (payload.mentor_id && !mongoose.Types.ObjectId.isValid(payload.mentor_id)) {
    throw buildError('Invalid mentor_id', 400);
  }

  // Validate department_id if provided
  if (payload.department_id && !mongoose.Types.ObjectId.isValid(payload.department_id)) {
    throw buildError('Invalid department_id', 400);
  }

  const updatableFields = [
    'full_name',
    'account_status',
    'is_email_verified',
    'is_validated_by_admin',
    'department_id',
    'mentor_id',
    'university_id',
    'work_id'
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

const approveIntern = async (internId) => {
  validateObjectId(internId, 'Intern');
  // Your approval logic here
  return updateInternById(internId, { account_status: 'approved' });
};

const deleteInternById = async (internId) => {
  validateObjectId(internId, 'Intern');

  const intern = await User.findOneAndDelete({ _id: internId, user_role: "Student" });
  if (!intern) {
    throw buildError('Intern not found', 404);
  }

  return sanitizeUser(intern);
};

const listMentors = async ({ page = 1, limit = 10, search = '', include = '' } = {}) => {
  const safePage = Math.max(1, Number(page) || 1);
  const safeLimit = Math.min(100, Math.max(1, Number(limit) || 10));

  const query = { user_role: "Mentor" };

  const normalizedSearch = String(search || '').trim();
  if (normalizedSearch) {
    query.$or = [
      { full_name: { $regex: normalizedSearch, $options: 'i' } },
      { email: { $regex: normalizedSearch, $options: 'i' } }
    ];
  }

  // Parse include parameter to determine what to populate
  const includeFields = include ? String(include).split(',').map(f => f.trim()).filter(f => f) : [];
  
  let userQuery = User.find(query)
    .sort({ created_at: -1 })
    .skip((safePage - 1) * safeLimit)
    .limit(safeLimit);

  // Apply conditional population
  if (includeFields.includes('department')) {
    userQuery = userQuery.populate('department_id', 'name code _id');
  }

  const [mentors, total] = await Promise.all([
    userQuery,
    User.countDocuments(query)
  ]);

  return {
    data: mentors.map(sanitizeUser),
    pagination: {
      total,
      page: safePage,
      limit: safeLimit,
      totalPages: Math.ceil(total / safeLimit)
    }
  };
};

const getMentorById = async (mentorId, include = '') => {
  validateObjectId(mentorId, 'Mentor');

  // Parse include parameter to determine what to populate
  const includeFields = include ? String(include).split(',').map(f => f.trim()).filter(f => f) : [];

  let query = User.findOne({ _id: mentorId, user_role: "Mentor" });

  // Apply conditional population
  if (includeFields.includes('department')) {
    query = query.populate('department_id', 'name code _id');
  }

  const mentor = await query;
  if (!mentor) {
    throw buildError('Mentor not found', 404);
  }

  return sanitizeUser(mentor);
};

const updateMentorById = async (mentorId, payload = {}) => {
  validateObjectId(mentorId, 'Mentor');

  const mentor = await User.findOne({ _id: mentorId, user_role: "Mentor" });
  if (!mentor) {
    throw buildError('Mentor not found', 404);
  }

  const updatableFields = [
    'full_name',
    'account_status',
    'is_email_verified',
    'is_validated_by_admin'
  ];

  for (const field of updatableFields) {
    if (payload[field] !== undefined) {
      mentor[field] = payload[field];
    }
  }

  if (payload.email !== undefined) {
    const normalizedEmail = String(payload.email).toLowerCase().trim();
    const existingUser = await User.findOne({ email: normalizedEmail, _id: { $ne: mentorId } });
    if (existingUser) {
      throw buildError('Email already registered', 409);
    }
    mentor.email = normalizedEmail;
  }

  if (payload.password !== undefined) {
    mentor.password = await bcrypt.hash(payload.password, 12);
  }

  await mentor.save();
  return sanitizeUser(mentor);
};

const deleteMentorById = async (mentorId) => {
  validateObjectId(mentorId, 'Mentor');

  const mentor = await User.findOneAndDelete({ _id: mentorId, user_role: "Mentor" });
  if (!mentor) {
    throw buildError('Mentor not found', 404);
  }

  return sanitizeUser(mentor);
};

module.exports = {
  createUser,
  listInterns,
  getInternById,
  updateInternById,
  approveIntern,
  deleteInternById,
  listMentors,
  getMentorById,
  updateMentorById,
  deleteMentorById,
  sanitizeUser
};