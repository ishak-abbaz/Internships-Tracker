const express = require('express');
const router = express.Router();
const { createUser, listInterns, getInternById, updateInternById, approveIntern, deleteInternById} = require('../Controllers/adminController');

router.post('/api/v1/admin/users', createUser);
router.get('/api/v1/admin/interns', listInterns);
router.get('/api/v1/admin/interns/:internId', getInternById);
router.put('/api/v1/admin/interns/:internId', updateInternById);
router.post('/api/v1/admin/interns/:internId/approve', approveIntern);
router.delete('/api/v1/admin/interns/:internId', deleteInternById);

module.exports = router;