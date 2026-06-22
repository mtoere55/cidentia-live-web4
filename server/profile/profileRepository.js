'use strict';

const { randomUUID } = require('crypto');
const { createDatabaseClient } = require('../db/databaseClient');

function sanitizeProfileDraft(input = {}) {
  return Object.freeze({
    displayName:
      typeof input.displayName === 'string' ? input.displayName.trim() : '',
    email: typeof input.email === 'string' ? input.email.trim() : '',
    bio: typeof input.bio === 'string' ? input.bio.trim() : '',
    avatarMediaId:
      typeof input.avatarMediaId === 'string' ? input.avatarMediaId.trim() : '',
    coverMediaId:
      typeof input.coverMediaId === 'string' ? input.coverMediaId.trim() : '',
  });
}

function nullable(value) {
  return value && value.length > 0 ? value : null;
}

function mapProfileRow(row) {
  if (!row) {
    return null;
  }

  return Object.freeze({
    id: row.id,
    ownerCid: row.owner_cid,
    displayName: row.display_name || '',
    email: row.email || '',
    bio: row.bio || '',
    avatarMediaId: row.avatar_media_id || '',
    coverMediaId: row.cover_media_id || '',
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  });
}

async function readProfileByCid(ownerCid, options = {}) {
  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return Object.freeze({
      ok: false,
      code: db.code || 'PROFILE_READ_DISABLED',
      ownerCid,
      profileRead: false,
      profile: null,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
    });
  }

  const result = await db.query(
    `SELECT id, owner_cid, display_name, email, bio, avatar_media_id, cover_media_id, created_at, updated_at
       FROM cidentia_profiles
      WHERE owner_cid = $1
      LIMIT 1`,
    [ownerCid],
  );

  return Object.freeze({
    ok: true,
    code: result.rows.length > 0 ? 'PROFILE_READ_OK' : 'PROFILE_NOT_FOUND',
    ownerCid,
    profileRead: true,
    profile: mapProfileRow(result.rows[0]),
    dbConnected: result.dbConnected,
    queryEnabled: db.queryEnabled,
  });
}

async function upsertProfileByCid(ownerCid, draft = {}, options = {}) {
  const db = options.db || createDatabaseClient(options.env);
  const profileDraft = sanitizeProfileDraft(draft);

  if (!db.queryEnabled) {
    return Object.freeze({
      ok: false,
      code: db.code || 'PROFILE_WRITE_DISABLED',
      ownerCid,
      profileUpdated: false,
      profileDraft,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
    });
  }

  const result = await db.query(
    `INSERT INTO cidentia_profiles (
        id,
        owner_cid,
        display_name,
        email,
        bio,
        avatar_media_id,
        cover_media_id,
        created_at,
        updated_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, now(), now())
      ON CONFLICT (owner_cid)
      DO UPDATE SET
        display_name = EXCLUDED.display_name,
        email = EXCLUDED.email,
        bio = EXCLUDED.bio,
        avatar_media_id = EXCLUDED.avatar_media_id,
        cover_media_id = EXCLUDED.cover_media_id,
        updated_at = now()
      RETURNING id, owner_cid, display_name, email, bio, avatar_media_id, cover_media_id, created_at, updated_at`,
    [
      randomUUID(),
      ownerCid,
      nullable(profileDraft.displayName),
      nullable(profileDraft.email),
      nullable(profileDraft.bio),
      nullable(profileDraft.avatarMediaId),
      nullable(profileDraft.coverMediaId),
    ],
  );

  return Object.freeze({
    ok: true,
    code: 'PROFILE_WRITE_OK',
    ownerCid,
    profileUpdated: result.rowCount > 0,
    profileDraft,
    profile: mapProfileRow(result.rows[0]),
    dbConnected: result.dbConnected,
    queryEnabled: db.queryEnabled,
  });
}

module.exports = {
  sanitizeProfileDraft,
  readProfileByCid,
  upsertProfileByCid,
};
