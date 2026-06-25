'use strict';

const { spawnSync } = require('child_process');

const result = spawnSync(
  process.execPath,
  ['scripts/m17d-media-metadata-write-smoke.js'],
  {
    encoding: 'utf8',
    env: {
      ...process.env,
      CIDENTIA_MEDIA_METADATA_WRITE_SMOKE: 'false',
      CIDENTIA_MEDIA_METADATA_WRITE_ENABLED: 'false',
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
    parsed.code === 'M17D_SMOKE_GATES_DISABLED' &&
    parsed.mediaMetadataCreated === false &&
    parsed.dbConnected === false &&
    parsed.queryEnabled === false &&
    parsed.cleanupDone === false &&
    parsed.secretsExposed === false,
  childExitCode: result.status,
  code: parsed.code,
  missing: parsed.missing,
  mediaMetadataCreated: parsed.mediaMetadataCreated,
  dbConnected: parsed.dbConnected,
  queryEnabled: parsed.queryEnabled,
  cleanupDone: parsed.cleanupDone,
  secretsExposed: parsed.secretsExposed,
});

console.log(JSON.stringify(report, null, 2));

if (!report.ok) {
  process.exitCode = 1;
}
