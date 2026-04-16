const User = require('../Models/userModel');
const mongoose = require('mongoose');

exports.listPendingRegistrations = async (req, res) => {
  try {
    const pendingUsers = await User.find({
      account_status: 'pending',
      user_role: { $in: ['Student', 'Mentor'] }
    })
      .select('-password -reset_Password_Token -reset_Password_expires_at')
      .sort({ created_at: 1 });

    res.status(200).json({
      msg: 'Pending registrations fetched successfully',
      count: pendingUsers.length,
      users: pendingUsers
    });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch pending registrations', error: err.message });
  }
};

exports.getRegistrationById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ msg: 'Invalid user id' });
    }

    const user = await User.findById(id).select('-password -reset_Password_Token -reset_Password_expires_at');
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    res.status(200).json({
      msg: 'User fetched successfully',
      user
    });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch user', error: err.message });
  }
};

exports.listPendingInterns = async (req, res) => {
  try {
    const pendingUsers = await User.find({
      account_status: 'pending',
      user_role: { $in: ['Student', 'Mentor'] }
    })
      .select('-password -reset_Password_Token -reset_Password_expires_at')
      .sort({ created_at: 1 });

    res.status(200).json({
      msg: 'Pending registrations fetched successfully',
      count: pendingUsers.length,
      users: pendingUsers
    });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch pending registrations', error: err.message });
  }
};

/**
 * Create a new user (admin, mentor, or student)
 * POST /api/admin/users
 */
exports.createUser = async (req, res) => {
  try {
    const { full_name, email, password, phone_number, user_role, department_id, specialization, admin_scope } = req.body;
    const user = await adminService.createUser({
      full_name,
      email,
      password,
      phone_number,
      user_role,
      department_id,
      specialization,
      admin_scope
    });

    res.status(201).json({
      success: true,
      msg: 'User created successfully. Verification email sent.',
      data: user
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to create user',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * List all interns with pagination and search
 * GET /api/admin/interns
 */
exports.listInterns = async (req, res) => {
  try {
    const { page, limit, search } = req.query;

    const result = await adminService.listInterns({
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 10,
      search: search || ''
    });

    res.status(200).json({
      success: true,
      msg: 'Interns fetched successfully.',
      data: result.data,
      pagination: result.pagination
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to fetch interns',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Get a specific intern by ID
 * GET /api/admin/interns/:internId
 */
exports.getInternById = async (req, res) => {
  try {
    const { internId } = req.params;

    const intern = await adminService.getInternById(internId);

    res.status(200).json({
      success: true,
      msg: 'Intern fetched successfully.',
      data: intern
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to fetch intern',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Update an intern by ID
 * PUT /api/admin/interns/:internId
 */
exports.updateInternById = async (req, res) => {
  try {
    const { internId } = req.params;
    const payload = req.body;

    const updatedIntern = await adminService.updateInternById(internId, payload);

    res.status(200).json({
      success: true,
      msg: 'Intern updated successfully.',
      data: updatedIntern
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to update intern',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Delete an intern by ID
 * DELETE /api/admin/interns/:internId
 */
exports.deleteInternById = async (req, res) => {
  try {
    const { internId } = req.params;

    const deletedIntern = await adminService.deleteInternById(internId);

    res.status(200).json({
      success: true,
      msg: 'Intern deleted successfully.',
      data: deletedIntern
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to delete intern',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Approve an intern registration
 * POST /api/admin/interns/:internId/approve
 */
exports.approveIntern = async (req, res) => {
  try {
    const { internId } = req.params;

    const approvedIntern = await adminService.updateInternById(internId, { 
      account_status: 'approved' 
    });

    res.status(200).json({
      success: true,
      msg: 'Intern approved successfully.',
      data: approvedIntern
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to approve intern',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Reject an intern registration
 * POST /api/admin/interns/:internId/reject
 */
exports.rejectIntern = async (req, res) => {
  try {
    const { internId } = req.params;

    const rejectedIntern = await adminService.updateInternById(internId, { 
      account_status: 'declined' 
    });

    res.status(200).json({
      success: true,
      msg: 'Intern rejected successfully.',
      data: rejectedIntern
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to reject intern',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * List all mentors with pagination and search
 * GET /api/admin/mentors
 */
exports.listMentors = async (req, res) => {
  try {
    const { page, limit, search } = req.query;

    const result = await adminService.listMentors({
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 10,
      search: search || ''
    });

    res.status(200).json({
      success: true,
      msg: 'Mentors fetched successfully.',
      data: result.data,
      pagination: result.pagination
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to fetch mentors',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Get a specific mentor by ID
 * GET /api/admin/mentors/:mentorId
 */
exports.getMentor = async (req, res) => {
  try {
    const { mentorId } = req.params;

    const mentor = await adminService.getMentorById(mentorId);

    res.status(200).json({
      success: true,
      msg: 'Mentor fetched successfully.',
      data: mentor
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to fetch mentor',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Update a mentor by ID
 * PUT /api/admin/mentors/:mentorId
 */
exports.updateMentor = async (req, res) => {
  try {
    const { mentorId } = req.params;
    const payload = req.body;

    const updatedMentor = await adminService.updateMentorById(mentorId, payload);

    res.status(200).json({
      success: true,
      msg: 'Mentor updated successfully.',
      data: updatedMentor
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to update mentor',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};

/**
 * Delete a mentor by ID
 * DELETE /api/admin/mentors/:mentorId
 */
exports.deleteMentor = async (req, res) => {
  try {
    const { mentorId } = req.params;

    const deletedMentor = await adminService.deleteMentorById(mentorId);

    res.status(200).json({
      success: true,
      msg: 'Mentor deleted successfully.',
      data: deletedMentor
    });
  } catch (err) {
    const statusCode = err.status || 500;
    res.status(statusCode).json({
      success: false,
      msg: err.message || 'Failed to delete mentor',
      error: process.env.NODE_ENV === 'development' ? err : undefined
    });
  }
};