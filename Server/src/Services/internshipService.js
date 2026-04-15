const InternAssignment = require('../Models/internAssignmentModel');
const User = require('../Models/userModel');
const Department = require('../Models/departmentModel');
const mongoose = require('mongoose');

const buildError = (message, status = 500) => {
  const err = new Error(message);
  err.status = status;
  return err;
};

const validateObjectId = (id, entityName = 'ID') => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw buildError(`Invalid ${entityName}`, 400);
  }
};

// Create new internship assignment
exports.createInternshipAssignment = async ({
  intern_id,
  mentor_id,
  department_id,
  assigned_by_admin_id
}) => {
  // Validate all IDs
  validateObjectId(intern_id, 'Intern ID');
  validateObjectId(mentor_id, 'Mentor ID');
  validateObjectId(department_id, 'Department ID');
  validateObjectId(assigned_by_admin_id, 'Admin ID');

  // Check if intern exists and is a Student
  const intern = await User.findById(intern_id);
  if (!intern) {
    throw buildError('Intern not found', 404);
  }
  if (intern.user_role !== 'Student') {
    throw buildError('User is not a valid intern (must have Student role)', 400);
  }

  // Check if mentor exists and is a Mentor
  const mentor = await User.findById(mentor_id);
  if (!mentor) {
    throw buildError('Mentor not found', 404);
  }
  if (mentor.user_role !== 'Mentor') {
    throw buildError('User is not a valid mentor (must have Mentor role)', 400);
  }

  // Check if department exists
  const department = await Department.findById(department_id);
  if (!department) {
    throw buildError('Department not found', 404);
  }

  // Check if admin exists and is Admin
  const admin = await User.findById(assigned_by_admin_id);
  if (!admin) {
    throw buildError('Admin user not found', 404);
  }
  if (admin.user_role !== 'Admin') {
    throw buildError('Assigned user is not an admin', 400);
  }

  // Check if intern already has an active assignment
  const existingAssignment = await InternAssignment.findOne({
    intern_id
  });
  if (existingAssignment) {
    throw buildError('Intern already has an active assignment', 400);
  }

  // Create assignment
  const assignment = await InternAssignment.create({
    intern_id,
    mentor_id,
    department_id,
    assigned_by_admin_id
  });

  // Populate references
  await assignment.populate([
    { path: 'intern_id', select: 'full_name email university_id' },
    { path: 'mentor_id', select: 'full_name email specialization' },
    { path: 'department_id', select: 'name code' },
    { path: 'assigned_by_admin_id', select: 'full_name email' }
  ]);

  return assignment;
};

// Get all internship assignments
exports.getAllInternshipAssignments = async (filters = {}) => {
  const query = {};

  // Optional filters
  if (filters.mentor_id) {
    validateObjectId(filters.mentor_id, 'Mentor ID');
    query.mentor_id = filters.mentor_id;
  }
  if (filters.department_id) {
    validateObjectId(filters.department_id, 'Department ID');
    query.department_id = filters.department_id;
  }

  const assignments = await InternAssignment.find(query)
    .populate('intern_id', 'full_name email university_id')
    .populate('mentor_id', 'full_name email specialization')
    .populate('department_id', 'name code')
    .populate('assigned_by_admin_id', 'full_name email')
    .sort({ created_at: -1 });

  return assignments;
};

// Get internship assignment by ID
exports.getInternshipAssignmentById = async (id) => {
  validateObjectId(id, 'Assignment ID');

  const assignment = await InternAssignment.findById(id)
    .populate('intern_id', 'full_name email university_id')
    .populate('mentor_id', 'full_name email specialization')
    .populate('department_id', 'name code')
    .populate('assigned_by_admin_id', 'full_name email');

  if (!assignment) {
    throw buildError('Internship assignment not found', 404);
  }

  return assignment;
};

// Get assignments by intern ID
exports.getAssignmentsByInternId = async (intern_id) => {
  validateObjectId(intern_id, 'Intern ID');

  const assignments = await InternAssignment.find({ intern_id })
    .populate('mentor_id', 'full_name email specialization')
    .populate('department_id', 'name code')
    .populate('assigned_by_admin_id', 'full_name email')
    .sort({ created_at: -1 });

  return assignments;
};

// Get assignments by mentor ID
exports.getAssignmentsByMentorId = async (mentor_id) => {
  validateObjectId(mentor_id, 'Mentor ID');

  const assignments = await InternAssignment.find({ mentor_id })
    .populate('intern_id', 'full_name email university_id')
    .populate('department_id', 'name code')
    .populate('assigned_by_admin_id', 'full_name email')
    .sort({ created_at: -1 });

  return assignments;
};

// Update internship assignment
exports.updateInternshipAssignment = async (id, updateData) => {
  validateObjectId(id, 'Assignment ID');

  const assignment = await InternAssignment.findById(id);
  if (!assignment) {
    throw buildError('Internship assignment not found', 404);
  }

  // Validate new IDs if provided
  if (updateData.mentor_id) {
    validateObjectId(updateData.mentor_id, 'Mentor ID');
    const mentor = await User.findById(updateData.mentor_id);
    if (!mentor || mentor.user_role !== 'Mentor') {
      throw buildError('Invalid mentor', 400);
    }
    assignment.mentor_id = updateData.mentor_id;
  }

  if (updateData.department_id) {
    validateObjectId(updateData.department_id, 'Department ID');
    const department = await Department.findById(updateData.department_id);
    if (!department) {
      throw buildError('Invalid department', 400);
    }
    assignment.department_id = updateData.department_id;
  }

  await assignment.save();

  // Populate and return
  await assignment.populate([
    { path: 'intern_id', select: 'full_name email university_id' },
    { path: 'mentor_id', select: 'full_name email specialization' },
    { path: 'department_id', select: 'name code' },
    { path: 'assigned_by_admin_id', select: 'full_name email' }
  ]);

  return assignment;
};

// Delete internship assignment
exports.deleteInternshipAssignment = async (id) => {
  validateObjectId(id, 'Assignment ID');

  const assignment = await InternAssignment.findByIdAndDelete(id);
  if (!assignment) {
    throw buildError('Internship assignment not found', 404);
  }

  return assignment;
};
