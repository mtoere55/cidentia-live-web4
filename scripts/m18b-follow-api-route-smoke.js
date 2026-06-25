'use strict';

const { createDatabaseClient } = require('../server/db/databaseClient');
const followHandler = require('../api/social/follow');
const unfollowHandler = require('../api/social/unfollow');
const followersHandler = require('../api/social/followers');
const followingHandler = require('../api/social/following');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function requireSmokeGate() {
  const required = [
    'CIDENTIA_SOCIAL_FOLLOW_ROUTES_SMOKE',
    'CIDENTIA_SOCIAL_FOLLOW_ROUTES_ENABLED',
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_QUERY_ENABLED',
  ];

  const missing = required.filter((key) => !envTrue(key));

  if (missing.length > 0) {
    return Object.freeze({
      ok: false,
      code: 'M18B_SMOKE_GATES_DISABLED',
      missing,
      followCreated: false,
      followDeleted: false,
      followersRead: false,
      followingRead: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  if (
    typeof process.env.CIDENTIA_DATABASE_URL !== 'string' ||
    process.env.CIDENTIA_DATABASE_URL.trim().length === 0
  ) {
    return Object.freeze({
      ok: false,
      code: 'DATABASE_URL_MISSING',
      followCreated: false,
      followDeleted: false,
      followersRead: false,
      followingRead: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  return Object.freeze({
    ok: true,
    code: 'M18B_SMOKE_GATES_READY',
  });
}

function createResponse() {
  const state = {
    statusCode: 200,
    payload: null,
  };

  return {
    state,
    status(code) {
      state.statusCode = code;
      return this;
    },
    json(payload) {
      state.payload = payload;
      return this;
    },
  };
}

async function call(handler, req) {
  const res = createResponse();
  await handler(req, res);
  return res.state;
}

async function main() {
  const gate = requireSmokeGate();

  if (!gate.ok) {
    console.log(JSON.stringify(gate, null, 2));
    process.exitCode = 1;
    return;
  }

  const followerCid = 'Cid-M18B-Follower-Smoke';
  const followedCid = 'Cid-M18B-Followed-Smoke';
  const db = createDatabaseClient(process.env);
  let cleanupDone = false;

  try {
    await db.query(
      `DELETE FROM cidentia_follows
        WHERE follower_cid = $1
           OR followed_cid = $1
           OR follower_cid = $2
           OR followed_cid = $2`,
      [followerCid, followedCid],
    );

    const follow = await call(followHandler, {
      method: 'POST',
      headers: {
        'x-cidentia-cid': followerCid,
      },
      body: {
        followedCid,
      },
    });

    const followers = await call(followersHandler, {
      method: 'GET',
      headers: {},
      query: {
        ownerCid: followedCid,
      },
    });

    const following = await call(followingHandler, {
      method: 'GET',
      headers: {},
      query: {
        ownerCid: followerCid,
      },
    });

    const duplicate = await call(followHandler, {
      method: 'POST',
      headers: {
        'x-cidentia-cid': followerCid,
      },
      body: {
        followedCid,
      },
    });

    const unfollow = await call(unfollowHandler, {
      method: 'POST',
      headers: {
        'x-cidentia-cid': followerCid,
      },
      body: {
        followedCid,
      },
    });

    const cleanup = await db.query(
      `DELETE FROM cidentia_follows
        WHERE follower_cid = $1
           OR followed_cid = $1
           OR follower_cid = $2
           OR followed_cid = $2`,
      [followerCid, followedCid],
    );
    cleanupDone = cleanup.rowCount === 0;

    const report = Object.freeze({
      ok:
        follow.statusCode === 200 &&
        follow.payload.code === 'FOLLOW_CREATED' &&
        follow.payload.followCreated === true &&
        followers.statusCode === 200 &&
        followers.payload.code === 'FOLLOWERS_READ_OK' &&
        followers.payload.followerCount === 1 &&
        following.statusCode === 200 &&
        following.payload.code === 'FOLLOWING_READ_OK' &&
        following.payload.followingCount === 1 &&
        duplicate.statusCode === 200 &&
        duplicate.payload.code === 'FOLLOW_ALREADY_EXISTS' &&
        duplicate.payload.followCreated === false &&
        unfollow.statusCode === 200 &&
        unfollow.payload.code === 'FOLLOW_DELETED' &&
        unfollow.payload.followDeleted === true &&
        cleanupDone === true,
      code: 'M18B_FOLLOW_API_ROUTE_SMOKE_OK',
      followerCid,
      followedCid,
      followStatusCode: follow.statusCode,
      duplicateStatusCode: duplicate.statusCode,
      unfollowStatusCode: unfollow.statusCode,
      followersStatusCode: followers.statusCode,
      followingStatusCode: following.statusCode,
      followCode: follow.payload && follow.payload.code,
      duplicateCode: duplicate.payload && duplicate.payload.code,
      unfollowCode: unfollow.payload && unfollow.payload.code,
      followersCode: followers.payload && followers.payload.code,
      followingCode: following.payload && following.payload.code,
      followCreated: Boolean(follow.payload && follow.payload.followCreated),
      duplicateBlocked:
        duplicate.payload && duplicate.payload.code === 'FOLLOW_ALREADY_EXISTS',
      followDeleted: Boolean(unfollow.payload && unfollow.payload.followDeleted),
      followersRead: Boolean(followers.payload && followers.payload.followersRead),
      followingRead: Boolean(following.payload && following.payload.followingRead),
      followerCount: followers.payload ? followers.payload.followerCount : 0,
      followingCount: following.payload ? following.payload.followingCount : 0,
      cleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicRouteDefaultOpened: false,
      flutterFollowOpened: false,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!report.ok) {
      process.exitCode = 1;
    }
  } finally {
    if (!cleanupDone) {
      await db.query(
        `DELETE FROM cidentia_follows
          WHERE follower_cid = $1
             OR followed_cid = $1
             OR follower_cid = $2
             OR followed_cid = $2`,
        [followerCid, followedCid],
      );
    }

    await db.close();
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M18B_FOLLOW_API_ROUTE_SMOKE_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
