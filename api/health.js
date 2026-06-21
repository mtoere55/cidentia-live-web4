const { sendStatus } = require('../server/runtime/backendStatusGuard');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use GET.',
    });
  }

  return sendStatus(res, {
    route: '/api/health',
  });
};
