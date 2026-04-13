const Department = require('../Models/departmentModel');
const mongoose = require('mongoose');

exports.createDepartment = async (req, res) => {
	try {
		const { name, code, description } = req.body;

		if (!name || !code) {
			return res.status(400).json({ msg: 'Department name and code are required' });
		}

		const normalizedName = name.trim();
		const normalizedCode = code.trim().toUpperCase();

		const existingDepartment = await Department.findOne({
			$or: [{ name: normalizedName }, { code: normalizedCode }]
		});

		if (existingDepartment) {
			return res.status(400).json({ msg: 'Department name or code already exists' });
		}

		const department = await Department.create({
			name: normalizedName,
			code: normalizedCode,
			description: description ?? null
		});

		res.status(201).json({
			msg: 'Department created successfully',
			department
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to create department', error: err.message });
	}
};

exports.getAllDepartments = async (req, res) => {
	try {
		const departments = await Department.find().sort({ name: 1 });

		res.status(200).json({
			msg: 'Departments fetched successfully',
			count: departments.length,
			departments
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to fetch departments', error: err.message });
	}
};

exports.getDepartmentById = async (req, res) => {
	try {
		const { id } = req.params;

		if (!mongoose.Types.ObjectId.isValid(id)) {
			return res.status(400).json({ msg: 'Invalid department id' });
		}

		const department = await Department.findById(id);
		if (!department) {
			return res.status(404).json({ msg: 'Department not found' });
		}

		res.status(200).json({
			msg: 'Department fetched successfully',
			department
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to fetch department', error: err.message });
	}
};

exports.updateDepartment = async (req, res) => {
	try {
		const { id } = req.params;
		const { name, description } = req.body;

		if (!mongoose.Types.ObjectId.isValid(id)) {
			return res.status(400).json({ msg: 'Invalid department id' });
		}

		if (name === undefined && description === undefined) {
			return res.status(400).json({ msg: 'Provide at least name or description to update' });
		}

		const department = await Department.findById(id);
		if (!department) {
			return res.status(404).json({ msg: 'Department not found' });
		}

		if (name !== undefined) {
			department.name = name.trim();
		}

		if (description !== undefined) {
			department.description = description;
		}

		await department.save();

		res.status(200).json({
			msg: 'Department updated successfully',
			department
		});
	} catch (err) {
		if (err.code === 11000) {
			return res.status(400).json({ msg: 'Department name already exists' });
		}

		res.status(500).json({ msg: 'Failed to update department', error: err.message });
	}
};

exports.deleteDepartment = async (req, res) => {
	try {
		const { id } = req.params;

		if (!mongoose.Types.ObjectId.isValid(id)) {
			return res.status(400).json({ msg: 'Invalid department id' });
		}

		const deletedDepartment = await Department.findByIdAndDelete(id);
		if (!deletedDepartment) {
			return res.status(404).json({ msg: 'Department not found' });
		}

		res.status(200).json({
			msg: 'Department deleted successfully',
			department: deletedDepartment
		});
	} catch (err) {
		res.status(500).json({ msg: 'Failed to delete department', error: err.message });
	}
};






















