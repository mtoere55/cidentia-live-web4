const { liveBridgeGuard, sendJson } = require('../../../server/live/liveBridgeGuard');

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
      recordingFileCreated: false,
      replayCreated: false,
    });
  }

  return sendJson(res, {
    ...liveBridgeGuard(),
    route: '/api/live/replay/create',
  });
};
