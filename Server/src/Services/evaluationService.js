const mongoose = require('mongoose');
const Evaluation = require('../Models/evaluationModel');
const User = require('../Models/userModel');

const buildError = (message, status = 500) => {
  const err = new Error(message);
  err.status = status;
  return err;
};

const validateObjectId = (id, entityName = 'Entity') => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw buildError(`Invalid ${entityName} ID`, 400);
  }
};

/**
 * Create evaluation record
 */
exports.createEvaluation = async ({ internId, mentorId, weekLabel, overallMark, feedback }) => {
  try {
    // Validation
    if (!internId || !mentorId || overallMark === undefined) {
      throw buildError('Please provide all required fields: internId, mentorId, overallMark', 400);
    }

    validateObjectId(internId, 'Intern');
    validateObjectId(mentorId, 'Mentor');

    if (typeof overallMark !== 'number' || overallMark < 0 || overallMark > 100) {
      throw buildError('Overall mark must be a number between 0 and 100', 400);
    }

    // Verify users exist
    const [intern, mentor] = await Promise.all([
      User.findById(internId),
      User.findById(mentorId)
    ]);

    if (!intern) throw buildError('Intern not found', 404);
    if (!mentor) throw buildError('Mentor not found', 404);

    const evaluation = new Evaluation({
      intern_id: internId,
      mentor_id: mentorId,
      week_label: weekLabel || null,
      overall_mark: overallMark,
      feedback: feedback || null,
      evaluated_at: new Date()
    });

    await evaluation.save();

    return {
      id: evaluation._id,
      intern_id: evaluation.intern_id,
      mentor_id: evaluation.mentor_id,
      week_label: evaluation.week_label,
      overall_mark: evaluation.overall_mark,
      feedback: evaluation.feedback,
      evaluated_at: evaluation.evaluated_at,
      created_at: evaluation.created_at,
      updated_at: evaluation.updated_at
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get evaluation by ID
 */
exports.getEvaluationById = async (evaluationId) => {
  try {
    validateObjectId(evaluationId, 'Evaluation');

    const evaluation = await Evaluation.findById(evaluationId)
      .populate('intern_id', 'full_name email')
      .populate('mentor_id', 'full_name email');

    if (!evaluation) {
      throw buildError('Evaluation record not found', 404);
    }

    return evaluation;
  } catch (error) {
    throw error;
  }
};

/**
 * Get evaluation by name search
 */
exports.getEvaluationByName = async (internName, limit = 50, page = 1) => {
  try {
    const skip = (page - 1) * limit;

    const [evaluations, total] = await Promise.all([
      Evaluation.aggregate([
        {
          $lookup: {
            from: 'users',
            localField: 'intern_id',
            foreignField: '_id',
            as: 'intern'
          }
        },
        { $unwind: '$intern' },
        {
          $match: {
            'intern.full_name': { $regex: internName, $options: 'i' }
          }
        },
        { $sort: { evaluated_at: -1 } },
        { $skip: skip },
        { $limit: limit }
      ]),
      Evaluation.aggregate([
        {
          $lookup: {
            from: 'users',
            localField: 'intern_id',
            foreignField: '_id',
            as: 'intern'
          }
        },
        { $unwind: '$intern' },
        {
          $match: {
            'intern.full_name': { $regex: internName, $options: 'i' }
          }
        },
        { $count: 'total' }
      ])
    ]);

    if (evaluations.length === 0) {
      throw buildError('No evaluations found matching this intern name', 404);
    }

    const totalCount = total.length > 0 ? total[0].total : 0;

    return {
      data: evaluations,
      total: totalCount,
      page,
      limit,
      pages: Math.ceil(totalCount / limit)
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get all evaluations for a specific intern
 */
exports.getInternEvaluations = async (internId, limit = 50, page = 1) => {
  try {
    validateObjectId(internId, 'Intern');

    const skip = (page - 1) * limit;

    const [evaluations, total] = await Promise.all([
      Evaluation.find({ intern_id: internId })
        .populate('mentor_id', 'full_name email')
        .sort({ evaluated_at: -1 })
        .limit(limit)
        .skip(skip),
      Evaluation.countDocuments({ intern_id: internId })
    ]);

    if (evaluations.length === 0) {
      throw buildError('No evaluations found for this intern', 404);
    }

    return {
      data: evaluations,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit)
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get all evaluations from a specific mentor
 */
exports.getMentorEvaluations = async (mentorId, limit = 50, page = 1) => {
  try {
    validateObjectId(mentorId, 'Mentor');

    const skip = (page - 1) * limit;

    const [evaluations, total] = await Promise.all([
      Evaluation.find({ mentor_id: mentorId })
        .populate('intern_id', 'full_name email')
        .sort({ evaluated_at: -1 })
        .limit(limit)
        .skip(skip),
      Evaluation.countDocuments({ mentor_id: mentorId })
    ]);

    if (evaluations.length === 0) {
      throw buildError('No evaluations found for this mentor', 404);
    }

    return {
      data: evaluations,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit)
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Update evaluation record (partial updates supported)
 */
exports.updateEvaluation = async (evaluationId, { weekLabel, overallMark, feedback }) => {
  try {
    validateObjectId(evaluationId, 'Evaluation');

    // Check that at least one field is provided for update
    if (weekLabel === undefined && overallMark === undefined && feedback === undefined) {
      throw buildError('Please provide at least one field to update (weekLabel, overallMark, or feedback)', 400);
    }

    // Validate overallMark if provided
    if (overallMark !== undefined) {
      if (typeof overallMark !== 'number' || overallMark < 0 || overallMark > 100) {
        throw buildError('Overall mark must be a number between 0 and 100', 400);
      }
    }

    const updateData = {};
    
    // Only add fields to update if they are explicitly provided
    if (weekLabel !== undefined) {
      updateData.week_label = weekLabel || null;
    }
    
    if (overallMark !== undefined) {
      updateData.overall_mark = overallMark;
    }
    
    if (feedback !== undefined) {
      // Allow empty string to clear feedback, or null
      updateData.feedback = feedback || null;
    }

    const evaluation = await Evaluation.findByIdAndUpdate(
      evaluationId,
      updateData,
      { new: true, runValidators: true }
    );

    if (!evaluation) {
      throw buildError('Evaluation record not found', 404);
    }

    return evaluation;
  } catch (error) {
    throw error;
  }
};

/**
 * Delete evaluation record
 */
exports.deleteEvaluation = async (evaluationId) => {
  try {
    validateObjectId(evaluationId, 'Evaluation');

    const evaluation = await Evaluation.findByIdAndDelete(evaluationId);

    if (!evaluation) {
      throw buildError('Evaluation record not found', 404);
    }

    return { msg: 'Evaluation record deleted successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * Get evaluation statistics for an intern
 */
exports.getEvaluationStats = async (internId) => {
  try {
    validateObjectId(internId, 'Intern');

    const stats = await Evaluation.aggregate([
      { $match: { intern_id: mongoose.Types.ObjectId(internId) } },
      {
        $group: {
          _id: null,
          avgMark: { $avg: '$overall_mark' },
          maxMark: { $max: '$overall_mark' },
          minMark: { $min: '$overall_mark' },
          totalEvaluations: { $sum: 1 }
        }
      }
    ]);

    if (stats.length === 0) {
      throw buildError('No evaluations found for this intern', 404);
    }

    return {
      averageMark: parseFloat(stats[0].avgMark.toFixed(2)),
      highestMark: stats[0].maxMark,
      lowestMark: stats[0].minMark,
      totalEvaluations: stats[0].totalEvaluations
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get all evaluations with pagination
 */
exports.getAllEvaluations = async (limit = 50, page = 1) => {
  try {
    const skip = (page - 1) * limit;

    const [evaluations, total] = await Promise.all([
      Evaluation.find()
        .populate('intern_id', 'full_name email')
        .populate('mentor_id', 'full_name email')
        .sort({ evaluated_at: -1 })
        .limit(limit)
        .skip(skip),
      Evaluation.countDocuments()
    ]);

    if (evaluations.length === 0) {
      throw buildError('No evaluations found', 404);
    }

    return {
      data: evaluations,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit)
    };
  } catch (error) {
    throw error;
  }
};
