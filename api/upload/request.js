const { sendLocked } = require('../../server/runtime/backendStatusGuard');

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
    });
  }

  return sendLocked(
    res,
    '/api/upload/request',
    'UPLOAD_ROUTE_DISABLED',
    'Upload permission route is disabled until the media contract is implemented.',
    {
      uploadCreated: false,
      signedUploadUrlCreated: false,
      mediaMetadataCreated: false,
    },
  );
};
