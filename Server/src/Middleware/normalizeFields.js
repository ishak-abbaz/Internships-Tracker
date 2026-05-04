// Normalize multipart form field names to lowercase (non-destructive)
module.exports = (req, _res, next) => {
  if (req.body && typeof req.body === 'object') {
    const keys = Object.keys(req.body);
    for (const k of keys) {
      const lower = k.toLowerCase();
      if (!(lower in req.body)) req.body[lower] = req.body[k];
    }
  }
  next();
};
