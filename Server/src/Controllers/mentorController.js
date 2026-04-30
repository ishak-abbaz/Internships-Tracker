const mentorService = require('../Services/mentorService');
const { sendSuccess, sendError } = require('../utils/response');

// ==================== ATTENDANCE CONTROLLERS ====================

/**
 * Create attendance record (Mark student attendance)
 * POST /api/mentors/attendance
 */
exports.markAttendance = async (req, res) => {
  try {
    const { internId, mentorId, attendanceDate, status, notes } = req.body;

    const attendance = await mentorService.createAttendance({
      internId,
      mentorId,
      attendanceDate,
      status,
      notes
    });

    return sendSuccess(res, {
      status: 201,
      msg: 'Attendance marked successfully',
      data: attendance
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error marking attendance',
      data: { error: error.message }
    });
  }
};

/**
 * Get attendance by ID
 * GET /api/mentors/attendance/:attendanceId
 */
exports.getAttendanceById = async (req, res) => {
  try {
    const { attendanceId } = req.params;

    const attendance = await mentorService.getAttendanceById(attendanceId);

    return sendSuccess(res, {
      status: 200,
      msg: 'Attendance retrieved successfully',
      data: attendance
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving attendance',
      data: { error: error.message }
    });
  }
};

/**
 * Get attendance by date
 * GET /api/mentors/attendance/date/:attendanceDate
 */
exports.getAttendanceByDate = async (req, res) => {
  try {
    const { attendanceDate } = req.params;

    const attendances = await mentorService.getAttendanceByDate(attendanceDate);

    return sendSuccess(res, {
      status: 200,
      msg: 'Attendance records retrieved successfully',
      data: attendances
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving attendance',
      data: { error: error.message }
    });
  }
};

/**
 * Get attendance for specific intern
 * GET /api/mentors/attendance/intern/:internId
 */
exports.getInternAttendances = async (req, res) => {
  try {
    const { internId } = req.params;
    const { limit = 50, page = 1 } = req.query;

    const result = await mentorService.getInternAttendances(
      internId,
      parseInt(limit),
      parseInt(page)
    );

    return sendSuccess(res, {
      status: 200,
      msg: 'Intern attendance records retrieved successfully',
      data: result
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving attendance',
      data: { error: error.message }
    });
  }
};

/**
 * Update attendance record
 * PUT /api/mentors/attendance/:attendanceId
 */
exports.updateAttendance = async (req, res) => {
  try {
    const { attendanceId } = req.params;
    const { status, notes } = req.body;

    const updatedAttendance = await mentorService.updateAttendance(attendanceId, {
      status,
      notes
    });

    return sendSuccess(res, {
      status: 200,
      msg: 'Attendance updated successfully',
      data: updatedAttendance
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error updating attendance',
      data: { error: error.message }
    });
  }
};

/**
 * Delete attendance record
 * DELETE /api/mentors/attendance/:attendanceId
 */
exports.deleteAttendance = async (req, res) => {
  try {
    const { attendanceId } = req.params;

    const result = await mentorService.deleteAttendance(attendanceId);

    return sendSuccess(res, {
      status: 200,
      msg: result.msg,
      data: result
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error deleting attendance',
      data: { error: error.message }
    });
  }
};

/**
 * Get attendance statistics for an intern
 * GET /api/mentors/attendance/stats/:internId
 */
exports.getAttendanceStats = async (req, res) => {
  try {
    const { internId } = req.params;

    const stats = await mentorService.getAttendanceStats(internId);

    return sendSuccess(res, {
      status: 200,
      msg: 'Attendance statistics retrieved successfully',
      data: stats
    });
  } catch (error) {
    return sendError(res, {
      status: error.status || 500,
      msg: error.message || 'Error retrieving statistics',
      data: { error: error.message }
    });
  }
};
