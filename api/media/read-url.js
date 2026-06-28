const {
  createSignedMediaReadUrl,
} = require('../../server/media/objectStorageReadPresignerClient');
const {
  readMediaAssetForSignedReadUrl,
} = require('../../server/media/mediaMetadataRepository');
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
  const cid = body.ownerCid || req.headers['x-cidentia-cid'] || '';
  const contract = loadCidentiaEnvContract(process.env);

  const assetRead = await readMediaAssetForSignedReadUrl(
    {
      id: body.id || '',
      ownerCid: cid,
    },
    {
      env: process.env,
    },
  );

  if (!assetRead.ok) {
    return res.status(assetRead.code === 'MEDIA_ASSET_NOT_FOUND' ? 404 : 503).json({
      ok: false,
      code: assetRead.code,
      route: '/api/media/read-url',
      ownerCid: cid || null,
      mediaAssetId: body.id || null,
      signedMediaReadUrl: null,
      signedMediaReadUrlCreated: false,
      publicMediaUrl: null,
      publicMediaUrlsCreated: false,
      dbConnected: assetRead.dbConnected === true,
      queryEnabled: assetRead.queryEnabled === true,
      envContractRead: true,
      mediaUrlGenerationLocked: contract.locked.mediaUrlGenerationLocked,
      objectStorageReadLocked: contract.locked.objectStorageReadLocked,
      signedMediaReadUrlLocked: contract.locked.signedMediaReadUrlLocked,
      storageBucketExposed: false,
      storageObjectKeyExposed: false,
      uploadPresignerTouched: false,
      flutterOpened: false,
      secretsExposed: false,
    });
  }

  const result = await createSignedMediaReadUrl({
    mediaAsset: assetRead.mediaAsset,
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
    storageBucketExposed: false,
    storageObjectKeyExposed: false,
    uploadPresignerTouched: false,
    flutterOpened: false,
  });
};
