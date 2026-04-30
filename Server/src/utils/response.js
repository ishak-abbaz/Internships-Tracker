const sendSuccess = (res, { status = 200, msg = 'Success', data = null }) => {
  return res.status(status).json({
    success: true,
    msg,
    data,
  });
};

const sendError = (res, { status = 500, msg = 'Error', data = null }) => {
  return res.status(status).json({
    success: false,
    msg,
    data,
  });
};

module.exports = { sendSuccess, sendError };
