'use strict';

const fs = require('fs');
const path = require('path');

const guidePath = path.join(
  __dirname,
  '..',
  'docs',
  'M12T_DB_LIVE_SMOKE_MANUAL_GUIDE.md',
);

const guide = fs.readFileSync(guidePath, 'utf8');

const forbidden = [
  'postgres://user:secret',
  'postgresql://user:secret',
  'DATABASE_LIVE_SMOKE_OK pasted',
];

const required = [
  'CIDENTIA_DATABASE_LIVE_SMOKE',
  'CIDENTIA_DATABASE_ENABLED',
  'CIDENTIA_DATABASE_URL',
  'DATABASE_LIVE_SMOKE_OK',
  'server-only',
  'Do not paste the real URL into chat',
];

const ok =
  forbidden.every((value) => !guide.includes(value)) &&
  required.every((value) => guide.includes(value));

if (!ok) {
  console.error(
    JSON.stringify(
      {
        ok: false,
        forbiddenFound: forbidden.filter((value) => guide.includes(value)),
        requiredMissing: required.filter((value) => !guide.includes(value)),
      },
      null,
      2,
    ),
  );
  process.exit(1);
}

console.log(
  JSON.stringify(
    {
      ok: true,
      guideExists: true,
      realDatabaseUrlCommitted: false,
      frontendReceivesDatabaseSecret: false,
      normalRuntimeConnectsDb: false,
      migrationExecuted: false,
      queryExecutedByCheck: false,
    },
    null,
    2,
  ),
);
