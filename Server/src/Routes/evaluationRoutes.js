const express = require('express');
const router = express.Router();
const {
  createEvaluation,
  getEvaluationById,
  getEvaluationByName,
  getInternEvaluations,
  getMentorEvaluations,
  updateEvaluation,
  deleteEvaluation,
  getEvaluationStats,
  getAllEvaluations
} = require('../Controllers/evaluationController');

// ==================== EVALUATION ROUTES ====================

// Get all evaluations with pagination
router.get('/', getAllEvaluations);

// Create evaluation
router.post('/', createEvaluation);

// Get evaluation by ID
router.get('/id/:evaluationId', getEvaluationById);

// Get evaluation by intern name (search)
// router.get('/search/name/:internName', getEvaluationByInternName);

// Get evaluations for specific intern
router.get('/intern/:internId', getInternEvaluations);

// Get evaluations by mentor
router.get('/mentor/:mentorId', getMentorEvaluations);

// Get evaluation statistics for an intern
router.get('/stats/:internId', getEvaluationStats);

// Update evaluation record
router.patch('/:evaluationId', updateEvaluation);

// Delete evaluation record
router.delete('/:evaluationId', deleteEvaluation);

module.exports = router;
