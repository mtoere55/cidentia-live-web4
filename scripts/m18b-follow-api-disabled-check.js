'use strict';

const followHandler = require('../api/social/follow');
const unfollowHandler = require('../api/social/unfollow');
const followersHandler = require('../api/social/followers');
const followingHandler = require('../api/social/following');

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
  process.env.CIDENTIA_SOCIAL_FOLLOW_ROUTES_ENABLED = 'false';
  process.env.CIDENTIA_DATABASE_ENABLED = 'false';
  process.env.CIDENTIA_DATABASE_QUERY_ENABLED = 'false';
  process.env.CIDENTIA_DATABASE_URL = '';

  const missingCid = await call(followHandler, {
    method: 'POST',
    headers: {},
    body: {
      followedCid: 'Cid-M18B-Target',
    },
  });

  const follow = await call(followHandler, {
    method: 'POST',
    headers: {
      'x-cidentia-cid': 'Cid-M18B-Follower',
    },
    body: {
      followedCid: 'Cid-M18B-Target',
    },
  });

  const unfollow = await call(unfollowHandler, {
    method: 'POST',
    headers: {
      'x-cidentia-cid': 'Cid-M18B-Follower',
    },
    body: {
      followedCid: 'Cid-M18B-Target',
    },
  });

  const followers = await call(followersHandler, {
    method: 'GET',
    headers: {},
    query: {
      ownerCid: 'Cid-M18B-Target',
    },
  });

  const following = await call(followingHandler, {
    method: 'GET',
    headers: {},
    query: {
      ownerCid: 'Cid-M18B-Follower',
    },
  });

  const report = Object.freeze({
    ok:
      missingCid.statusCode === 401 &&
      missingCid.payload.code === 'SOCIAL_CID_REQUIRED' &&
      follow.statusCode === 503 &&
      follow.payload.code === 'SOCIAL_ROUTE_DISABLED' &&
      unfollow.statusCode === 503 &&
      unfollow.payload.code === 'SOCIAL_ROUTE_DISABLED' &&
      followers.statusCode === 503 &&
      followers.payload.code === 'SOCIAL_ROUTE_DISABLED' &&
      following.statusCode === 503 &&
      following.payload.code === 'SOCIAL_ROUTE_DISABLED' &&
      follow.payload.followCreated === false &&
      unfollow.payload.followDeleted === false &&
      followers.payload.followersRead === false &&
      following.payload.followingRead === false &&
      follow.payload.secretsExposed === false,
    missingCid: {
      statusCode: missingCid.statusCode,
      code: missingCid.payload.code,
    },
    follow: {
      statusCode: follow.statusCode,
      code: follow.payload.code,
      repositoryCode: follow.payload.repositoryCode,
      followCreated: follow.payload.followCreated,
    },
    unfollow: {
      statusCode: unfollow.statusCode,
      code: unfollow.payload.code,
      repositoryCode: unfollow.payload.repositoryCode,
      followDeleted: unfollow.payload.followDeleted,
    },
    followers: {
      statusCode: followers.statusCode,
      code: followers.payload.code,
      repositoryCode: followers.payload.repositoryCode,
      followersRead: followers.payload.followersRead,
    },
    following: {
      statusCode: following.statusCode,
      code: following.payload.code,
      repositoryCode: following.payload.repositoryCode,
      followingRead: following.payload.followingRead,
    },
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
    code: 'M18B_FOLLOW_API_DISABLED_CHECK_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
