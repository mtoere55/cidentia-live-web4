const {
  mediaMetadataDisabledSchema,
} = require('../../server/media/mediaMetadataSchema');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use GET.',
    });
  }

  return res.status(503).json({
    ...mediaMetadataDisabledSchema(),
    route: '/api/media/metadata-schema',
    message:
      'Media metadata schema is defined, but metadata writes remain disabled.',
    uploadCreated: false,
    signedUploadUrlCreated: false,
    mediaMetadataCreated: false,
    objectStorageWrite: false,
    guarded: true,
    readOnly: true,
  });
};
