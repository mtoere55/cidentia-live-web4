'use strict';

const { readProfileStatsByCid } = require('../server/profile/profileStatsRepository');

async function main() {
  const env = {
    CIDENTIA_DATABASE_ENABLED: 'false',
    CIDENTIA_DATABASE_QUERY_ENABLED: 'false',
    CIDENTIA_DATABASE_URL: '',
  };

  const missingCid = await readProfileStatsByCid('', { env });
  const disabled = await readProfileStatsByCid('Cid-M19B-Stats', { env });

  const report = Object.freeze({
    ok:
      missingCid.code === 'PROFILE_CID_REQUIRED' &&
      disabled.ok === false &&
      disabled.code === 'DATABASE_DISABLED' &&
      disabled.statsRead === false &&
      disabled.postsCount === null &&
      disabled.reelsCount === null &&
      disabled.mediaCount === null &&
      disabled.followersCount === null &&
      disabled.followingCount === null &&
      disabled.trustScore === null &&
      disabled.dbConnected === false &&
      disabled.queryEnabled === false &&
      disabled.secretsExposed === false,
    missingCidCode: missingCid.code,
    disabledCode: disabled.code,
    statsRead: disabled.statsRead,
    postsCount: disabled.postsCount,
    reelsCount: disabled.reelsCount,
    mediaCount: disabled.mediaCount,
    followersCount: disabled.followersCount,
    followingCount: disabled.followingCount,
    trustScore: disabled.trustScore,
    dbConnected: disabled.dbConnected,
    queryEnabled: disabled.queryEnabled,
    secretsExposed: disabled.secretsExposed,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M19B_PROFILE_STATS_REPOSITORY_CHECK_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
