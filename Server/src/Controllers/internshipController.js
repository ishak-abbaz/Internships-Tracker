const User = require('../Models/userModel');
const Department = require('../Models/departmentModel');
const {
  createInternshipAssignment,
  getAllInternshipAssignments,
  getInternshipAssignmentById,
  updateInternshipAssignment,
  deleteInternshipAssignment
} = require('../Services/internshipService');

// Create new internship assignment (Admin only)
exports.createInternship = async (req, res) => {
  try {
    const { intern_id } = req.params;
    const {
      mentor_name,
      department_code,
      subject,
      start_date,
      end_date
    } = req.body;

    // Validate required fields
    if (!intern_id || !mentor_name || !department_code || !subject || !start_date || !end_date) {
      return res.status(400).json({
        msg: '❌ Error: Please provide all required fields: intern_id (in URL), mentor_name, and department_code',
        error: 'Missing required fields'
      });
    }

    // Lookup mentor by name
    const mentor = await User.findOne({ full_name: mentor_name, user_role: 'Mentor' });
    if (!mentor) {
      return res.status(404).json({ msg: `Mentor with name '${mentor_name}' not found` });
    }

    // Lookup department by code
    const department = await Department.findOne({ code: department_code });
    if (!department) {
      return res.status(404).json({ msg: `Department with code '${department_code}' not found` });
    }

    const assignment = await createInternshipAssignment({
      intern_id,
      mentor_id: mentor._id,
      department_id: department._id,
      subject,
      start_date,
      end_date,
      assigned_by_admin_id: req.user.id
    });

    res.status(201).json({
      msg: 'Internship assignment created successfully',
      assignment
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to create internship assignment',
      error: err.message
    });
  }
};

// Get all internship assignments
exports.getAllInternships = async (req, res) => {
  try {
    const filters = {};

    // Optional query filters
    if (req.query.mentor_id) {
      filters.mentor_id = req.query.mentor_id;
    }
    if (req.query.department_id) {
      filters.department_id = req.query.department_id;
    }

    const assignments = await getAllInternshipAssignments(filters);

    res.status(200).json({
      msg: 'Internship assignments fetched successfully',
      count: assignments.length,
      assignments
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to fetch internship assignments',
      error: err.message
    });
  }
};

// Get internship assignment by ID
exports.getInternshipById = async (req, res) => {
  try {
    const { id } = req.params;

    const assignment = await getInternshipAssignmentById(id);

    res.status(200).json({
      msg: 'Internship assignment fetched successfully',
      assignment
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to fetch internship assignment',
      error: err.message
    });
  }
};

// Get assignments for a specific intern
exports.getInternAssignments = async (req, res) => {
  try {
    const { intern_id } = req.params;

    const assignments = await getAssignmentsByInternId(intern_id);

    res.status(200).json({
      msg: 'Intern assignments fetched successfully',
      count: assignments.length,
      assignments
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to fetch intern assignments',
      error: err.message
    });
  }
};

// Get assignments for a specific mentor
exports.getMentorAssignments = async (req, res) => {
  try {
    // If no mentor_id provided, use logged-in user (assuming they are a mentor)
    const mentor_id = req.params.mentor_id;

    const assignments = await getAssignmentsByMentorId(mentor_id);

    res.status(200).json({
      msg: 'Mentor assignments fetched successfully',
      count: assignments.length,
      assignments
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to fetch mentor assignments',
      error: err.message
    });
  }
};

// Update internship assignment (Admin only)
exports.updateInternship = async (req, res) => {
  try {
    const { id } = req.params;
    const { mentor_id, department_id, subject, start_date, end_date } = req.body;

    const updateData = {};
    if (mentor_id) updateData.mentor_id = mentor_id;
    if (department_id) updateData.department_id = department_id;
    if (subject) updateData.subject = subject;
    if (start_date) updateData.start_date = start_date;
    if (end_date) updateData.end_date = end_date;
    
    const assignment = await updateInternshipAssignment(id, updateData);

    res.status(200).json({
      msg: 'Internship assignment updated successfully',
      assignment
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to update internship assignment',
      error: err.message
    });
  }
};

// Delete internship assignment (Admin only)
exports.deleteInternship = async (req, res) => {
  try {
    const { id } = req.params;

    const assignment = await deleteInternshipAssignment(id);

    res.status(200).json({
      msg: 'Internship assignment deleted successfully',
      assignment
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to delete internship assignment',
      error: err.message
    });
  }
};

