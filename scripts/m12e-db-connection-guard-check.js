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

  const disabledQuery = await disabledClient.query('select 1');
  const guardedQuery = await guardedClient.query('select 1');

  const ok =
    disabledClient.code === 'DATABASE_DISABLED' &&
    missingUrlClient.code === 'DATABASE_URL_MISSING' &&
    guardedClient.code === 'DATABASE_CLIENT_NOT_IMPLEMENTED' &&
    disabledClient.dbConnected === false &&
    guardedClient.dbConnected === false &&
    guardedClient.secretsExposed === false &&
    disabledQuery.rows.length === 0 &&
    guardedQuery.rows.length === 0;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          disabledClient,
          missingUrlClient,
          guardedClient,
          disabledQuery,
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
        dbConnected: guardedClient.dbConnected,
        migrationExecuted: guardedClient.migrationExecuted,
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
