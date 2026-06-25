'use strict';

const { spawnSync } = require('child_process');

const result = spawnSync(
  process.execPath,
  ['scripts/m17e-profile-cover-persistence-smoke.js'],
  {
    encoding: 'utf8',
    env: {
      ...process.env,
      CIDENTIA_PROFILE_COVER_PERSISTENCE_SMOKE: 'false',
      CIDENTIA_MEDIA_METADATA_WRITE_ENABLED: 'false',
      CIDENTIA_PROFILE_WRITE_ENABLED: 'false',
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
    parsed.code === 'M17E_SMOKE_GATES_DISABLED' &&
    parsed.mediaMetadataCreated === false &&
    parsed.profileUpdated === false &&
    parsed.profileRead === false &&
    parsed.coverLinked === false &&
    parsed.cleanupDone === false &&
    parsed.dbConnected === false &&
    parsed.queryEnabled === false &&
    parsed.secretsExposed === false,
  childExitCode: result.status,
  code: parsed.code,
  missing: parsed.missing,
  mediaMetadataCreated: parsed.mediaMetadataCreated,
  profileUpdated: parsed.profileUpdated,
  profileRead: parsed.profileRead,
  coverLinked: parsed.coverLinked,
  cleanupDone: parsed.cleanupDone,
  dbConnected: parsed.dbConnected,
  queryEnabled: parsed.queryEnabled,
  secretsExposed: parsed.secretsExposed,
});

console.log(JSON.stringify(report, null, 2));

if (!report.ok) {
  process.exitCode = 1;
}
