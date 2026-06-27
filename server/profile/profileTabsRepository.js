'use strict';

const { createDatabaseClient } = require('../db/databaseClient');

function normalizeCid(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const cid = value.trim();

  if (cid.length < 3) {
    return null;
  }

  return cid;
}

function disabledTabsResult(code, ownerCid, tab, db = {}) {
  return Object.freeze({
    ok: false,
    code,
    ownerCid,
    tab,
    itemsRead: false,
    items: Object.freeze([]),
    dbConnected: db.dbConnected === true,
    queryEnabled: db.queryEnabled === true,
    secretsExposed: false,
  });
}

function normalizeLimit(value) {
  const parsed = Number(value);

  if (!Number.isFinite(parsed)) {
    return 20;
  }

  return Math.max(1, Math.min(50, Math.trunc(parsed)));
}

function mapPostRow(row) {
  return Object.freeze({
    id: row.id,
    ownerCid: row.owner_cid,
    mediaId: row.media_id || null,
    caption: row.caption || '',
    visibility: row.visibility,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    publicMediaUrl: null,
  });
}

function mapReelRow(row) {
  return Object.freeze({
    id: row.id,
    ownerCid: row.owner_cid,
    mediaId: row.media_id || null,
    caption: row.caption || '',
    visibility: row.visibility,
    createdAt: row.created_at,
    publicMediaUrl: null,
  });
}

function mapMediaRow(row) {
  return Object.freeze({
    id: row.id,
    ownerCid: row.owner_cid,
    ownerDisplayNameSnapshot: row.owner_display_name_snapshot || '',
    mediaSurface: row.media_surface,
    mimeType: row.mime_type,
    byteSize: Number(row.byte_size || 0),
    storageBucket: row.storage_bucket,
    storageObjectKey: row.storage_object_key,
    visibility: row.visibility,
    moderationStatus: row.moderation_status,
    uploadSource: row.upload_source,
    createdAt: row.created_at,
    publicMediaUrl: null,
  });
}

async function readProfilePostsByCid(ownerCid, options = {}) {
  const cid = normalizeCid(ownerCid);

  if (!cid) {
    return disabledTabsResult('PROFILE_CID_REQUIRED', null, 'posts');
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return disabledTabsResult(db.code || 'PROFILE_TABS_DISABLED', cid, 'posts', db);
  }

  const limit = normalizeLimit(options.limit);
  const result = await db.query(
    `SELECT id, owner_cid, media_id, caption, visibility, created_at, updated_at
       FROM cidentia_posts
      WHERE owner_cid = $1
      ORDER BY created_at DESC
      LIMIT $2`,
    [cid, limit],
  );

  return Object.freeze({
    ok: true,
    code: 'PROFILE_POSTS_READ_OK',
    ownerCid: cid,
    tab: 'posts',
    itemsRead: true,
    items: Object.freeze(result.rows.map(mapPostRow)),
    dbConnected: result.dbConnected === true,
    queryEnabled: db.queryEnabled === true,
    secretsExposed: false,
  });
}

async function readProfileReelsByCid(ownerCid, options = {}) {
  const cid = normalizeCid(ownerCid);

  if (!cid) {
    return disabledTabsResult('PROFILE_CID_REQUIRED', null, 'reels');
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return disabledTabsResult(db.code || 'PROFILE_TABS_DISABLED', cid, 'reels', db);
  }

  const limit = normalizeLimit(options.limit);
  const result = await db.query(
    `SELECT id, owner_cid, media_id, caption, visibility, created_at
       FROM cidentia_reels
      WHERE owner_cid = $1
      ORDER BY created_at DESC
      LIMIT $2`,
    [cid, limit],
  );

  return Object.freeze({
    ok: true,
    code: 'PROFILE_REELS_READ_OK',
    ownerCid: cid,
    tab: 'reels',
    itemsRead: true,
    items: Object.freeze(result.rows.map(mapReelRow)),
    dbConnected: result.dbConnected === true,
    queryEnabled: db.queryEnabled === true,
    secretsExposed: false,
  });
}

async function readProfileMediaByCid(ownerCid, options = {}) {
  const cid = normalizeCid(ownerCid);

  if (!cid) {
    return disabledTabsResult('PROFILE_CID_REQUIRED', null, 'media');
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return disabledTabsResult(db.code || 'PROFILE_TABS_DISABLED', cid, 'media', db);
  }

  const limit = normalizeLimit(options.limit);
  const result = await db.query(
    `SELECT
        id,
        owner_cid,
        owner_display_name_snapshot,
        media_surface,
        mime_type,
        byte_size,
        storage_bucket,
        storage_object_key,
        visibility,
        moderation_status,
        upload_source,
        created_at
       FROM cidentia_media_assets
      WHERE owner_cid = $1
      ORDER BY created_at DESC
      LIMIT $2`,
    [cid, limit],
  );

  return Object.freeze({
    ok: true,
    code: 'PROFILE_MEDIA_READ_OK',
    ownerCid: cid,
    tab: 'media',
    itemsRead: true,
    items: Object.freeze(result.rows.map(mapMediaRow)),
    dbConnected: result.dbConnected === true,
    queryEnabled: db.queryEnabled === true,
    secretsExposed: false,
  });
}

module.exports = {
  normalizeCid,
  readProfilePostsByCid,
  readProfileReelsByCid,
  readProfileMediaByCid,
};
