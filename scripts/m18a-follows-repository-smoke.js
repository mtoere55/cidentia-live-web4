'use strict';

const { createDatabaseClient } = require('../server/db/databaseClient');
const {
  followCid,
  unfollowCid,
  readFollowers,
  readFollowing,
} = require('../server/social/followsRepository');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function requireSmokeGate() {
  const required = [
    'CIDENTIA_FOLLOWS_REPOSITORY_SMOKE',
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_QUERY_ENABLED',
  ];

  const missing = required.filter((key) => !envTrue(key));

  if (missing.length > 0) {
    return Object.freeze({
      ok: false,
      code: 'M18A_SMOKE_GATES_DISABLED',
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
    code: 'M18A_SMOKE_GATES_READY',
  });
}

async function main() {
  const gate = requireSmokeGate();

  if (!gate.ok) {
    console.log(JSON.stringify(gate, null, 2));
    process.exitCode = 1;
    return;
  }

  const followerCid = 'Cid-M18A-Follower-Smoke';
  const followedCid = 'Cid-M18A-Followed-Smoke';
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

    const follow = await followCid(followerCid, followedCid, { db });
    const followers = await readFollowers(followedCid, { db });
    const following = await readFollowing(followerCid, { db });
    const duplicate = await followCid(followerCid, followedCid, { db });
    const unfollow = await unfollowCid(followerCid, followedCid, { db });

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
        follow.code === 'FOLLOW_CREATED' &&
        follow.followCreated === true &&
        followers.code === 'FOLLOWERS_READ_OK' &&
        followers.followerCount === 1 &&
        following.code === 'FOLLOWING_READ_OK' &&
        following.followingCount === 1 &&
        duplicate.code === 'FOLLOW_ALREADY_EXISTS' &&
        duplicate.followCreated === false &&
        unfollow.code === 'FOLLOW_DELETED' &&
        unfollow.followDeleted === true &&
        cleanupDone === true,
      code: 'M18A_FOLLOWS_REPOSITORY_SMOKE_OK',
      followerCid,
      followedCid,
      followCode: follow.code,
      duplicateCode: duplicate.code,
      unfollowCode: unfollow.code,
      followersCode: followers.code,
      followingCode: following.code,
      followCreated: follow.followCreated,
      duplicateBlocked: duplicate.code === 'FOLLOW_ALREADY_EXISTS',
      followDeleted: unfollow.followDeleted,
      followersRead: followers.followersRead,
      followingRead: following.followingRead,
      followerCount: followers.followerCount,
      followingCount: following.followingCount,
      cleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicRouteOpened: false,
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
    code: 'M18A_FOLLOWS_REPOSITORY_SMOKE_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
