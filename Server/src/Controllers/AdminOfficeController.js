const mongoose = require('mongoose');
const { Readable } = require('stream');
const cloudinary = require('../Config/cloudinary');
const Policy   = require('../Models/policyModel');
const Schedule = require('../Models/scheduleModel');
const Department = require('../Models/departmentModel');

// ─── Helpers ────────────────────────────────────────────────────────────────

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

/** Upload a PDF buffer to Cloudinary and return { secure_url, public_id } */
const uploadToCloudinary = (buffer, folder) =>
  new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { resource_type: 'raw', folder, format: 'pdf' },
      (err, result) => (err ? reject(err) : resolve(result))
    );
    Readable.from(buffer).pipe(stream);
  });

/** Delete a file from Cloudinary (silently ignores errors) */
const deleteFromCloudinary = async (publicId) => {
  if (!publicId) return;
  try {
    await cloudinary.uploader.destroy(publicId, { resource_type: 'raw' });
  } catch (_) { /* ignore */ }
};

// ─── Policy Handbooks ────────────────────────────────────────────────────────

exports.createPolicyHandbook = async (req, res) => {
  try {
    const { title, description, department_code, target_role, version } = req.body;

    if (!title)     return res.status(400).json({ msg: 'Title is required' });
    if (!req.file)  return res.status(400).json({ msg: 'PDF file is required' });

    let department_id = null;
    if (department_code) {
      const department = await Department.findOne({ code: department_code.trim().toUpperCase() });
      if (!department)
        return res.status(400).json({ msg: 'Department code not found' });
      department_id = department._id;
    }

    const { secure_url, public_id } = await uploadToCloudinary(
      req.file.buffer,
      'internships-tracker/policies'
    );

    const policy = await Policy.create({
      title: title.trim(),
      description:   description   ?? null,
      department_id: department_id,
      department_code: department_code ? department_code.trim().toUpperCase() : null,
      target_role:   target_role   || 'All',
      version:       version       || 1,
      file_url:       secure_url,
      file_public_id: public_id,
    });

    res.status(201).json({ msg: 'Policy handbook uploaded successfully', policy });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to upload policy handbook', error: err.message });
  }
};

exports.getAllPolicyHandbooks = async (_req, res) => {
  try {
    const policies = await Policy.find().sort({ created_at: -1 });
    res.status(200).json({ msg: 'Fetched successfully', count: policies.length, policies });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch policies', error: err.message });
  }
};

exports.getPolicyHandbookById = async (req, res) => {
  try {
    const { id } = req.params;
    if (!isValidId(id)) return res.status(400).json({ msg: 'Invalid policy id' });

    const policy = await Policy.findById(id);
    if (!policy) return res.status(404).json({ msg: 'Policy not found' });

    res.status(200).json({ msg: 'Fetched successfully', policy });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch policy', error: err.message });
  }
};

exports.updatePolicyHandbook = async (req, res) => {
  try {
    const { id } = req.params;
    if (!isValidId(id)) return res.status(400).json({ msg: 'Invalid policy id' });

    const { title, description, department_code, target_role, version } = req.body;
    const hasChanges = title || description || department_code || target_role || version || req.file;
    if (!hasChanges) return res.status(400).json({ msg: 'Provide at least one field to update' });

    let department_id = null;
    if (department_code) {
      const department = await Department.findOne({ code: department_code.trim().toUpperCase() });
      if (!department)
        return res.status(400).json({ msg: 'Department code not found' });
      department_id = department._id;
    }

    const policy = await Policy.findById(id);
    if (!policy) return res.status(404).json({ msg: 'Policy not found' });

    if (title       !== undefined) policy.title       = title.trim();
    if (description !== undefined) policy.description = description;
    if (department_code !== undefined) {
      policy.department_id = department_id;
      policy.department_code = department_code ? department_code.trim().toUpperCase() : null;
    }
    if (target_role !== undefined) policy.target_role = target_role;
    if (version     !== undefined) policy.version     = version;

    if (req.file) {
      const { secure_url, public_id } = await uploadToCloudinary(
        req.file.buffer,
        'internships-tracker/policies'
      );
      await deleteFromCloudinary(policy.file_public_id);
      policy.file_url       = secure_url;
      policy.file_public_id = public_id;
    }

    await policy.save();
    res.status(200).json({ msg: 'Policy updated successfully', policy });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to update policy', error: err.message });
  }
};

exports.deletePolicyHandbook = async (req, res) => {
  try {
    const { id } = req.params;
    if (!isValidId(id)) return res.status(400).json({ msg: 'Invalid policy id' });

    const policy = await Policy.findByIdAndDelete(id);
    if (!policy) return res.status(404).json({ msg: 'Policy not found' });

    await deleteFromCloudinary(policy.file_public_id);
    res.status(200).json({ msg: 'Policy deleted successfully', policy });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to delete policy', error: err.message });
  }
};

// ─── Office Schedules ────────────────────────────────────────────────────────

exports.createOfficeSchedule = async (req, res) => {
  try {
    const { title, description, department_code, version } = req.body;

    if (!title)
      return res.status(400).json({ msg: 'Title is required' });
    if (!req.file)
      return res.status(400).json({ msg: 'PDF file is required' });

    let department_id = null;
    if (department_code) {
      const department = await Department.findOne({ code: department_code.trim().toUpperCase() });
      if (!department)
        return res.status(400).json({ msg: 'Department code not found' });
      department_id = department._id;
    }

    const { secure_url, public_id } = await uploadToCloudinary(
      req.file.buffer,
      'internships-tracker/schedules'
    );

    const schedule = await Schedule.create({
      title: title.trim(),
      description: description ?? null,
      department_id: department_id,
      department_code: department_code ? department_code.trim().toUpperCase() : null,
      version: version || 1,
      file_url:       secure_url,
      file_public_id: public_id,
      uploaded_by_admin_id: req.user._id,
    });

    res.status(201).json({ msg: 'Office schedule uploaded successfully', schedule });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to upload schedule', error: err.message });
  }
};

exports.getAllOfficeSchedules = async (_req, res) => {
  try {
    const schedules = await Schedule.find().sort({ created_at: -1 });
    res.status(200).json({ msg: 'Fetched successfully', count: schedules.length, schedules });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch schedules', error: err.message });
  }
};

exports.getOfficeScheduleById = async (req, res) => {
  try {
    const { id } = req.params;
    if (!isValidId(id)) return res.status(400).json({ msg: 'Invalid schedule id' });

    const schedule = await Schedule.findById(id);
    if (!schedule) return res.status(404).json({ msg: 'Schedule not found' });

    res.status(200).json({ msg: 'Fetched successfully', schedule });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch schedule', error: err.message });
  }
};

exports.updateOfficeSchedule = async (req, res) => {
  try {
    const { id } = req.params;
    if (!isValidId(id)) return res.status(400).json({ msg: 'Invalid schedule id' });

    const { title, description, department_code, version } = req.body;

    const hasChanges = title || description || department_code || version || req.file;
    if (!hasChanges) return res.status(400).json({ msg: 'Provide at least one field to update' });

    let department_id = null;
    if (department_code) {
      const department = await Department.findOne({ code: department_code.trim().toUpperCase() });
      if (!department)
        return res.status(400).json({ msg: 'Department code not found' });
      department_id = department._id;
    }

    const schedule = await Schedule.findById(id);
    if (!schedule) return res.status(404).json({ msg: 'Schedule not found' });

    if (title !== undefined) schedule.title = title.trim();
    if (description !== undefined) schedule.description = description;
    if (department_code !== undefined) {
      schedule.department_id = department_id;
      schedule.department_code = department_code ? department_code.trim().toUpperCase() : null;
    }
    if (version !== undefined) schedule.version = version;

    if (req.file) {
      const { secure_url, public_id } = await uploadToCloudinary(
        req.file.buffer,
        'internships-tracker/schedules'
      );
      await deleteFromCloudinary(schedule.file_public_id);
      schedule.file_url       = secure_url;
      schedule.file_public_id = public_id;
    }

    await schedule.save();
    res.status(200).json({ msg: 'Schedule updated successfully', schedule });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to update schedule', error: err.message });
  }
};

exports.deleteOfficeSchedule = async (req, res) => {
  try {
    const { id } = req.params;
    if (!isValidId(id)) return res.status(400).json({ msg: 'Invalid schedule id' });

    const schedule = await Schedule.findByIdAndDelete(id);
    if (!schedule) return res.status(404).json({ msg: 'Schedule not found' });

    await deleteFromCloudinary(schedule.file_public_id);
    res.status(200).json({ msg: 'Schedule deleted successfully', schedule });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to delete schedule', error: err.message });
  }
};