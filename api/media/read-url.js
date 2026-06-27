const {
  evaluateSignedMediaReadUrlPolicy,
} = require('../../server/media/objectStorageReadPresignerClient');

function methodNotAllowed(res) {
  return res.status(405).json({
    ok: false,
    code: 'METHOD_NOT_ALLOWED',
    message: 'Use POST.',
  });
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return methodNotAllowed(res);
  }

  const body = req.body || {};

  const result = evaluateSignedMediaReadUrlPolicy({
    mediaAsset: {
      id: body.id || 'read-signed-url-disabled-check',
      ownerCid: body.ownerCid || req.headers['x-cidentia-cid'] || '',
      surface: body.surface || 'profile_cover',
      storageBucket: body.storageBucket || 'private-bucket',
      storageObjectKey: body.storageObjectKey || 'disabled/read-object.png',
      visibility: body.visibility || 'public',
      moderationStatus: body.moderationStatus || 'approved',
    },
  });

  return res.status(503).json({
    ...result,
    route: '/api/media/read-url',
    objectStorageCalled: false,
    uploadPresignerTouched: false,
    flutterOpened: false,
  });
};
