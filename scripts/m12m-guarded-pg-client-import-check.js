'use strict';

const { createDatabaseClient } = require('../server/db/databaseClient');

async function main() {
  const disabledClient = createDatabaseClient({});
  const missingUrlClient = createDatabaseClient({
    CIDENTIA_DATABASE_ENABLED: 'true',
  });
  const guardedClient = createDatabaseClient({
    CIDENTIA_DATABASE_ENABLED: 'true',
    CIDENTIA_DATABASE_URL: 'postgres://user:secret@example.local:5432/db',
  });

  const guardedQuery = await guardedClient.query('select 1');

  const ok =
    disabledClient.code === 'DATABASE_DISABLED' &&
    missingUrlClient.code === 'DATABASE_URL_MISSING' &&
    (
      guardedClient.code === 'PG_DRIVER_NOT_INSTALLED' ||
      guardedClient.code === 'PG_DRIVER_GUARDED_NOT_CONNECTED'
    ) &&
    disabledClient.dbConnected === false &&
    guardedClient.dbConnected === false &&
    guardedClient.queryEnabled === false &&
    guardedClient.secretsExposed === false &&
    guardedQuery.rows.length === 0;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          disabledClient,
          missingUrlClient,
          guardedClient,
          guardedQuery,
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
        disabledCode: disabledClient.code,
        missingUrlCode: missingUrlClient.code,
        guardedCode: guardedClient.code,
        pgDriverLoaded: guardedClient.pgDriverLoaded === true,
        dbConnected: guardedClient.dbConnected,
        queryEnabled: guardedClient.queryEnabled,
        secretsExposed: guardedClient.secretsExposed,
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
