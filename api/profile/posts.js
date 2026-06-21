const { mediaBridgeGuard, sendJson } = require('../../server/media/mediaBridgeGuard');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use GET.',
      liveUpload: false,
      storageWrite: false,
      postCreated: false,
    });
  }

  return sendJson(res, {
    ...mediaBridgeGuard(),
    route: '/api/profile/posts',
    items: [],
    nextCursor: null,
  });
};
