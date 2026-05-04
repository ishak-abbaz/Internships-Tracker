const mentorService = require('../Services/mentorService');

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

    res.status(201).json({
      msg: 'Attendance marked successfully',
      data: attendance
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error marking attendance',
      error: error.message
    });
  }
};

/**
 * Get all attendance records
 * GET /api/mentors/attendance
 */
exports.getAllAttendances = async (req, res) => {
  try {
    const { limit = 50, page = 1 } = req.query;

    const result = await mentorService.getAllAttendances(
      parseInt(limit),
      parseInt(page)
    );

    res.status(200).json({
      msg: 'All attendance records retrieved successfully',
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving attendances',
      error: error.message
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

    res.status(200).json({
      msg: 'Attendance retrieved successfully',
      data: attendance
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving attendance',
      error: error.message
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

    res.status(200).json({
      msg: 'Attendance records retrieved successfully',
      data: attendances
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving attendance',
      error: error.message
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

    res.status(200).json({
      msg: 'Intern attendance records retrieved successfully',
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving attendance',
      error: error.message
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

    res.status(200).json({
      msg: 'Attendance updated successfully',
      data: updatedAttendance
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error updating attendance',
      error: error.message
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

    res.status(200).json({
      msg: result.msg,
      data: result
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error deleting attendance',
      error: error.message
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

    res.status(200).json({
      msg: 'Attendance statistics retrieved successfully',
      data: stats
    });
  } catch (error) {
    res.status(error.status || 500).json({
      msg: error.message || 'Error retrieving statistics',
      error: error.message
    });
  }
};
