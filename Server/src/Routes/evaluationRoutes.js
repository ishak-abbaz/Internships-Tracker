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

// Protect all evaluation routes
router.use(protect);

// ==================== EVALUATION ROUTES ====================

// Get all evaluations (Admin only)
router.get('/', restrictTo('Admin'), getAllEvaluations);

// Create evaluation (Mentor only)
router.post('/', restrictTo('Mentor'), createEvaluation);

// Get evaluation statistics (Accessible to all authenticated users)
router.get('/stats/:internId', getEvaluationStats);

// Get evaluation by ID
router.get('/id/:evaluationId', getEvaluationById);

// Get evaluations for specific intern (Accessible to all authenticated users)
router.get('/intern/:internId', getInternEvaluations);

// Get evaluations by mentor
router.get('/mentor/:mentorId', getMentorEvaluations);

// Update evaluation record (Mentor only, typically the one who created it)
router.patch('/:evaluationId', restrictTo('Mentor'), updateEvaluation);

// Delete evaluation record (Mentor or Admin)
router.delete('/:evaluationId', restrictTo('Mentor', 'Admin'), deleteEvaluation);

module.exports = router;
