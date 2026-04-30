const mentorModuleService = require('../Services/trainingModuleService');
const { sendSuccess, sendError } = require('../utils/response');

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

    return sendSuccess(res, {
      status: 201,
      msg: 'Training module created successfully',
      data: module
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error creating training module',
      data: { error: error.message }
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

    return sendSuccess(res, {
      status: 200,
      msg: 'Training module retrieved successfully',
      data: module
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving training module',
      data: { error: error.message }
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

    return sendSuccess(res, {
      status: 200,
      msg: 'Training modules retrieved successfully',
      data: { count: modules.length, items: modules }
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving training modules',
      data: { error: error.message }
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

    return sendSuccess(res, {
      status: 200,
      msg: 'Your training modules retrieved successfully',
      data: { count: modules.length, items: modules }
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving your training modules',
      data: { error: error.message }
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

    return sendSuccess(res, {
      status: 200,
      msg: 'Training module updated successfully',
      data: updatedModule
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error updating training module',
      data: { error: error.message }
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

    return sendSuccess(res, {
      status: 200,
      msg: 'Training module deleted successfully',
      data: result
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error deleting training module',
      data: { error: error.message }
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

    return sendSuccess(res, {
      status: 200,
      msg: 'All training modules retrieved successfully',
      data: { count: modules.length, items: modules }
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving training modules',
      data: { error: error.message }
    });
  }
};
