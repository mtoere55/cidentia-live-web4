'use strict';

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

  return Object.freeze({
    ok: false,
    code: 'PROFILE_REPOSITORY_QUERY_NOT_IMPLEMENTED',
    ownerCid,
    profileRead: false,
    profile: null,
    dbConnected: db.dbConnected,
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

  return Object.freeze({
    ok: false,
    code: 'PROFILE_REPOSITORY_WRITE_NOT_IMPLEMENTED',
    ownerCid,
    profileUpdated: false,
    profileDraft,
    dbConnected: db.dbConnected,
    queryEnabled: db.queryEnabled,
  });
}

module.exports = {
  sanitizeProfileDraft,
  readProfileByCid,
  upsertProfileByCid,
};
