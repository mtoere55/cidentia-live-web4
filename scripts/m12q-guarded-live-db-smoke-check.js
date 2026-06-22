'use strict';

const { runGuardedLiveDatabaseSmoke } = require('../server/db/liveDatabaseSmoke');

async function main() {
  const disabled = await runGuardedLiveDatabaseSmoke({});
  const gateOnly = await runGuardedLiveDatabaseSmoke({
    CIDENTIA_DATABASE_LIVE_SMOKE: 'true',
  });
  const missingUrl = await runGuardedLiveDatabaseSmoke({
    CIDENTIA_DATABASE_LIVE_SMOKE: 'true',
    CIDENTIA_DATABASE_ENABLED: 'true',
  });

  const ok =
    disabled.code === 'DATABASE_LIVE_SMOKE_DISABLED' &&
    gateOnly.code === 'DATABASE_DISABLED' &&
    missingUrl.code === 'DATABASE_URL_MISSING' &&
    disabled.dbConnected === false &&
    gateOnly.dbConnected === false &&
    missingUrl.dbConnected === false &&
    disabled.queryExecuted === false &&
    gateOnly.queryExecuted === false &&
    missingUrl.queryExecuted === false &&
    disabled.secretsExposed === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          disabled,
          gateOnly,
          missingUrl,
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
        disabledCode: disabled.code,
        gateOnlyCode: gateOnly.code,
        missingUrlCode: missingUrl.code,
        liveSmokeDefaultLocked: true,
        realConnectionOpened: false,
        queryExecuted: false,
        secretsExposed: false,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
