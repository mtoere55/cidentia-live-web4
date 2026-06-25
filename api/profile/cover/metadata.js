const {
  cidFromProfileRequest,
  profileCidRequiredBoundary,
} = require('../../../server/profile/profileBoundary');
const {
  createMediaMetadata,
  sanitizeMediaMetadataDraft,
} = require('../../../server/media/mediaMetadataRepository');

function envTrue(env, key) {
  return env[key] === 'true' || env[key] === '1';
}

async function readJsonBody(req) {
  if (req.body && typeof req.body === 'object') {
    return req.body;
  }

  return new Promise((resolve) => {
    let raw = '';

    req.on('data', (chunk) => {
      raw += chunk;
    });

    req.on('end', () => {
      if (!raw) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(raw));
      } catch (_) {
        resolve({});
      }
    });

    req.on('error', () => {
      resolve({});
    });
  });
}

function mediaMetadataWriteDisabledBoundary(route, ownerCid, draft = {}) {
  return Object.freeze({
    ok: false,
    route,
    code: 'MEDIA_METADATA_WRITE_DISABLED',
    message:
      'Profile cover metadata write is disabled until the persistence contract is explicitly opened.',
    ownerCid,
    mediaMetadataCreated: false,
    profileUpdated: false,
    uploadCreated: false,
    signedUploadUrlCreated: false,
    objectStorageWrite: false,
    dbConnected: false,
    queryEnabled: false,
    guarded: true,
    readOnly: true,
    secretsExposed: false,
    draft,
  });
}

module.exports = async function handler(req, res) {
  const route = '/api/profile/cover/metadata';

  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
    });
  }

  const body = await readJsonBody(req);
  const ownerCid = cidFromProfileRequest(req, body);

  if (!ownerCid) {
    return res.status(401).json(profileCidRequiredBoundary(route));
  }

  const draft = sanitizeMediaMetadataDraft({
    ownerCid,
    surface: body.surface || 'profile-cover',
    storageBucket: body.storageBucket,
    storageObjectKey: body.storageObjectKey,
    mimeType: body.mimeType,
    byteLength: body.byteLength,
    uploadStatus: body.uploadStatus || 'uploaded',
  });

  if (!envTrue(process.env, 'CIDENTIA_MEDIA_METADATA_WRITE_ENABLED')) {
    return res
      .status(503)
      .json(mediaMetadataWriteDisabledBoundary(route, ownerCid, draft));
  }

  const result = await createMediaMetadata(draft);

  if (!result.ok) {
    return res.status(503).json({
      ...mediaMetadataWriteDisabledBoundary(route, ownerCid, draft),
      repositoryCode: result.code,
      dbConnected: result.dbConnected,
      queryEnabled: result.queryEnabled,
    });
  }

  return res.status(200).json({
    ...result,
    route,
    ownerCid,
    profileUpdated: false,
    guarded: true,
    readOnly: false,
  });
};
