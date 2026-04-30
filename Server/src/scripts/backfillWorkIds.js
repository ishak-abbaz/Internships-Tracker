const mongoose = require('mongoose');
const connectDb = require('../Config/database');
const Intern = require('../Models/internModel');

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

const run = async () => {
  try {
    await connectDb();

    const interns = await Intern.find({ work_id: null })
      .select('_id full_name email work_id')
      .sort({ created_at: 1 });

    if (interns.length === 0) {
      console.log('No interns found with missing work_id.');
      return;
    }

    let assignedCount = 0;

    for (const intern of interns) {
      intern.work_id = await generateNextWorkId();
      await intern.save();
      assignedCount += 1;
      console.log(`Assigned work_id ${intern.work_id} to ${intern._id}`);
    }

    console.log(`Backfill complete. Assigned ${assignedCount} work_id(s).`);
  } catch (err) {
    console.error('Backfill failed:', err.message);
    process.exitCode = 1;
  } finally {
    await mongoose.connection.close();
  }
};

run();
