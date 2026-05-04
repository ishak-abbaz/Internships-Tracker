const express = require('express');
const router = express.Router();

const {
  createPolicyHandbook,
  getAllPolicyHandbooks,
  getPolicyHandbookById,
  updatePolicyHandbook,
  deletePolicyHandbook,
  createOfficeSchedule,
  getAllOfficeSchedules,
  getOfficeScheduleById,
  updateOfficeSchedule,
  deleteOfficeSchedule,
} = require('../Controllers/AdminOfficeController');

const { protect, restrictTo } = require('../Middleware/auth');
const upload = require('../Middleware/upload');
const normalizeFields = require('../Middleware/normalizeFields');

// Protect all routes
router.use(protect);

// Policy Handbook
router.post(  '/policy/create',        restrictTo('Admin'), upload.single('file'), normalizeFields, createPolicyHandbook);
router.get(   '/policy/getall',        restrictTo('Admin', 'Mentor', 'Student'), getAllPolicyHandbooks);
router.get(   '/policy/:id',           restrictTo('Admin', 'Mentor', 'Student'), getPolicyHandbookById);
router.patch( '/policy/update/:id',    restrictTo('Admin'), upload.single('file'), normalizeFields, updatePolicyHandbook);
router.delete('/policy/delete/:id',    restrictTo('Admin'), deletePolicyHandbook);

// Office Schedule
router.post(  '/schedule/create',      restrictTo('Admin'), upload.single('file'), normalizeFields, createOfficeSchedule);
router.get(   '/schedule/getall',      restrictTo('Admin', 'Mentor', 'Student'), getAllOfficeSchedules);
router.get(   '/schedule/:id',         restrictTo('Admin', 'Mentor', 'Student'), getOfficeScheduleById);
router.patch( '/schedule/update/:id',  restrictTo('Admin'), upload.single('file'), normalizeFields, updateOfficeSchedule);
router.delete('/schedule/delete/:id',  restrictTo('Admin'), deleteOfficeSchedule);

module.exports = router;