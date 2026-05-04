const express = require('express');
const router = express.Router();
const {
  createEvaluation,
  getEvaluationById,
  getInternEvaluations,
  getMentorEvaluations,
  updateEvaluation,
  deleteEvaluation,
  getEvaluationStats,
  getAllEvaluations
} = require('../Controllers/evaluationController');

const { protect, restrictTo } = require('../Middleware/auth');

// ==================== EVALUATION ROUTES ====================

// Protect all evaluation routes
router.use(protect);

// Get all evaluations with pagination - Admin and Mentor can see all
router.get('/', restrictTo('Admin', 'Mentor'), getAllEvaluations);

// Create evaluation - Mentors and Admins can evaluate
router.post('/', restrictTo('Admin', 'Mentor'), createEvaluation);

// Get evaluation by ID - Authenticated users
router.get('/id/:evaluationId', getEvaluationById);

// Get evaluations for specific intern - Admin, Mentor, or the Intern themselves
router.get('/intern/:internId', restrictTo('Admin', 'Mentor', 'Student'), getInternEvaluations);

// Get evaluations by mentor - Admin and Mentor
router.get('/mentor/:mentorId', restrictTo('Admin', 'Mentor'), getMentorEvaluations);

// Get evaluation statistics for an intern - Admin, Mentor, or the Intern themselves
router.get('/stats/:internId', restrictTo('Admin', 'Mentor', 'Student'), getEvaluationStats);

// Update evaluation record - Mentor who created it or Admin
router.patch('/:evaluationId', restrictTo('Admin', 'Mentor'), updateEvaluation);

// Delete evaluation record - Admin only usually
router.delete('/:evaluationId', restrictTo('Admin'), deleteEvaluation);

module.exports = router;
