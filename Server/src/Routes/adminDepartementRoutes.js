const express = require('express');
const router = express.Router();

const {
	createDepartment,
	getAllDepartments,
	getDepartmentById,
	updateDepartment,
	deleteDepartment
} = require('../Controllers/adminDepartementController');

const { protect, restrictTo } = require('../Middleware/auth');

// Protect all department routes
router.use(protect);

// Department CRUD
router.post('/createdep', restrictTo('Admin'), createDepartment);
router.get('/getAlldep', restrictTo('Admin', 'Mentor', 'Student'), getAllDepartments);
router.get('/:id', restrictTo('Admin', 'Mentor', 'Student'), getDepartmentById);
router.patch('/updatedep/:id', restrictTo('Admin'), updateDepartment);
router.delete('/delete/:id', restrictTo('Admin'), deleteDepartment);

module.exports = router;
