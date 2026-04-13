const express = require('express');
const router = express.Router();

const {
  createInternship,
  getAllInternships,
  getAllActiveInternships,
  getInternshipById,
  getInternAssignments,
  getMentorAssignments,
  getInternActiveAssignment,
  updateInternship,
  deleteInternship
} = require('../Controllers/internshipController');

const { protect, restrictTo } = require('../Middleware/auth');

// Protect all internship routes
router.use(protect);

// Admin-only routes
// Create new internship assignment
router.post('/', restrictTo('Admin'), createInternship);

// Get all internship assignments (Admin)
router.get('/', restrictTo('Admin'), getAllInternships);

// Get all active internship assignments (Admin)
router.get('/active/', restrictTo('Admin'), getAllActiveInternships);

// Update internship assignment (Admin only)
router.patch('/update/:id', restrictTo('Admin'), updateInternship);

// Delete internship assignment (Admin only)
router.delete('/:id', restrictTo('Admin'), deleteInternship);

// Routes accessible to all authenticated users
// Get specific internship assignment by ID
router.get('/:id', getInternshipById);

// Get all assignments for a specific intern
router.get('/intern/:intern_id/assignments', getInternAssignments);

// Get active assignment for a specific intern
router.get('/intern/:intern_id/active', getInternActiveAssignment);

// Get all assignments for a mentor (mentor can view their interns)
// If mentor_id is not provided, it uses the logged-in user's ID
router.get('/mentor/:mentor_id/assignments', restrictTo('Mentor', 'Admin'), getMentorAssignments);

module.exports = router;
