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

// Protect all routes — Admin only
router.use(protect, restrictTo('Admin'));

// Policy Handbook
router.post(  '/policy/create',        upload.single('file'), normalizeFields, createPolicyHandbook);
router.get(   '/policy/getall',getAllPolicyHandbooks);
router.get(   '/policy/:id',getPolicyHandbookById);
router.patch( '/policy/update/:id',    upload.single('file'), normalizeFields, updatePolicyHandbook);
router.delete('/policy/delete/:id',deletePolicyHandbook);

// Office Schedule
router.post(  '/schedule/create',      upload.single('file'), normalizeFields, createOfficeSchedule);
router.get(   '/schedule/getall',  getAllOfficeSchedules);
router.get(   '/schedule/:id',     getOfficeScheduleById);
router.patch( '/schedule/update/:id',  upload.single('file'), normalizeFields, updateOfficeSchedule);
router.delete('/schedule/delete/:id',deleteOfficeSchedule);

module.exports = router;