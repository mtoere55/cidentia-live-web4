const {
  createSignedMediaReadUrl,
} = require('../../server/media/objectStorageReadPresignerClient');
const {
  loadCidentiaEnvContract,
} = require('../../server/runtime/envContract');

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
  const contract = loadCidentiaEnvContract(process.env);

  const result = await createSignedMediaReadUrl({
    mediaAsset: {
      id: body.id || 'read-signed-url-check',
      ownerCid: body.ownerCid || req.headers['x-cidentia-cid'] || '',
      surface: body.surface || 'profile_cover',
      storageBucket: body.storageBucket || '',
      storageObjectKey: body.storageObjectKey || '',
      mimeType: body.mimeType || '',
      visibility: body.visibility || 'private',
      moderationStatus: body.moderationStatus || 'pending',
    },
    env: process.env,
  });

  const statusCode = result.ok ? 200 : 503;

  return res.status(statusCode).json({
    ...result,
    route: '/api/media/read-url',
    envContractRead: true,
    mediaUrlGenerationLocked: contract.locked.mediaUrlGenerationLocked,
    objectStorageReadLocked: contract.locked.objectStorageReadLocked,
    signedMediaReadUrlLocked: contract.locked.signedMediaReadUrlLocked,
    uploadPresignerTouched: false,
    flutterOpened: false,
  });
};
