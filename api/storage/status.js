const { sendLocked } = require('../../server/runtime/backendStatusGuard');

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
    '/api/storage/status',
    'OBJECT_STORAGE_WRITE_DISABLED',
    'Object Storage is configured by contract but write access is disabled.',
    {
      bucket: 'cidentia-live-media',
      endpoint: 'fsn1.your-objectstorage.com',
      storageConfigured: true,
      signedUrlGeneration: false,
      uploadCreated: false,
    },
  );
};
