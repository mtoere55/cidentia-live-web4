'use strict';

const smoke = require('child_process').spawnSync(
  process.execPath,
  ['scripts/m19d-profile-stats-api-route-smoke.js'],
  {
    cwd: process.cwd(),
    env: {
      ...process.env,
      CIDENTIA_PROFILE_STATS_API_ROUTE_SMOKE: 'false',
      CIDENTIA_DATABASE_ENABLED: 'false',
      CIDENTIA_DATABASE_QUERY_ENABLED: 'false',
      CIDENTIA_DATABASE_URL: '',
    },
    encoding: 'utf8',
  },
);

const stdout = smoke.stdout.trim();
const payload = stdout ? JSON.parse(stdout) : {};

const report = Object.freeze({
  ok:
    smoke.status === 1 &&
    payload.ok === false &&
    payload.code === 'M19D_SMOKE_GATES_DISABLED' &&
    payload.routeRead === false &&
    payload.cleanupDone === false &&
    payload.dbConnected === false &&
    payload.queryEnabled === false &&
    payload.secretsExposed === false,
  status: smoke.status,
  code: payload.code,
  routeRead: payload.routeRead,
  cleanupDone: payload.cleanupDone,
  dbConnected: payload.dbConnected,
  queryEnabled: payload.queryEnabled,
  secretsExposed: payload.secretsExposed,
});

console.log(JSON.stringify(report, null, 2));

if (!report.ok) {
  process.exitCode = 1;
}
