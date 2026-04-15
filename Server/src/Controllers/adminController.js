const User = require('../Models/userModel');
const Intern = require('../Models/internModel');
const mongoose = require('mongoose');

const generateNextWorkId = async () => {
  const START_WORK_ID = 100001;

  const lastInternWithWorkId = await Intern.findOne({ work_id: { $ne: null } })
    .sort({ work_id: -1 })
    .select('work_id');

  let candidate = lastInternWithWorkId?.work_id
    ? Number(lastInternWithWorkId.work_id) + 1
    : START_WORK_ID;

  while (await Intern.exists({ work_id: candidate })) {
    candidate += 1;
  }

  return candidate;
};

exports.listPendingRegistrations = async (req, res) => {
  try {
    const pendingUsers = await User.find({
      account_status: 'pending',
      user_role: { $in: ['Student', 'Mentor'] }
    })
      .select('-password -reset_Password_Token -reset_Password_expires_at')
      .sort({ created_at: 1 });

    res.status(200).json({
      msg: 'Pending registrations fetched successfully',
      count: pendingUsers.length,
      users: pendingUsers
    });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch pending registrations', error: err.message });
  }
};

exports.getRegistrationById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ msg: 'Invalid user id' });
    }

    const user = await User.findById(id).select('-password -reset_Password_Token -reset_Password_expires_at');
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    res.status(200).json({
      msg: 'User fetched successfully',
      user
    });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch user', error: err.message });
  }
};

exports.approveRegistration = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ msg: 'Invalid user id' });
    }

    let user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    if (user.account_status !== 'pending') {
      return res.status(400).json({ msg: `Cannot approve a ${user.account_status} account` });
    }

    if (user.user_role === 'Student') {
      const intern = await Intern.findById(id);
      if (!intern) {
        return res.status(404).json({ msg: 'Intern profile not found' });
      }

      intern.account_status = 'approved';
      intern.account_reviewed_at = new Date();
      intern.account_reviewed_by = req.user._id;
      intern.is_email_verified = true;
      intern.is_validated_by_admin = true;

      if (!intern.work_id) {
        intern.work_id = await generateNextWorkId();
      }

      await intern.save();
      user = intern;
    } else {
      user.account_status = 'approved';
      user.account_reviewed_at = new Date();
      user.account_reviewed_by = req.user._id;
      user.is_email_verified = true;
      await user.save();
    }

    res.status(200).json({
      msg: 'Account approved successfully',
      user: {
        id: user._id,
        full_name: user.full_name,
        email: user.email,
        user_role: user.user_role,
        account_status: user.account_status,
        account_reviewed_at: user.account_reviewed_at,
        account_reviewed_by: user.account_reviewed_by,
        work_id: user.user_role === 'Student' ? user.work_id : null
      }
    });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to approve account', error: err.message });
  }
};

exports.declineRegistration = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ msg: 'Invalid user id' });
    }

    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    if (user.account_status !== 'pending') {
      return res.status(400).json({ msg: `Cannot decline a ${user.account_status} account` });
    }

    user.account_status = 'declined';
    user.account_reviewed_at = new Date();
    user.account_reviewed_by = req.user._id;
    await user.save();

    res.status(200).json({
      msg: 'Account declined successfully',
      user: {
        id: user._id,
        full_name: user.full_name,
        email: user.email,
        user_role: user.user_role,
        account_status: user.account_status,
        account_reviewed_at: user.account_reviewed_at,
        account_reviewed_by: user.account_reviewed_by
      }
    });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to decline account', error: err.message });
  }
};

