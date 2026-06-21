const { mediaBridgeGuard, sendJson } = require('../../server/media/mediaBridgeGuard');

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
      liveUpload: false,
      storageWrite: false,
      postCreated: false,
    });
  }

  return sendJson(res, {
    ...mediaBridgeGuard(),
    route: '/api/media/upload',
  });
};
