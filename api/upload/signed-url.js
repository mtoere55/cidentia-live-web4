const {
  signedUploadUrlDisabledBoundary,
} = require('../../server/media/signedUploadUrlBoundary');

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
    });
  }

  return res.status(503).json({
    ...signedUploadUrlDisabledBoundary(),
    route: '/api/upload/signed-url',
    message:
      'Signed upload URL creation is disabled until Object Storage and upload gates are enabled.',
    guarded: true,
    readOnly: true,
  });
};
