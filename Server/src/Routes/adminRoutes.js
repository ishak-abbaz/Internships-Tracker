const express = require('express');
const router = express.Router();
const { createUser, listInterns, getInternById, updateInternById, approveIntern, deleteInternById} = require('../Controllers/adminController');

router.post('/users', createUser);
router.get('/interns', listInterns);
router.get('/interns/:internId', getInternById);
router.put('/interns/:internId', updateInternById);
router.post('/interns/:internId/approve', approveIntern);
router.delete('/interns/:internId', deleteInternById);

module.exports = router;