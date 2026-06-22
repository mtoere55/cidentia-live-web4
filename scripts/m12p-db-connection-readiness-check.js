'use strict';

const { loadDatabaseContract } = require('../server/db/databaseContract');
const { buildPgPoolConfig, createDatabaseClient } = require('../server/db/databaseClient');

async function main() {
  const disabled = createDatabaseClient({});
  const missingUrl = createDatabaseClient({
    CIDENTIA_DATABASE_ENABLED: 'true',
  });

  const readinessEnv = {
    CIDENTIA_DATABASE_ENABLED: 'true',
    CIDENTIA_DATABASE_URL: 'postgres://user:secret@example.local:5432/db',
    CIDENTIA_DATABASE_SSL_MODE: 'require',
    CIDENTIA_DATABASE_POOL_MAX: '5',
  };

  const contract = loadDatabaseContract(readinessEnv);
  const poolConfig = buildPgPoolConfig(readinessEnv);
  const guarded = createDatabaseClient(readinessEnv);
  const guardedQuery = await guarded.query('select 1');

  const requiredEnvKeys = [
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_URL',
    'CIDENTIA_DATABASE_SSL_MODE',
    'CIDENTIA_DATABASE_POOL_MAX',
  ];

  const ok =
    disabled.code === 'DATABASE_DISABLED' &&
    missingUrl.code === 'DATABASE_URL_MISSING' &&
    contract.databaseEnabled === true &&
    contract.databaseUrlPresent === true &&
    poolConfig.connectionStringPresent === true &&
    guarded.code === 'PG_POOL_GUARDED_NOT_CONNECTED' &&
    guarded.dbConnected === false &&
    guarded.queryEnabled === false &&
    guardedQuery.rows.length === 0 &&
    poolConfig.secretsExposed === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          disabled,
          missingUrl,
          contract,
          poolConfig,
          guarded,
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
        requiredEnvKeys,
        disabledCode: disabled.code,
        missingUrlCode: missingUrl.code,
        guardedCode: guarded.code,
        databaseEnabled: contract.databaseEnabled,
        databaseUrlPresent: contract.databaseUrlPresent,
        poolPrepared: guarded.poolPrepared === true,
        dbConnected: guarded.dbConnected,
        queryEnabled: guarded.queryEnabled,
        migrationExecuted: guarded.migrationExecuted,
        secretsExposed: false,
        realConnectionOpened: false,
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
