const express = require('express');
const router = express.Router();

const {
	listPendingRegistrations,
	getRegistrationById,
	approveRegistration,
	declineRegistration
} = require('../Controllers/adminController');

const { protect, restrictTo } = require('../Middleware/auth');

// Protect all admin review routes
router.use(protect, restrictTo('Admin'));

// Registration review CRUD (Admin only)
router.get('/registrations/pending', listPendingRegistrations);
router.get('/registrations/:id', getRegistrationById);
router.patch('/registrations/:id/approve', approveRegistration);
router.patch('/registrations/:id/decline', declineRegistration);

module.exports = router;