const mentorModuleService = require('../Services/mentorModuleService');

// ==================== TRAINING MODULE CONTROLLERS ====================

/**
 * Create a new training module
 * POST /api/mentors/training-modules
 * Mentor only
 */
exports.createTrainingModule = async (req, res) => {
  try {
    const { title, description, url, departmentCode } = req.body;
    const mentorId = req.user.id;

    const module = await mentorModuleService.createTrainingModule({
      title,
      description,
      url,
      departmentCode,
      mentorId
    });

    res.status(201).json({
      msg: 'Training module created successfully',
      data: module
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error creating training module',
      error: error.message
    });
  }
};
/**
 * Get training module by ID
 * GET /api/mentors/training-modules/:moduleId
 */
exports.getTrainingModuleById = async (req, res) => {
  try {
    const { moduleId } = req.params;

    const module = await mentorModuleService.getTrainingModuleById(moduleId);

    res.status(200).json({
      msg: 'Training module retrieved successfully',
      data: module
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving training module',
      error: error.message
    });
  }
};
/**
 * Get all training modules for a department
 * GET /api/mentors/training-modules/department/:departmentCode
 * Query params: activeOnly (true/false)
 */
exports.getModulesByDepartment = async (req, res) => {
  try {
    const { departmentCode } = req.params;
    const { activeOnly = true } = req.query;

    const modules = await mentorModuleService.getModulesByDepartment(
      departmentCode,
      activeOnly === 'true'
    );

    res.status(200).json({
      msg: 'Training modules retrieved successfully',
      count: modules.length,
      data: modules
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving training modules',
      error: error.message
    });
  }
};

/**
 * Get all training modules created by a mentor
 * GET /api/mentors/training-modules/my-modules
 * Mentor only
 * Query params: activeOnly (true/false)
 */
exports.getModulesByMentor = async (req, res) => {
  try {
    const { mentorId } = req.params;
    const { activeOnly = false } = req.query;

    const modules = await mentorModuleService.getModulesByMentor(
      mentorId,
      activeOnly === 'false'
    );

    res.status(200).json({
      msg: 'Your training modules retrieved successfully',
      count: modules.length,
      data: modules
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving your training modules',
      error: error.message
    });
  }
};

/**
 * Update training module
 * PUT /api/mentors/training-modules/:moduleId
 * Mentor only (must be creator)
 */
exports.updateTrainingModule = async (req, res) => {
  try {
    const { moduleId } = req.params;
    const mentorId = req.user.id;
    const updateData = req.body;

    const updatedModule = await mentorModuleService.updateTrainingModule(
      moduleId,
      mentorId,
      updateData
    );

    res.status(200).json({
      msg: 'Training module updated successfully',
      data: updatedModule
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error updating training module',
      error: error.message
    });
  }
};

/**
 * Delete training module
 * DELETE /api/mentors/training-modules/:moduleId
 * Mentor only (must be creator)
 */
exports.deleteTrainingModule = async (req, res) => {
  try {
    const { moduleId } = req.params;
    const mentorId = req.user.id;

    const result = await mentorModuleService.deleteTrainingModule(moduleId, mentorId);

    res.status(200).json({
      msg: 'Training module deleted successfully',
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error deleting training module',
      error: error.message
    });
  }
};

/**
 * Get all training modules (Admin/General view)
 * GET /api/mentors/training-modules
 * Query params: activeOnly (true/false)
 */
exports.getAllTrainingModules = async (req, res) => {
  try {
    const { activeOnly = false } = req.query;

    const modules = await mentorModuleService.getAllTrainingModules(activeOnly === 'true');

    res.status(200).json({
      msg: 'All training modules retrieved successfully',
      count: modules.length,
      data: modules
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving training modules',
      error: error.message
    });
  }
};
