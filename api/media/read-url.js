const {
  evaluateSignedMediaReadUrlPolicy,
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

  const result = evaluateSignedMediaReadUrlPolicy(
    {
      mediaAsset: {
        id: body.id || 'read-signed-url-disabled-check',
        ownerCid: body.ownerCid || req.headers['x-cidentia-cid'] || '',
        surface: body.surface || 'profile_cover',
        storageBucket: body.storageBucket || 'private-bucket',
        storageObjectKey: body.storageObjectKey || 'disabled/read-object.png',
        visibility: body.visibility || 'public',
        moderationStatus: body.moderationStatus || 'approved',
      },
    },
    {
      policy: {
        mediaUrlGenerationEnabled:
          contract.gates.CIDENTIA_MEDIA_URL_GENERATION_ENABLED,
        objectStorageReadEnabled:
          contract.gates.CIDENTIA_OBJECT_STORAGE_READ_ENABLED,
        signedMediaReadUrlEnabled:
          contract.gates.CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED,
      },
    },
  );

  return res.status(503).json({
    ...result,
    route: '/api/media/read-url',
    envContractRead: true,
    mediaUrlGenerationLocked: contract.locked.mediaUrlGenerationLocked,
    objectStorageReadLocked: contract.locked.objectStorageReadLocked,
    signedMediaReadUrlLocked: contract.locked.signedMediaReadUrlLocked,
    objectStorageCalled: false,
    uploadPresignerTouched: false,
    flutterOpened: false,
  });
};
