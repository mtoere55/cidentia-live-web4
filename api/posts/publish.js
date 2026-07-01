const { randomUUID } = require('crypto');
const { createDatabaseClient } = require('../../server/db/databaseClient');
const {
  createMediaMetadata,
} = require('../../server/media/mediaMetadataRepository');

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

function normalizeText(value) {
  if (typeof value !== 'string') {
    return '';
  }

  return value.trim();
}

function normalizeCid(req, body) {
  return (
    normalizeText(req.headers['x-cidentia-cid']) ||
    normalizeText(req.headers['x-cid']) ||
    normalizeText(body.ownerCid) ||
    normalizeText(body.cid)
  );
}

function normalizeMode(value) {
  const mode = normalizeText(value).toLowerCase();

  if (mode === 'reel' || mode === 'reels') {
    return 'reel';
  }

  if (mode === 'replay' || mode === 'live_replay') {
    return 'live_replay';
  }

  return 'post';
}

function surfaceForMode(mode) {
  if (mode === 'reel') {
    return 'reel';
  }

  if (mode === 'live_replay') {
    return 'live_replay';
  }

  return 'post';
}

function tableForMode(mode) {
  if (mode === 'reel') {
    return 'cidentia_reels';
  }

  return 'cidentia_posts';
}

function validatePublishRequest({ ownerCid, body, storageBucket }) {
  const storageObjectKey = normalizeText(body.storageObjectKey);
  const mimeType = normalizeText(body.mimeType);
  const byteLength = Number(body.byteLength);

  if (!ownerCid) {
    return 'CID_REQUIRED_FOR_POST_PUBLISH';
  }

  if (!storageBucket) {
    return 'STORAGE_BUCKET_REQUIRED_FOR_POST_PUBLISH';
  }

  if (!storageObjectKey) {
    return 'STORAGE_OBJECT_KEY_REQUIRED_FOR_POST_PUBLISH';
  }

  if (!mimeType) {
    return 'MIME_TYPE_REQUIRED_FOR_POST_PUBLISH';
  }

  if (!Number.isFinite(byteLength) || byteLength <= 0) {
    return 'BYTE_LENGTH_REQUIRED_FOR_POST_PUBLISH';
  }

  if (!storageObjectKey.includes(`uploads/${ownerCid}/`)) {
    return 'STORAGE_OBJECT_KEY_OWNER_MISMATCH';
  }

  return null;
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
      mediaMetadataCreated: false,
      postCreated: false,
      reelCreated: false,
      secretsExposed: false,
    });
  }

  const body = await readJsonBody(req);
  const ownerCid = normalizeCid(req, body);
  const mode = normalizeMode(body.mode || body.postType || body.surface);
  const surface = surfaceForMode(mode);
  const storageBucket =
    normalizeText(body.storageBucket) ||
    normalizeText(process.env.CIDENTIA_OBJECT_STORAGE_BUCKET);
  const storageObjectKey = normalizeText(body.storageObjectKey);
  const mimeType = normalizeText(body.mimeType);
  const byteLength = Number(body.byteLength);
  const caption = normalizeText(body.caption);

  const validationCode = validatePublishRequest({
    ownerCid,
    body,
    storageBucket,
  });

  if (validationCode) {
    return res.status(400).json({
      ok: false,
      route: '/api/posts/publish',
      code: validationCode,
      mediaMetadataCreated: false,
      postCreated: false,
      reelCreated: false,
      cidRequired: true,
      cidVerified: Boolean(ownerCid),
      storageBucketExposed: false,
      storageObjectKeyExposed: false,
      secretsExposed: false,
    });
  }

  const db = createDatabaseClient(process.env);

  if (!db.queryEnabled) {
    return res.status(503).json({
      ok: false,
      route: '/api/posts/publish',
      code: db.code || 'DATABASE_QUERY_DISABLED',
      mediaMetadataCreated: false,
      postCreated: false,
      reelCreated: false,
      dbConnected: db.dbConnected === true,
      queryEnabled: db.queryEnabled === true,
      storageBucketExposed: false,
      storageObjectKeyExposed: false,
      secretsExposed: false,
    });
  }

  try {
    const mediaResult = await createMediaMetadata(
      {
        ownerCid,
        surface,
        storageBucket,
        storageObjectKey,
        mimeType,
        byteLength,
        uploadStatus: 'uploaded',
      },
      { db },
    );

    if (!mediaResult.ok || !mediaResult.mediaAsset) {
      return res.status(400).json({
        ok: false,
        route: '/api/posts/publish',
        code: mediaResult.code || 'MEDIA_METADATA_CREATE_FAILED',
        mediaMetadataCreated: false,
        postCreated: false,
        reelCreated: false,
        dbConnected: mediaResult.dbConnected === true,
        queryEnabled: mediaResult.queryEnabled === true,
        storageBucketExposed: false,
        storageObjectKeyExposed: false,
        secretsExposed: false,
      });
    }

    const socialId = randomUUID();
    const table = tableForMode(mode);

    const insertResult =
      table === 'cidentia_reels'
        ? await db.query(
            `INSERT INTO cidentia_reels (
                id,
                owner_cid,
                media_id,
                caption,
                visibility,
                created_at
              )
              VALUES ($1, $2, $3, $4, 'public', now())
              RETURNING id, owner_cid, media_id, caption, visibility, created_at`,
            [socialId, ownerCid, mediaResult.mediaAsset.id, caption || null],
          )
        : await db.query(
            `INSERT INTO cidentia_posts (
                id,
                owner_cid,
                media_id,
                caption,
                visibility,
                created_at,
                updated_at
              )
              VALUES ($1, $2, $3, $4, 'public', now(), now())
              RETURNING id, owner_cid, media_id, caption, visibility, created_at, updated_at`,
            [socialId, ownerCid, mediaResult.mediaAsset.id, caption || null],
          );

    const socialRow = insertResult.rows[0];

    return res.status(200).json({
      ok: true,
      route: '/api/posts/publish',
      code: mode === 'reel' ? 'REEL_PUBLISH_OK' : 'POST_PUBLISH_OK',
      ownerCid,
      mode,
      mediaMetadataCreated: true,
      postCreated: mode !== 'reel',
      reelCreated: mode === 'reel',
      mediaAssetId: mediaResult.mediaAsset.id,
      postId: mode !== 'reel' ? socialRow.id : null,
      reelId: mode === 'reel' ? socialRow.id : null,
      publishStatus: 'published',
      dbConnected: true,
      queryEnabled: true,
      storageBucketExposed: false,
      storageObjectKeyExposed: false,
      secretsExposed: false,
    });
  } catch (error) {
    return res.status(503).json({
      ok: false,
      route: '/api/posts/publish',
      code: 'POST_PUBLISH_FAILED_SAFE',
      message: error && error.message ? error.message : 'Publish failed safely.',
      mediaMetadataCreated: false,
      postCreated: false,
      reelCreated: false,
      storageBucketExposed: false,
      storageObjectKeyExposed: false,
      secretsExposed: false,
    });
  }
};
