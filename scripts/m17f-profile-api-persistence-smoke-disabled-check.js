'use strict';

const { spawnSync } = require('child_process');

const result = spawnSync(
  process.execPath,
  ['scripts/m17f-profile-api-persistence-smoke.js'],
  {
    encoding: 'utf8',
    env: {
      ...process.env,
      CIDENTIA_PROFILE_API_PERSISTENCE_SMOKE: 'false',
      CIDENTIA_DATABASE_ENABLED: 'false',
      CIDENTIA_DATABASE_QUERY_ENABLED: 'false',
      CIDENTIA_DATABASE_URL: '',
    },
  },
);

const parsed = JSON.parse(result.stdout);

const report = Object.freeze({
  ok:
    result.status === 1 &&
    parsed.code === 'M17F_SMOKE_GATES_DISABLED' &&
    parsed.profileUpdated === false &&
    parsed.profileRead === false &&
    parsed.routeUpdateOk === false &&
    parsed.routeReadOk === false &&
    parsed.cleanupDone === false &&
    parsed.dbConnected === false &&
    parsed.queryEnabled === false &&
    parsed.secretsExposed === false,
  childExitCode: result.status,
  code: parsed.code,
  missing: parsed.missing,
  profileUpdated: parsed.profileUpdated,
  profileRead: parsed.profileRead,
  routeUpdateOk: parsed.routeUpdateOk,
  routeReadOk: parsed.routeReadOk,
  cleanupDone: parsed.cleanupDone,
  dbConnected: parsed.dbConnected,
  queryEnabled: parsed.queryEnabled,
  secretsExposed: parsed.secretsExposed,
});

console.log(JSON.stringify(report, null, 2));

if (!report.ok) {
  process.exitCode = 1;
}
