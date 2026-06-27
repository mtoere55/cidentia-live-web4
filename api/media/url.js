const {
  evaluateMediaUrlPolicy,
} = require('../../server/media/mediaUrlPolicy');

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

  const result = evaluateMediaUrlPolicy({
    mediaAsset: {
      id: req.body?.id || 'media-url-disabled-check',
      ownerCid: req.body?.ownerCid || req.headers['x-cidentia-cid'] || '',
      surface: req.body?.surface || 'profile_cover',
      storageBucket: req.body?.storageBucket || 'private-bucket',
      storageObjectKey: req.body?.storageObjectKey || 'disabled/object.png',
      visibility: req.body?.visibility || 'public',
      moderationStatus: req.body?.moderationStatus || 'approved',
    },
  });

  return res.status(503).json({
    ...result,
    route: '/api/media/url',
    storageSignedUrlCreated: false,
    publicMediaUrlsCreated: false,
    objectStorageCalled: false,
    flutterOpened: false,
  });
};
