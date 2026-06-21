const { sendLocked } = require('../../../server/runtime/backendStatusGuard');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use GET.',
    });
  }

  return sendLocked(
    res,
    '/api/cidendb/session/status',
    'CIDENDB_SESSION_SERVICE_DISABLED',
    'CidenDB session status route is present but live session service is disabled.',
    {
      sessionCreated: false,
      verifiedCid: false,
      frontendTokenExposed: false,
    },
  );
};
