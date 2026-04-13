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
router.use(protect, restrictTo('Admin'));

// Department CRUD (Admin only)
router.post('/createdep', createDepartment);
router.get('/getAlldep', getAllDepartments);
router.get('/:id', getDepartmentById);
router.patch('/updatedep/:id', updateDepartment);
router.delete('/delete/:id', deleteDepartment);

module.exports = router;
