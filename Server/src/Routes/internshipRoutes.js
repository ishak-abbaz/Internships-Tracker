const express = require('express');
const router = express.Router();

const {
  createInternship,
  getAllInternships,
  getInternshipById,
  getInternAssignments,
  getMentorAssignments,
  updateInternship,
  deleteInternship
} = require('../Controllers/internshipController');

const { protect, restrictTo } = require('../Middleware/auth');

// Protect all internship routes
router.use(protect);

// Admin-only routes
// Create new internship assignment for a specific intern
router.post('/:intern_id', restrictTo('Admin'), createInternship);

// Get all internship assignments (Admin)
router.get('/', restrictTo('Admin', 'Mentor'), getAllInternships);

router.get('/:id', restrictTo('Admin'), getInternshipById);

// Update internship assignment (Admin only)
router.patch('/update/:id', restrictTo('Admin'), updateInternship);

// Delete internship assignment (Admin only)
router.delete('/:id', restrictTo('Admin'), deleteInternship);


module.exports = router;
