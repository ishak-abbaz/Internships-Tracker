const mongoose = require('mongoose');
const { Readable } = require('stream');
const cloudinary = require('../Config/cloudinary');
const Intern = require('../Models/internModel');
const Policy = require('../Models/policyModel');
const Schedule = require('../Models/scheduleModel');
const Evaluation = require('../Models/evaluationModel');
const InternAssignment = require('../Models/internAssignmentModel');

// ─── Helpers ────────────────────────────────────────────────────────────────

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

/** Upload an image buffer to Cloudinary and return { secure_url, public_id } */
const uploadToCloudinary = (buffer, folder) =>
	new Promise((resolve, reject) => {
		const stream = cloudinary.uploader.upload_stream(
			{ resource_type: 'image', folder },
			(err, result) => (err ? reject(err) : resolve(result))
		);
		Readable.from(buffer).pipe(stream);
	});

/** Delete a file from Cloudinary (silently ignores errors) */
const deleteFromCloudinary = async (publicId) => {
	if (!publicId) return;
	try {
		await cloudinary.uploader.destroy(publicId, { resource_type: 'image' });
	} catch (_) { /* ignore */ }
};

const getInternContext = async (internId) => {
	const [intern, assignment] = await Promise.all([
		Intern.findById(internId)
			.select('department_id mentor_id work_id id_photo_url id_photo_public_id account_status is_validated_by_admin'),
		InternAssignment.findOne({ intern_id: internId })
			.populate('department_id', 'name code')
			.populate('mentor_id', 'full_name email')
			.sort({ created_at: -1 })
	]);

	if (!intern) return { intern: null, assignment: null, departmentId: null, mentorId: null };

	const departmentId = assignment?.department_id?._id || intern.department_id || null;
	const mentorId = assignment?.mentor_id?._id || intern.mentor_id || null;

	return { intern, assignment, departmentId, mentorId };
};

// ─── Intern Views ───────────────────────────────────────────────────────────

exports.getMyInternshipAssignment = async (req, res) => {
	try {
		const internId = req.user?._id;
		if (!internId || !isValidId(internId)) return res.status(401).json({ msg: 'Unauthorized' });

		const context = await getInternContext(internId);

		const { assignment } = context;

		if (!assignment) {
			return res.status(404).json({ msg: 'No internship assignment found for this intern' });
		}

		res.status(200).json({ msg: 'Fetched successfully', assignment });
	} catch (err) {
		res.status(500).json({ msg: 'Failed to fetch internship assignment', error: err.message });
	}
};

exports.getMySchedules = async (req, res) => {
	try {
		const internId = req.user?._id;
		if (!internId || !isValidId(internId)) return res.status(401).json({ msg: 'Unauthorized' });

		const context = await getInternContext(internId);

		const { departmentId, mentorId } = context;

		const scheduleFilters = [{ intern_id: internId }];
		if (departmentId) scheduleFilters.push({ department_id: departmentId });
		if (mentorId) scheduleFilters.push({ mentor_id: mentorId });

		const schedules = await Schedule.find({
			is_active: { $ne: false },
			$or: scheduleFilters
		})
			.populate('department_id', 'name code')
			.populate('mentor_id', 'full_name email')
			.sort({ schedule_date: -1, created_at: -1 });

		res.status(200).json({ msg: 'Fetched successfully', count: schedules.length, schedules });
	} catch (err) {
		res.status(500).json({ msg: 'Failed to fetch schedules', error: err.message });
	}
};

exports.getMyTrainingModules = async (req, res) => {
	try {
		const internId = req.user?._id;
		if (!internId || !isValidId(internId)) return res.status(401).json({ msg: 'Unauthorized' });

		const context = await getInternContext(internId);

		const { departmentId } = context;

		const departmentFilter = [{ department_id: null }];
		if (departmentId) departmentFilter.push({ department_id: departmentId });

		// Training modules are currently stored in the Policy collection.
		const trainingModules = await Policy.find({
			is_active: { $ne: false },
			target_role: { $in: ['All', 'student'] },
			$or: departmentFilter
		}).sort({ created_at: -1 });

		res.status(200).json({
			msg: 'Fetched successfully',
			count: trainingModules.length,
			trainingModules
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to fetch training modules', error: err.message });
	}
};

exports.downloadTrainingModuleById = async (req, res) => {
	try {
		const internId = req.user?._id;
		if (!internId || !isValidId(internId)) return res.status(401).json({ msg: 'Unauthorized' });

		const { moduleId } = req.params;
		if (!isValidId(moduleId)) return res.status(400).json({ msg: 'Invalid training module id' });

		const context = await getInternContext(internId);

		const { departmentId } = context;
		const trainingModule = await Policy.findById(moduleId);
		if (!trainingModule) return res.status(404).json({ msg: 'Training module not found' });

		const roleAllowed = trainingModule.target_role === 'All' || trainingModule.target_role === 'student';
		const departmentAllowed = !trainingModule.department_id ||
			(departmentId && String(trainingModule.department_id) === String(departmentId));

		if (!roleAllowed || !departmentAllowed || trainingModule.is_active === false) {
			return res.status(403).json({ msg: 'You are not allowed to access this training module' });
		}

		if (!trainingModule.file_url) {
			return res.status(404).json({ msg: 'Training module file not found' });
		}

		return res.redirect(trainingModule.file_url);
	} catch (err) {
		res.status(500).json({ msg: 'Failed to download training module', error: err.message });
	}
};

exports.getMyWorkId = async (req, res) => {
	try {
		const internId = req.user?._id;
		if (!internId || !isValidId(internId)) return res.status(401).json({ msg: 'Unauthorized' });

		const [intern, assignment] = await Promise.all([
			Intern.findById(internId)
				.select('_id full_name email user_role university_id department_id mentor_id work_id id_photo_url account_status is_validated_by_admin created_at updated_at')
				.populate('department_id', 'name code')
				.populate('mentor_id', 'full_name email'),
			InternAssignment.findOne({ intern_id: internId })
				.populate('department_id', 'name code')
				.populate('mentor_id', 'full_name email')
				.sort({ created_at: -1 })
		]);

		if (!intern) return res.status(404).json({ msg: 'Intern not found' });

		const department = assignment?.department_id || intern.department_id || null;

		res.status(200).json({
			msg: 'Fetched successfully',
			work_card: {
				work_id_card: {
					work_id: intern.work_id,
					id_photo_url: intern.id_photo_url || null
				},
				intern_profile: {
					id: intern._id,
					full_name: intern.full_name,
					user_role: intern.user_role,
					department: department
						? {
							name: department.name,
							code: department.code
						}
						: null
				}
			}
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to fetch Work ID', error: err.message });
	}
};

exports.uploadWorkIdPhoto = async (req, res) => {
	try {
		if (!req.file) return res.status(400).json({ msg: 'Image file is required' });
		const internId = req.user?._id;
		if (!internId || !isValidId(internId)) return res.status(401).json({ msg: 'Unauthorized' });

		const intern = await Intern.findById(internId);
		if (!intern) return res.status(404).json({ msg: 'Intern not found' });

		const { secure_url, public_id } = await uploadToCloudinary(
			req.file.buffer,
			'internships-tracker/work-id-photos'
		);

		await deleteFromCloudinary(intern.id_photo_public_id);

		intern.id_photo_url = secure_url;
		intern.id_photo_public_id = public_id;
		await intern.save();

		res.status(200).json({
			msg: 'Work ID photo uploaded successfully',
			id_photo_url: intern.id_photo_url
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to upload Work ID photo', error: err.message });
	}
};


exports.getMyEvaluations = async (req, res) => {
	try {
		const internId = req.user?._id;
		if (!internId || !isValidId(internId)) return res.status(401).json({ msg: 'Unauthorized' });

		const evaluations = await Evaluation.find({ intern_id: internId })
			.populate('mentor_id', 'full_name email')
			.sort({ evaluated_at: -1 });

		const average_mark = evaluations.length
			? Number((evaluations.reduce((sum, item) => sum + item.overall_mark, 0) / evaluations.length).toFixed(2))
			: null;

		res.status(200).json({
			msg: 'Fetched successfully',
			count: evaluations.length,
			average_mark,
			evaluations
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to fetch evaluations', error: err.message });
	}
};
