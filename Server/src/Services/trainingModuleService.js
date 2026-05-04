const mongoose = require('mongoose');
const TrainingModule = require('../Models/trainingModuleModel');
const Department = require('../Models/departmentModel');
const User = require('../Models/userModel');

/**
 * ==================== TRAINING MODULE SERVICE ====================
 * Handles all training module-related operations for mentors
 * 
 * Key Principles:
 * - Immutable Fields: created_by_mentor_id, created_at
 * - Updatable Fields: title, description, url, is_active
 * - All operations maintain audit trail via created_by_mentor_id
 * - Department validation by code (not ID)
 */

const buildError = (message, status = 500) => {
  const err = new Error(message);
  err.status = status;
  return err;
};

const validateObjectId = (id, entityName = 'Entity') => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    console.log(`❌ Invalid ${entityName} ID:`, id);
    throw buildError(`Invalid ${entityName} ID`, 400);
  }
};

const validateUrl = (url) => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

// ==================== TRAINING MODULE CRUD OPERATIONS ====================

/**
 * Create a new training module (Mentor only)
 * 
 * @param {string} title - Module title (required)
 * @param {string} description - Module description (required)
 * @param {string} url - URL to training material (required)
 * @param {string} departmentCode - Department code in uppercase (required)
 * @param {string} mentorId - ID of the mentor creating the module (required)
 * @returns {object} Created training module document
 */
exports.createTrainingModule = async ({
  title,
  description,
  url,
  departmentCode,
  mentorId
}) => {
  try {
    // Validation: Check all required fields
    if (!title || !description || !url || !departmentCode || !mentorId) {
      throw buildError(
        'Please provide all required fields: title, description, url, departmentCode, mentorId',
        400
      );
    }

    validateObjectId(mentorId, 'Mentor');

    // Validate URL format
    if (!validateUrl(url)) {
      throw buildError('Invalid URL format', 400);
    }

    // Verify mentor exists in the system
    const mentor = await User.findById(mentorId);
    if (!mentor) {
      throw buildError('Mentor not found', 404);
    }

    // Verify department exists by code
    const department = await Department.findOne({ code: departmentCode.toUpperCase() });
    if (!department) {
      throw buildError(`Department with code ${departmentCode} not found`, 404);
    }

    // Check if module with same title already exists in this department
    const existingModule = await TrainingModule.findOne({
      title: title.trim(),
      department_code: departmentCode.toUpperCase()
    });
    if (existingModule) {
      throw buildError(
        `Training module "${title}" already exists for department ${departmentCode}`,
        409
      );
    }

    // Create the training module
    const newModule = new TrainingModule({
      title: title.trim(),
      description: description.trim(),
      url: url.trim(),
      department_code: departmentCode.toUpperCase(),
      created_by_mentor_id: mentorId,
      is_active: true
    });

    await newModule.save();

    // Populate creator info before returning
    await newModule.populate('created_by_mentor_id', 'name email');

    return newModule;
  } catch (error) {
    throw error;
  }
};

/**
 * Get training module by ID
 * 
 * @param {string} moduleId - Module ID (required)
 * @returns {object} Training module document with mentor details
 */
exports.getTrainingModuleById = async (moduleId) => {
  try {
    validateObjectId(moduleId, 'TrainingModule');

    const module = await TrainingModule.findById(moduleId).populate('created_by_mentor_id', 'name email');

    if (!module) {
      throw buildError('Training module not found', 404);
    }

    return module;
  } catch (error) {
    throw error;
  }
};

/**
 * Get all training modules for a specific department
 * 
 * @param {string} departmentCode - Department code (required)
 * @param {boolean} activeOnly - Return only active modules (optional, default: true)
 * @returns {array} Array of training modules
 */
exports.getModulesByDepartment = async (departmentCode, activeOnly = true) => {
  try {
    if (!departmentCode) {
      throw buildError('Department code is required', 400);
    }

    // Verify department exists
    const department = await Department.findOne({ code: departmentCode.toUpperCase() });
    if (!department) {
      throw buildError(`Department with code ${departmentCode} not found`, 404);
    }

    const query = { department_code: departmentCode.toUpperCase() };
    if (activeOnly) {
      query.is_active = true;
    }

    const modules = await TrainingModule.find(query)
      .populate('created_by_mentor_id', 'name email')
      .sort({ created_at: -1 });

    return modules;
  } catch (error) {
    throw error;
  }
};

/**
 * Get all training modules created by a specific mentor
 * 
 * @param {string} mentorId - Mentor ID (required)
 * @param {boolean} activeOnly - Return only active modules (optional, default: false)
 * @returns {array} Array of training modules created by mentor
 */
exports.getModulesByMentor = async (mentorId, activeOnly = false) => {
  try {
    validateObjectId(mentorId, 'Mentor');

    // Verify mentor exists
    const mentor = await User.findById(mentorId);
    if (!mentor) {
      throw buildError('Mentor not found', 404);
    }

    const query = { created_by_mentor_id: mentorId };
    if (activeOnly) {
      query.is_active = true;
    }

    const modules = await TrainingModule.find(query).sort({ created_at: -1 });

    return modules;
  } catch (error) {
    throw error;
  }
};

/**
 * Update training module (Mentor only - must be creator)
 * 
 * @param {string} moduleId - Module ID (required)
 * @param {string} mentorId - Mentor ID requesting update (required)
 * @param {object} updateData - Fields to update (title, description, url, is_active)
 * @returns {object} Updated training module
 */
exports.updateTrainingModule = async (moduleId, mentorId, updateData) => {
  try {
    validateObjectId(moduleId, 'TrainingModule');
    validateObjectId(mentorId, 'Mentor');

    // Find module and verify mentor is the creator
    const module = await TrainingModule.findById(moduleId);
    if (!module) {
      throw buildError('Training module not found', 404);
    }

    const user = await User.findById(mentorId);
    const isAdmin = user?.user_role === 'Admin';

    if (module.created_by_mentor_id.toString() !== mentorId && !isAdmin) {
      throw buildError('Only the creator of this module or an Admin can update it', 403);
    }

    // Validate and update fields
    const updatableFields = ['title', 'description', 'url', 'is_active'];
    const allowedUpdates = Object.keys(updateData).filter((key) =>
      updatableFields.includes(key)
    );

    // Validate URL if provided
    if (updateData.url && !validateUrl(updateData.url)) {
      throw buildError('Invalid URL format', 400);
    }

    // Update fields
    allowedUpdates.forEach((key) => {
      if (key === 'title' || key === 'description' || key === 'url') {
        module[key] = updateData[key].trim();
      } else {
        module[key] = updateData[key];
      }
    });

    await module.save();

    // Populate creator info before returning
    await module.populate('created_by_mentor_id', 'name email');

    return module;
  } catch (error) {
    throw error;
  }
};

/**
 * Delete training module (Mentor only - must be creator)
 * 
 * @param {string} moduleId - Module ID (required)
 * @param {string} mentorId - Mentor ID requesting deletion (required)
 * @returns {object} Deleted module information
 */
exports.deleteTrainingModule = async (moduleId, mentorId) => {
  try {
    validateObjectId(moduleId, 'TrainingModule');
    validateObjectId(mentorId, 'Mentor');

    // Find module and verify mentor is the creator
    const module = await TrainingModule.findById(moduleId);
    if (!module) {
      throw buildError('Training module not found', 404);
    }

    const user = await User.findById(mentorId);
    const isAdmin = user?.user_role === 'Admin';

    if (module.created_by_mentor_id.toString() !== mentorId && !isAdmin) {
      throw buildError('Only the creator of this module or an Admin can delete it', 403);
    }

    // Delete the module
    await TrainingModule.findByIdAndDelete(moduleId);

    return {
      deletedModuleId: moduleId,
      title: module.title
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get all training modules (Admin/Mentor view)
 * 
 * @param {boolean} activeOnly - Return only active modules (optional, default: false)
 * @returns {array} All training modules
 */
exports.getAllTrainingModules = async (activeOnly = false) => {
  try {
    const query = activeOnly ? { is_active: true } : {};

    const modules = await TrainingModule.find(query)
      .populate('created_by_mentor_id', 'name email')
      .sort({ created_at: -1 });

    return modules;
  } catch (error) {
    throw error;
  }
};
