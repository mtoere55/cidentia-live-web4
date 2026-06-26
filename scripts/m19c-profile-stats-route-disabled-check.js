'use strict';

const statsHandler = require('../api/profile/stats');

function createResponse() {
  return {
    statusCode: 200,
    payload: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.payload = payload;
      return this;
    },
  };
}

async function callStats(req) {
  const res = createResponse();
  await statsHandler(req, res);
  return res;
}

async function main() {
  const missingCid = await callStats({
    method: 'GET',
    headers: {},
    query: {},
  });

  const disabled = await callStats({
    method: 'GET',
    headers: {
      'x-cidentia-cid': 'Cid-M19C-Stats',
    },
    query: {},
  });

  const report = Object.freeze({
    ok:
      missingCid.statusCode === 401 &&
      missingCid.payload.code === 'PROFILE_CID_REQUIRED' &&
      disabled.statusCode === 503 &&
      disabled.payload.code === 'PROFILE_STATS_DISABLED' &&
      disabled.payload.repositoryCode === 'DATABASE_DISABLED' &&
      disabled.payload.statsRead === false &&
      disabled.payload.postsCount === null &&
      disabled.payload.reelsCount === null &&
      disabled.payload.mediaCount === null &&
      disabled.payload.followersCount === null &&
      disabled.payload.followingCount === null &&
      disabled.payload.trustScore === null &&
      disabled.payload.dbConnected === false &&
      disabled.payload.queryEnabled === false &&
      disabled.payload.secretsExposed === false,
    missingCidStatus: missingCid.statusCode,
    missingCidCode: missingCid.payload.code,
    disabledStatus: disabled.statusCode,
    disabledCode: disabled.payload.code,
    repositoryCode: disabled.payload.repositoryCode,
    statsRead: disabled.payload.statsRead,
    postsCount: disabled.payload.postsCount,
    reelsCount: disabled.payload.reelsCount,
    mediaCount: disabled.payload.mediaCount,
    followersCount: disabled.payload.followersCount,
    followingCount: disabled.payload.followingCount,
    trustScore: disabled.payload.trustScore,
    dbConnected: disabled.payload.dbConnected,
    queryEnabled: disabled.payload.queryEnabled,
    secretsExposed: disabled.payload.secretsExposed,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M19C_PROFILE_STATS_ROUTE_DISABLED_CHECK_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
