'use strict';

const {
  buildPgPoolConfig,
  createDatabaseClient,
} = require('../server/db/databaseClient');

async function main() {
  const disabledClient = createDatabaseClient({});
  const missingUrlClient = createDatabaseClient({
    CIDENTIA_DATABASE_ENABLED: 'true',
  });
  const poolClient = createDatabaseClient({
    CIDENTIA_DATABASE_ENABLED: 'true',
    CIDENTIA_DATABASE_URL: 'postgres://user:secret@example.local:5432/db',
    CIDENTIA_DATABASE_SSL_MODE: 'require',
    CIDENTIA_DATABASE_POOL_MAX: '7',
  });

  const poolConfig = buildPgPoolConfig({
    CIDENTIA_DATABASE_URL: 'postgres://user:secret@example.local:5432/db',
    CIDENTIA_DATABASE_SSL_MODE: 'require',
    CIDENTIA_DATABASE_POOL_MAX: '7',
  });

  const query = await poolClient.query('select 1');

  const ok =
    disabledClient.code === 'DATABASE_DISABLED' &&
    missingUrlClient.code === 'DATABASE_URL_MISSING' &&
    (
      poolClient.code === 'PG_DRIVER_NOT_INSTALLED' ||
      poolClient.code === 'PG_POOL_GUARDED_NOT_CONNECTED'
    ) &&
    poolClient.dbConnected === false &&
    poolClient.queryEnabled === false &&
    query.rows.length === 0 &&
    poolConfig.connectionStringPresent === true &&
    poolConfig.max === 7 &&
    poolConfig.secretsExposed === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          disabledClient,
          missingUrlClient,
          poolClient,
          poolConfig,
          query,
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
        guardedCode: poolClient.code,
        pgDriverLoaded: poolClient.pgDriverLoaded === true,
        poolPrepared: poolClient.poolPrepared === true,
        poolMax: poolConfig.max,
        dbConnected: poolClient.dbConnected,
        queryEnabled: poolClient.queryEnabled,
        secretsExposed: poolConfig.secretsExposed,
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
