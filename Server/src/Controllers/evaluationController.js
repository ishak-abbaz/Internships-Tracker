const evaluationService = require('../Services/evaluationService');

/**
 * Create evaluation record
 * POST /api/evaluations
 */
exports.createEvaluation = async (req, res) => {
  try {
    const { internId, mentorId, weekLabel, overallMark, feedback } = req.body;

    const evaluation = await evaluationService.createEvaluation({
      internId,
      mentorId,
      weekLabel,
      overallMark,
      feedback
    });

    res.status(201).json({
      msg: 'Evaluation created successfully',
      data: evaluation
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error creating evaluation',
      error: error.message
    });
  }
};

/**
 * Get evaluation by ID
 * GET /api/evaluations/:evaluationId
 */
exports.getEvaluationById = async (req, res) => {
  try {
    const { evaluationId } = req.params;

    const evaluation = await evaluationService.getEvaluationById(evaluationId);

    res.status(200).json({
      msg: 'Evaluation retrieved successfully',
      data: evaluation
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving evaluation',
      error: error.message
    });
  }
};

/**
 * Get evaluation by intern name (search)
 * GET /api/evaluations/search/name/:internName
 */
exports.getEvaluationByInternName = async (req, res) => {
  try {
    const { internName } = req.params;
    const { limit = 50, page = 1 } = req.query;

    const result = await evaluationService.getEvaluationByName(
      internName,
      parseInt(limit),
      parseInt(page)
    );

    res.status(200).json({
      msg: 'Evaluations found for intern name',
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error searching evaluations',
      error: error.message
    });
  }
};

/**
 * Get all evaluations for specific intern
 * GET /api/evaluations/intern/:internId
 */
exports.getInternEvaluations = async (req, res) => {
  try {
    const { internId } = req.params;
    const { limit = 50, page = 1 } = req.query;

    const result = await evaluationService.getInternEvaluations(
      internId,
      parseInt(limit),
      parseInt(page)
    );

    res.status(200).json({
      msg: 'Intern evaluations retrieved successfully',
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving evaluations',
      error: error.message
    });
  }
};

/**
 * Get all evaluations by mentor
 * GET /api/evaluations/mentor/:mentorId
 */
exports.getMentorEvaluations = async (req, res) => {
  try {
    const { mentorId } = req.params;
    const { limit = 50, page = 1 } = req.query;

    const result = await evaluationService.getMentorEvaluations(
      mentorId,
      parseInt(limit),
      parseInt(page)
    );

    res.status(200).json({
      msg: 'Mentor evaluations retrieved successfully',
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving evaluations',
      error: error.message
    });
  }
};

/**
 * Update evaluation record
 * PUT /api/evaluations/:evaluationId
 */
exports.updateEvaluation = async (req, res) => {
  try {
    const { evaluationId } = req.params;
    const { weekLabel, overallMark, feedback } = req.body;

    const updatedEvaluation = await evaluationService.updateEvaluation(evaluationId, {
      weekLabel,
      overallMark,
      feedback
    });

    res.status(200).json({
      msg: 'Evaluation updated successfully',
      data: updatedEvaluation
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error updating evaluation',
      error: error.message
    });
  }
};

/**
 * Delete evaluation record
 * DELETE /api/evaluations/:evaluationId
 */
exports.deleteEvaluation = async (req, res) => {
  try {
    const { evaluationId } = req.params;

    const result = await evaluationService.deleteEvaluation(evaluationId);

    res.status(200).json({
      msg: result.msg,
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error deleting evaluation',
      error: error.message
    });
  }
};

/**
 * Get evaluation statistics for an intern
 * GET /api/evaluations/stats/:internId
 */
exports.getEvaluationStats = async (req, res) => {
  try {
    const { internId } = req.params;

    const stats = await evaluationService.getEvaluationStats(internId);
    res.status(200).json({
      msg: 'Evaluation statistics retrieved successfully',
      data: stats
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving statistics',
      error: error.message
    });
  }
};

/**
 * Get all evaluations with pagination
 * GET /api/evaluations
 */
exports.getAllEvaluations = async (req, res) => {
  try {
    const { limit = 50, page = 1 } = req.query;

    const result = await evaluationService.getAllEvaluations(
      parseInt(limit),
      parseInt(page)
    );

    res.status(200).json({
      msg: 'All evaluations retrieved successfully',
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving evaluations',
      error: error.message
    });
  }
};
