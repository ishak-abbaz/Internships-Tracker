const express = require('express');
const router = express.Router();

const {createUser, 
	listInterns, 
	listPendingInterns, 
	getInternById, 
	updateInternById, 
	approveIntern, 
	rejectIntern,
	deleteInternById,
	listMentors,
	getMentor,
	updateMentor,
	deleteMentor,
	listPendingRegistrations,
	getRegistrationById,
} = require('../Controllers/adminController');

const { protect, restrictTo } = require('../Middleware/auth');

// Protect all admin review routes
router.use(protect, restrictTo('Admin'));

router.post('/users', createUser);
router.get('/interns', listInterns);
router.get('/interns/pending', listPendingInterns);
router.get('/interns/:internId', getInternById);
router.patch('/interns/:internId', updateInternById);
router.post('/interns/:internId/approve', approveIntern);
router.post('/interns/:internId/reject', rejectIntern);
router.delete('/interns/:internId', deleteInternById);

router.get('/mentors', listMentors);
router.get('/mentors/:mentorId', getMentor);
router.patch('/mentors/:mentorId', updateMentor);
router.delete('/mentors/:mentorId', deleteMentor);

// Registration review CRUD (Admin only)
router.get('/registrations/pending', listPendingRegistrations);
router.get('/registrations/:id', getRegistrationById);

module.exports = router;
