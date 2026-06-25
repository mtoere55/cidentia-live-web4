'use strict';

const { randomUUID } = require('crypto');
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

function mapFollowRow(row) {
  if (!row) {
    return null;
  }

  return Object.freeze({
    id: row.id,
    followerCid: row.follower_cid,
    followedCid: row.followed_cid,
    createdAt: row.created_at,
  });
}

function invalidFollowResult(code, details = {}) {
  return Object.freeze({
    ok: false,
    code,
    followCreated: false,
    followDeleted: false,
    followersRead: false,
    followingRead: false,
    dbConnected: false,
    queryEnabled: false,
    ...details,
  });
}

function validateFollowPair(followerCid, followedCid) {
  const normalizedFollowerCid = normalizeCid(followerCid);
  const normalizedFollowedCid = normalizeCid(followedCid);

  if (!normalizedFollowerCid) {
    return invalidFollowResult('FOLLOWER_CID_REQUIRED');
  }

  if (!normalizedFollowedCid) {
    return invalidFollowResult('FOLLOWED_CID_REQUIRED');
  }

  if (normalizedFollowerCid === normalizedFollowedCid) {
    return invalidFollowResult('SELF_FOLLOW_BLOCKED', {
      followerCid: normalizedFollowerCid,
      followedCid: normalizedFollowedCid,
    });
  }

  return Object.freeze({
    ok: true,
    followerCid: normalizedFollowerCid,
    followedCid: normalizedFollowedCid,
  });
}

async function followCid(followerCid, followedCid, options = {}) {
  const pair = validateFollowPair(followerCid, followedCid);

  if (!pair.ok) {
    return pair;
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return Object.freeze({
      ok: false,
      code: db.code || 'FOLLOW_WRITE_DISABLED',
      followerCid: pair.followerCid,
      followedCid: pair.followedCid,
      followCreated: false,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
    });
  }

  const result = await db.query(
    `INSERT INTO cidentia_follows (
        id,
        follower_cid,
        followed_cid,
        created_at
      )
      VALUES ($1, $2, $3, now())
      ON CONFLICT (follower_cid, followed_cid)
      DO NOTHING
      RETURNING id, follower_cid, followed_cid, created_at`,
    [randomUUID(), pair.followerCid, pair.followedCid],
  );

  return Object.freeze({
    ok: true,
    code: result.rowCount > 0 ? 'FOLLOW_CREATED' : 'FOLLOW_ALREADY_EXISTS',
    followerCid: pair.followerCid,
    followedCid: pair.followedCid,
    followCreated: result.rowCount > 0,
    follow: mapFollowRow(result.rows[0]),
    dbConnected: result.dbConnected,
    queryEnabled: db.queryEnabled,
  });
}

async function unfollowCid(followerCid, followedCid, options = {}) {
  const pair = validateFollowPair(followerCid, followedCid);

  if (!pair.ok) {
    return pair;
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return Object.freeze({
      ok: false,
      code: db.code || 'FOLLOW_DELETE_DISABLED',
      followerCid: pair.followerCid,
      followedCid: pair.followedCid,
      followDeleted: false,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
    });
  }

  const result = await db.query(
    `DELETE FROM cidentia_follows
      WHERE follower_cid = $1
        AND followed_cid = $2`,
    [pair.followerCid, pair.followedCid],
  );

  return Object.freeze({
    ok: true,
    code: result.rowCount > 0 ? 'FOLLOW_DELETED' : 'FOLLOW_NOT_FOUND',
    followerCid: pair.followerCid,
    followedCid: pair.followedCid,
    followDeleted: result.rowCount > 0,
    dbConnected: result.dbConnected,
    queryEnabled: db.queryEnabled,
  });
}

async function readFollowers(ownerCid, options = {}) {
  const cid = normalizeCid(ownerCid);

  if (!cid) {
    return invalidFollowResult('OWNER_CID_REQUIRED');
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return Object.freeze({
      ok: false,
      code: db.code || 'FOLLOWERS_READ_DISABLED',
      ownerCid: cid,
      followersRead: false,
      followers: [],
      followerCount: 0,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
    });
  }

  const result = await db.query(
    `SELECT id, follower_cid, followed_cid, created_at
       FROM cidentia_follows
      WHERE followed_cid = $1
      ORDER BY created_at DESC`,
    [cid],
  );

  return Object.freeze({
    ok: true,
    code: 'FOLLOWERS_READ_OK',
    ownerCid: cid,
    followersRead: true,
    followers: result.rows.map(mapFollowRow),
    followerCount: result.rows.length,
    dbConnected: result.dbConnected,
    queryEnabled: db.queryEnabled,
  });
}

async function readFollowing(ownerCid, options = {}) {
  const cid = normalizeCid(ownerCid);

  if (!cid) {
    return invalidFollowResult('OWNER_CID_REQUIRED');
  }

  const db = options.db || createDatabaseClient(options.env);

  if (!db.queryEnabled) {
    return Object.freeze({
      ok: false,
      code: db.code || 'FOLLOWING_READ_DISABLED',
      ownerCid: cid,
      followingRead: false,
      following: [],
      followingCount: 0,
      dbConnected: db.dbConnected,
      queryEnabled: db.queryEnabled,
    });
  }

  const result = await db.query(
    `SELECT id, follower_cid, followed_cid, created_at
       FROM cidentia_follows
      WHERE follower_cid = $1
      ORDER BY created_at DESC`,
    [cid],
  );

  return Object.freeze({
    ok: true,
    code: 'FOLLOWING_READ_OK',
    ownerCid: cid,
    followingRead: true,
    following: result.rows.map(mapFollowRow),
    followingCount: result.rows.length,
    dbConnected: result.dbConnected,
    queryEnabled: db.queryEnabled,
  });
}

module.exports = {
  normalizeCid,
  validateFollowPair,
  followCid,
  unfollowCid,
  readFollowers,
  readFollowing,
};
