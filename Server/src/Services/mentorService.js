const mongoose = require('mongoose');
const Attendance = require('../Models/attendanceModel');
const User = require('../Models/userModel');

/**
 * ==================== MENTOR SERVICE ====================
 * Handles all mentor-related operations for attendance management
 * 
 * Key Principles:
 * - Immutable Fields: intern_id, mentor_id, attendance_date, marked_by_mentor_id
 * - Updatable Fields: status, notes
 * - All operations maintain audit trail via marked_by_mentor_id
 * - Timestamp tracking via created_at and updated_at
 */

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

// ==================== ATTENDANCE CRUD OPERATIONS ====================

/**
 * Create attendance record (mentor marks student attendance)
 * 
 * @param {string} internId - The ID of the intern (immutable - cannot be changed later)
 * @param {string} mentorId - The ID of the mentor marking attendance (immutable - audit trail)
 * @param {Date} attendanceDate - The date of attendance (immutable - cannot be changed later)
 * @param {string} status - Status: 'present', 'absent', 'late', 'excused'
 * @param {string} notes - Optional notes about the attendance
 * @returns {object} Created attendance record with all fields
 */
exports.createAttendance = async ({ internId, mentorId, attendanceDate, status, notes }) => {
  try {
    // Validation: Check all required fields
    if (!internId || !mentorId || !attendanceDate || !status) {
      throw buildError('Please provide all required fields: internId, mentorId, attendanceDate, status', 400);
    }

    validateObjectId(internId, 'Intern');
    validateObjectId(mentorId, 'Mentor');

    // Validate status against allowed values
    const validStatuses = ['present', 'absent', 'late', 'excused'];
    if (!validStatuses.includes(status)) {
      throw buildError(`Status must be one of: ${validStatuses.join(', ')}`, 400);
    }

    // Verify both users exist in the system
    const [intern, mentor] = await Promise.all([
      User.findById(internId),
      User.findById(mentorId)
    ]);

    if (!intern) throw buildError('Intern not found', 404);
    if (!mentor) throw buildError('Mentor not found', 404);

    // Check for duplicate attendance on same date (prevent duplicate entries)
    const existingAttendance = await Attendance.findOne({
      intern_id: internId,
      attendance_date: new Date(attendanceDate).toDateString()
    });

    if (existingAttendance) {
      throw buildError('Attendance already recorded for this intern on this date. Delete and recreate if changes needed.', 409);
    }

    // Create new attendance record with audit trail
    const attendance = new Attendance({
      intern_id: internId,
      mentor_id: mentorId,
      attendance_date: new Date(attendanceDate),
      status,
      notes: notes || null,
      marked_by_mentor_id: mentorId // Audit trail: who marked this attendance
    });

    await attendance.save();

    return {
      id: attendance._id,
      intern_id: attendance.intern_id,
      mentor_id: attendance.mentor_id,
      attendance_date: attendance.attendance_date,
      status: attendance.status,
      notes: attendance.notes,
      marked_by_mentor_id: attendance.marked_by_mentor_id, // Immutable - shows who marked it
      created_at: attendance.created_at,
      updated_at: attendance.updated_at
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get attendance record by its ID
 * 
 * @param {string} attendanceId - The attendance record ID
 * @returns {object} Complete attendance record with populated user details
 */
exports.getAttendanceById = async (attendanceId) => {
  try {
    validateObjectId(attendanceId, 'Attendance');

    const attendance = await Attendance.findById(attendanceId)
      .populate('intern_id', 'full_name email')
      .populate('mentor_id', 'full_name email')
      .populate('marked_by_mentor_id', 'full_name email');

    if (!attendance) {
      throw buildError('Attendance record not found', 404);
    }

    return attendance;
  } catch (error) {
    throw error;
  }
};

/**
 * Get all attendance records for a specific date
 * 
 * @param {Date} attendanceDate - The date to query
 * @returns {array} All attendance records for that date
 */
exports.getAttendanceByDate = async (attendanceDate) => {
  try {
    const startDate = new Date(attendanceDate);
    const endDate = new Date(attendanceDate);
    endDate.setDate(endDate.getDate() + 1);

    const attendances = await Attendance.find({
      attendance_date: { $gte: startDate, $lt: endDate }
    })
      .populate('intern_id', 'full_name email')
      .populate('mentor_id', 'full_name email')
      .populate('marked_by_mentor_id', 'full_name email')
      .sort({ attendance_date: -1 });

    if (attendances.length === 0) {
      throw buildError('No attendance records found for this date', 404);
    }

    return attendances;
  } catch (error) {
    throw error;
  }
};

/**
 * Get all attendance records for a specific intern (with pagination)
 * 
 * @param {string} internId - The intern's ID
 * @param {number} limit - Records per page (default: 50)
 * @param {number} page - Page number (default: 1)
 * @returns {object} Paginated attendance records for the intern
 */
exports.getInternAttendances = async (internId, limit = 50, page = 1) => {
  try {
    validateObjectId(internId, 'Intern');

    const skip = (page - 1) * limit;

    const [attendances, total] = await Promise.all([
      Attendance.find({ intern_id: internId })
        .populate('mentor_id', 'full_name email')
        .populate('marked_by_mentor_id', 'full_name email')
        .sort({ attendance_date: -1 })
        .limit(limit)
        .skip(skip),
      Attendance.countDocuments({ intern_id: internId })
    ]);

    if (attendances.length === 0) {
      throw buildError('No attendance records found for this intern', 404);
    }

    return {
      data: attendances,
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
 * Update attendance record (partial updates supported)
 * 
 * IMPORTANT: IMMUTABLE FIELDS (cannot be changed):
 * - intern_id: Who was marked (tracked in audit)
 * - mentor_id: Which mentor assigned this attendance
 * - attendance_date: The date this attendance is for
 * - marked_by_mentor_id: Audit trail - who marked it (unchangeable for compliance)
 * 
 * UPDATABLE FIELDS (what mentor can change):
 * - status: 'present', 'absent', 'late', 'excused'
 * - notes: Any notes about the attendance
 * 
 * If you need to change intern_id, mentor_id, or date: DELETE and CREATE new record
 * 
 * @param {string} attendanceId - The attendance record to update
 * @param {string} status - (Optional) New status value
 * @param {string} notes - (Optional) New notes value (use '' to clear)
 * @returns {object} Updated attendance record
 */
exports.updateAttendance = async (attendanceId, { status, notes }) => {
  try {
    validateObjectId(attendanceId, 'Attendance');

    // Check that at least one field is provided for update
    if (status === undefined && notes === undefined) {
      throw buildError('Please provide at least one field to update (status or notes). Cannot update: intern_id, mentor_id, attendance_date, or marked_by_mentor_id (immutable fields).', 400);
    }

    // Validate status if provided (only updatable field with restrictions)
    if (status !== undefined) {
      const validStatuses = ['present', 'absent', 'late', 'excused'];
      if (!validStatuses.includes(status)) {
        throw buildError(`Status must be one of: ${validStatuses.join(', ')}`, 400);
      }
    }

    const updateData = {};
    
    // Only add fields to update if they are explicitly provided
    if (status !== undefined) {
      updateData.status = status;
    }
    
    if (notes !== undefined) {
      // Allow empty string to clear notes, or null
      updateData.notes = notes || null;
    }

    const attendance = await Attendance.findByIdAndUpdate(
      attendanceId,
      updateData,
      { new: true, runValidators: true }
    )
      .populate('intern_id', 'full_name email')
      .populate('mentor_id', 'full_name email')
      .populate('marked_by_mentor_id', 'full_name email');

    if (!attendance) {
      throw buildError('Attendance record not found', 404);
    }

    return attendance;
  } catch (error) {
    throw error;
  }
};

/**
 * Delete attendance record
 * 
 * Use this when:
 * - Attendance was marked incorrectly (wrong date, wrong intern)
 * - Need to remove duplicate attendance
 * - Invalid records need cleanup
 * 
 * After deletion, you can create a new record if needed
 * 
 * @param {string} attendanceId - The attendance record to delete
 * @returns {object} Confirmation message
 */
exports.deleteAttendance = async (attendanceId) => {
  try {
    validateObjectId(attendanceId, 'Attendance');

    const attendance = await Attendance.findByIdAndDelete(attendanceId);

    if (!attendance) {
      throw buildError('Attendance record not found', 404);
    }

    return { 
      msg: 'Attendance record deleted successfully',
      deletedRecordId: attendance._id,
      deletedAt: new Date()
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get attendance statistics for an intern
 * 
 * Returns breakdown of attendance by status and percentages
 * Useful for generating reports and performance metrics
 * 
 * @param {string} internId - The intern's ID
 * @returns {object} Statistics with total count and breakdown by status
 */
exports.getAttendanceStats = async (internId) => {
  try {
    validateObjectId(internId, 'Intern');

    const stats = await Attendance.aggregate([
      { $match: { intern_id: mongoose.Types.ObjectId(internId) } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    const total = stats.reduce((sum, s) => sum + s.count, 0);
    
    if (total === 0) {
      throw buildError('No attendance records found for this intern', 404);
    }

    const formatted = stats.map(s => ({
      status: s._id,
      count: s.count,
      percentage: total > 0 ? parseFloat(((s.count / total) * 100).toFixed(2)) : 0
    }));

    return { 
      total, 
      byStatus: formatted,
      generatedAt: new Date()
    };
  } catch (error) {
    throw error;
  }
};
