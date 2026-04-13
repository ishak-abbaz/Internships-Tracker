// const mongoose = require('mongoose');
const {
  createInternshipAssignment,
  getAllInternshipAssignments,
  getAllActiveInternships,
  getInternshipAssignmentById,
  getAssignmentsByInternId,
  getAssignmentsByMentorId,
  updateInternshipAssignment,
  deleteInternshipAssignment,
  getActiveAssignmentForIntern
} = require('../Services/internshipService');

// Create new internship assignment (Admin only)
exports.createInternship = async (req, res) => {
  try {
    const {
      intern_id,
      mentor_id,
      department_id,
      subject,
      start_date,
      end_date,
      status
    } = req.body;

    // Validate required fields
    if (!intern_id || !mentor_id || !department_id || !subject) {
      return res.status(400).json({
        msg: 'Please provide all required fields: intern_id, mentor_id, department_id, and subject'
      });
    }

    const assignment = await createInternshipAssignment({
      intern_id,
      mentor_id,
      department_id,
      subject,
      assigned_by_admin_id: req.user.id,
      start_date,
      end_date,
      status
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
    if (req.query.status) {
      filters.status = req.query.status;
    }
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

// Get active assignment for a specific intern
exports.getInternActiveAssignment = async (req, res) => {
  try {
    const { intern_id } = req.params;

    const assignment = await getActiveAssignmentForIntern(intern_id);

    res.status(200).json({
      msg: 'Active internship assignment fetched successfully',
      assignment
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to fetch active internship assignment',
      error: err.message
    });
  }
};

// Update internship assignment (Admin only)
exports.updateInternship = async (req, res) => {
  try {
    const { id } = req.params;
    const { mentor_id, department_id, subject, status, start_date, end_date } = req.body;

    // Validate that at least one field is provided
    if (!mentor_id && !department_id && !subject && !status && start_date === undefined && end_date === undefined) {
      return res.status(400).json({
        msg: 'Provide at least one field to update (mentor_id, department_id, subject, status, start_date, or end_date)'
      });
    }

    const updateData = {};
    if (mentor_id) updateData.mentor_id = mentor_id;
    if (department_id) updateData.department_id = department_id;
    if (subject) updateData.subject = subject;
    if (status) updateData.status = status;
    if (start_date !== undefined) updateData.start_date = start_date;
    if (end_date !== undefined) updateData.end_date = end_date;

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

// Get all active internship assignments (Admin only)
exports.getAllActiveInternships = async (req, res) => {
  try {
    const assignments = await getAllActiveInternships();

    res.status(200).json({
      msg: 'Active internship assignments fetched successfully',
      count: assignments.length,
      assignments
    });
  } catch (err) {
    res.status(err.status || 500).json({
      msg: err.message || 'Failed to fetch active internship assignments',
      error: err.message
    });
  }
};
