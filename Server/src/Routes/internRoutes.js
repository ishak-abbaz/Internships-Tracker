const express = require('express');
const multer = require('multer');
const router = express.Router();

const {
  getMyInternshipAssignment,
  getMySchedules,
  getMyTrainingModules,
  downloadTrainingModuleById,
  getMyWorkId,
  uploadWorkIdPhoto,
  downloadWorkIdPhoto,
  getMyDepartment,
  getMyProfile,
  getMyEvaluations
} = require('../Controllers/internController');

const { protect, restrictTo } = require('../Middleware/auth');

const imageUpload = multer({
  storage: multer.memoryStorage(),
  fileFilter: (_req, file, cb) => {
    if (file.mimetype && file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 }
});

// Protect all intern routes — Student only
router.use(protect, restrictTo('Student'));

router.get('/assignment', getMyInternshipAssignment);
router.get('/schedules', getMySchedules);
router.get('/training-modules', getMyTrainingModules);
router.get('/training-modules/:moduleId/download', downloadTrainingModuleById);
router.get('/department', getMyDepartment);
router.get('/profile', getMyProfile);
router.get('/work-id', getMyWorkId);
router.post('/work-id/photo', imageUpload.single('file'), uploadWorkIdPhoto);
router.get('/evaluations', getMyEvaluations);

module.exports = router;
