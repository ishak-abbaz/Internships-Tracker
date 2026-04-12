const express = require('express');
const router = express.Router();
const {
  markAttendance,
  getAttendanceById,
  getAttendanceByDate,
  getInternAttendances,
  updateAttendance,
  deleteAttendance,
  getAttendanceStats
} = require('../Controllers/mentorController');

// ==================== ATTENDANCE ROUTES ====================

// Mark attendance - mentor marks student attendance
router.post('/attendance', markAttendance);

// Get attendance by ID
router.get('/attendance/id/:attendanceId', getAttendanceById);

// Get attendance by date
router.get('/attendance/date/:attendanceDate', getAttendanceByDate);

// Get attendance for specific intern
router.get('/attendance/intern/:internId', getInternAttendances);

// Get attendance statistics for an intern
router.get('/attendance/stats/:internId', getAttendanceStats);

// Update attendance record
router.put('/attendance/:attendanceId', updateAttendance);

// Delete attendance record
router.delete('/attendance/:attendanceId', deleteAttendance);

module.exports = router;