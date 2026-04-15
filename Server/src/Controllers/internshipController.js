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
      department_code
    } = req.body;

    // Validate required fields
    if (!intern_id || !mentor_name || !department_code) {
      return res.status(400).json({
        msg: 'Please provide all required fields: intern_id (in URL), mentor_name, and department_code'
      });
    }

    // Find Department by Code
    const department = await Department.findOne({ code: department_code.toUpperCase() });
    if (!department) {
      return res.status(404).json({ msg: `Department with code '${department_code}' not found` });
    }

    // Find Mentor by full name
    const mentor = await User.findOne({ full_name: mentor_name, user_role: 'Mentor' });
    if (!mentor) {
      return res.status(404).json({ msg: `Mentor with name '${mentor_name}' not found` });
    }

    const assignment = await createInternshipAssignment({
      intern_id,
      mentor_id: mentor._id,
      department_id: department._id,
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
    const { mentor_name, department_code } = req.body;

    // Validate that at least one field is provided
    if (!mentor_name && !department_code) {
      return res.status(400).json({
        msg: 'Provide at least one field to update (mentor_name or department_code)'
      });
    }

    const updateData = {};
    if (mentor_name) {
      const mentor = await User.findOne({ full_name: mentor_name, user_role: 'Mentor' });
      if (!mentor) {
        return res.status(404).json({ msg: `Mentor with name '${mentor_name}' not found` });
      }
      updateData.mentor_id = mentor._id;
    }
    
    if (department_code) {
      const department = await Department.findOne({ code: department_code.toUpperCase() });
      if (!department) {
        return res.status(404).json({ msg: `Department with code '${department_code}' not found` });
      }
      updateData.department_id = department._id;
    }
    
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

