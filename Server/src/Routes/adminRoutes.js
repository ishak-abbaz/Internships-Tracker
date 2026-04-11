const express = require('express');
const router = express.Router();
const { 
	createUser, 
	listInterns, 
	listPendingInterns, 
	getInternById, 
	updateInternById, 
	approveIntern, 
	rejectIntern,
	deleteInternById
} = require('../Controllers/adminController');

const { protect, restrictTo } = require('../Middleware/auth');

// Protect all admin review routes
router.use(protect, restrictTo('Admin'));

router.post('/users', createUser);
router.get('/interns', listInterns);
router.get('/interns/pending', listPendingInterns);
router.get('/interns/:internId', getInternById);
router.put('/interns/:internId', updateInternById);
router.post('/interns/:internId/approve', approveIntern);
router.post('/interns/:internId/reject', rejectIntern);
router.delete('/interns/:internId', deleteInternById);

module.exports = router;