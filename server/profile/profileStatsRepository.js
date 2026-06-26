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

function disabledStatsResult(code, ownerCid, db = {}) {
  return Object.freeze({
    ok: false,
    code,
    ownerCid,
    statsRead: false,
    postsCount: null,
    reelsCount: null,
    mediaCount: null,
    followersCount: null,
    followingCount: null,
    trustScore: null,
    dbConnected: db.dbConnected === true,
    queryEnabled: db.queryEnabled === true,
    secretsExposed: false,
  });
}

async function readProfileStatsByCid(ownerCid, options = {}) {
  const cid = normalizeCid(ownerCid);

  if (!cid) {
    return disabledStatsResult('PROFILE_CID_REQUIRED', null);
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return disabledStatsResult(db.code || 'PROFILE_STATS_DISABLED', cid, db);
  }

  const result = await db.query(
    `SELECT
       (SELECT COUNT(*)::int
          FROM cidentia_posts
         WHERE owner_cid = $1) AS posts_count,
       (SELECT COUNT(*)::int
          FROM cidentia_reels
         WHERE owner_cid = $1) AS reels_count,
       (SELECT COUNT(*)::int
          FROM cidentia_media_assets
         WHERE owner_cid = $1) AS media_count,
       (SELECT COUNT(*)::int
          FROM cidentia_follows
         WHERE followed_cid = $1) AS followers_count,
       (SELECT COUNT(*)::int
          FROM cidentia_follows
         WHERE follower_cid = $1) AS following_count`,
    [cid],
  );

  const row = result.rows[0] || {};

  return Object.freeze({
    ok: true,
    code: 'PROFILE_STATS_READ_OK',
    ownerCid: cid,
    statsRead: true,
    postsCount: Number(row.posts_count || 0),
    reelsCount: Number(row.reels_count || 0),
    mediaCount: Number(row.media_count || 0),
    followersCount: Number(row.followers_count || 0),
    followingCount: Number(row.following_count || 0),
    trustScore: null,
    dbConnected: result.dbConnected === true,
    queryEnabled: db.queryEnabled === true,
    secretsExposed: false,
  });
}

module.exports = {
  normalizeCid,
  readProfileStatsByCid,
};
