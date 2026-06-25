'use strict';

const {
  followCid,
  unfollowCid,
  readFollowers,
  readFollowing,
} = require('../server/social/followsRepository');

async function main() {
  const env = {
    CIDENTIA_DATABASE_ENABLED: 'false',
    CIDENTIA_DATABASE_QUERY_ENABLED: 'false',
    CIDENTIA_DATABASE_URL: '',
  };

  const follow = await followCid('Cid-M18A-Follower', 'Cid-M18A-Followed', {
    env,
  });
  const unfollow = await unfollowCid('Cid-M18A-Follower', 'Cid-M18A-Followed', {
    env,
  });
  const followers = await readFollowers('Cid-M18A-Followed', { env });
  const following = await readFollowing('Cid-M18A-Follower', { env });

  const selfFollow = await followCid('Cid-M18A-Same', 'Cid-M18A-Same', {
    env,
  });

  const report = Object.freeze({
    ok:
      follow.ok === false &&
      follow.followCreated === false &&
      unfollow.ok === false &&
      unfollow.followDeleted === false &&
      followers.ok === false &&
      followers.followersRead === false &&
      following.ok === false &&
      following.followingRead === false &&
      selfFollow.code === 'SELF_FOLLOW_BLOCKED' &&
      follow.dbConnected === false &&
      follow.queryEnabled === false,
    followCode: follow.code,
    unfollowCode: unfollow.code,
    followersCode: followers.code,
    followingCode: following.code,
    selfFollowCode: selfFollow.code,
    followCreated: follow.followCreated,
    followDeleted: unfollow.followDeleted,
    followersRead: followers.followersRead,
    followingRead: following.followingRead,
    dbConnected: follow.dbConnected,
    queryEnabled: follow.queryEnabled,
    secretsExposed: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M18A_FOLLOWS_REPOSITORY_CHECK_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
