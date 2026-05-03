const express = require('express');
const router = express.Router();
const {
    createTrainingModule, 
    getTrainingModuleById, 
    getModulesByDepartment, 
    getModulesByMentor,
    updateTrainingModule, 
    deleteTrainingModule, 
    getAllTrainingModules
} = require('../Controllers/trainingModuleController');
const {
    restrictTo, 
    protect
} = require('../Middleware/auth');

router.use(protect);

/**
 * Get all training modules (with filters)
 * GET /api/mentors/training-modules
 * Query params: activeOnly (true/false, default: false)
 */
router.get('/', getAllTrainingModules);

/**
 * Get training module by ID
 * GET /api/mentors/training-modules/:moduleId
 */
router.get('/:moduleId', getTrainingModuleById);

/**
 * Get all training modules for a department
 * GET /api/mentors/training-modules/department/:departmentCode
 * Query params: activeOnly (true/false, default: true)
 */
router.get('/department/:departmentCode', getModulesByDepartment);

// ==================== PROTECTED ROUTES (Mentor Only) ====================

/**
 * Create a new training module
 * POST /api/mentors/training-modules
 * Body: { title, description, url, departmentCode }
 * Auth: Required (Mentor)
 */
router.post('/', restrictTo('Admin', 'Mentor'), createTrainingModule);

/**
 * Get all training modules created by the mentor (current user)
 * GET /api/mentors/training-modules/my-modules
 * Query params: activeOnly (true/false, default: false)
 * Auth: Required (Mentor)
 */
router.get('/mentor/:mentorId', getModulesByMentor);

/**
 * Update training module
 * PUT /api/mentors/training-modules/:moduleId
 * Body: { title?, description?, url?, is_active? }
 * Auth: Required (Mentor who created the module)
 */
router.patch('/:moduleId', restrictTo('Admin', 'Mentor'), updateTrainingModule);

/**
 * Delete training module
 * DELETE /api/mentors/training-modules/:moduleId
 * Auth: Required (Mentor who created the module)
 */
router.delete('/:moduleId', restrictTo('Admin', 'Mentor'), deleteTrainingModule);

module.exports = router;
