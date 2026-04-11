const adminService = require('../Services/adminService');

/**
 * Create a new user (admin, mentor, or student)
 * POST /api/admin/users
 */
exports.createUser = async (req, res) => {
  try {
    const { full_name, email, password, phone_number, user_role } = req.body;

    const user = await adminService.createUser({
      full_name,
      email,
      password,
      phone_number,
      user_role
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