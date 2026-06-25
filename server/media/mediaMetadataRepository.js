'use strict';

const { randomUUID } = require('crypto');
const { createDatabaseClient } = require('../db/databaseClient');

const ALLOWED_MEDIA_METADATA_SURFACES = Object.freeze([
  'profile_cover',
  'avatar',
  'post',
  'reel',
  'live_replay',
]);

function normalizeText(value) {
  if (typeof value !== 'string') {
    return '';
  }

  return value.trim();
}

function nullable(value) {
  return value && value.length > 0 ? value : null;
}

function normalizeSurface(value) {
  return normalizeText(value).replace(/-/g, '_');
}

function sanitizeMediaMetadataDraft(input = {}) {
  const byteLength = Number(input.byteLength);

  return Object.freeze({
    ownerCid: normalizeText(input.ownerCid),
    surface: normalizeSurface(input.surface),
    storageBucket: normalizeText(input.storageBucket),
    storageObjectKey: normalizeText(input.storageObjectKey),
    mimeType: normalizeText(input.mimeType),
    byteLength: Number.isFinite(byteLength) && byteLength > 0 ? byteLength : 0,
    uploadStatus: normalizeText(input.uploadStatus) || 'uploaded',
  });
}

function validateMediaMetadataDraft(draft) {
  if (!draft.ownerCid) {
    return 'OWNER_CID_REQUIRED';
  }

  if (!ALLOWED_MEDIA_METADATA_SURFACES.includes(draft.surface)) {
    return 'MEDIA_SURFACE_NOT_ALLOWED';
  }

  if (!draft.storageBucket) {
    return 'STORAGE_BUCKET_REQUIRED';
  }

  if (!draft.storageObjectKey) {
    return 'STORAGE_OBJECT_KEY_REQUIRED';
  }

  if (!draft.mimeType) {
    return 'MIME_TYPE_REQUIRED';
  }

  if (!draft.byteLength) {
    return 'BYTE_LENGTH_REQUIRED';
  }

  return null;
}

function mapMediaAssetRow(row) {
  if (!row) {
    return null;
  }

  return Object.freeze({
    id: row.id,
    ownerCid: row.owner_cid,
    surface: row.surface,
    storageBucket: row.storage_bucket,
    storageObjectKey: row.storage_object_key,
    mimeType: row.mime_type,
    byteLength: Number(row.byte_length || 0),
    uploadStatus: row.upload_status || '',
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  });
}

async function createMediaMetadata(draftInput = {}, options = {}) {
  const db = options.db || createDatabaseClient(options.env);
  const draft = sanitizeMediaMetadataDraft(draftInput);
  const validationCode = validateMediaMetadataDraft(draft);

  if (validationCode) {
    return Object.freeze({
      ok: false,
      code: validationCode,
      mediaMetadataCreated: false,
      mediaAsset: null,
      draft,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
      guarded: true,
      secretsExposed: false,
    });
  }

  if (!db.queryEnabled) {
    return Object.freeze({
      ok: false,
      code: db.code || 'MEDIA_METADATA_WRITE_DISABLED',
      mediaMetadataCreated: false,
      mediaAsset: null,
      draft,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
      guarded: true,
      secretsExposed: false,
    });
  }

  const result = await db.query(
    `INSERT INTO cidentia_media_assets (
        id,
        owner_cid,
        surface,
        storage_bucket,
        storage_object_key,
        mime_type,
        byte_length,
        upload_status,
        created_at,
        updated_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now(), now())
      RETURNING id, owner_cid, surface, storage_bucket, storage_object_key, mime_type, byte_length, upload_status, created_at, updated_at`,
    [
      randomUUID(),
      draft.ownerCid,
      draft.surface,
      nullable(draft.storageBucket),
      nullable(draft.storageObjectKey),
      nullable(draft.mimeType),
      draft.byteLength,
      nullable(draft.uploadStatus),
    ],
  );

  return Object.freeze({
    ok: true,
    code: 'MEDIA_METADATA_WRITE_OK',
    mediaMetadataCreated: result.rowCount > 0,
    mediaAsset: mapMediaAssetRow(result.rows[0]),
    draft,
    dbConnected: result.dbConnected,
    queryEnabled: db.queryEnabled,
    guarded: true,
    secretsExposed: false,
  });
}

module.exports = {
  ALLOWED_MEDIA_METADATA_SURFACES,
  sanitizeMediaMetadataDraft,
  validateMediaMetadataDraft,
  mapMediaAssetRow,
  createMediaMetadata,
};
