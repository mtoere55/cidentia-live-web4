const {
  cidFromProfileRequest,
  profileCidRequiredBoundary,
  profileReadDisabledBoundary,
} = require('../../server/profile/profileBoundary');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use GET.',
    });
  }

  const cid = cidFromProfileRequest(req);

  if (!cid) {
    return res.status(401).json(
      profileCidRequiredBoundary('/api/profile/me'),
    );
  }

  return res.status(503).json(
    profileReadDisabledBoundary('/api/profile/me', cid),
  );
};
