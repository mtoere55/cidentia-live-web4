'use strict';

const { runGuardedLiveDatabaseSmoke } = require('../server/db/liveDatabaseSmoke');
const { runGuardedMigration } = require('../server/db/migrationRunner');

async function main() {
  const defaultSmoke = await runGuardedLiveDatabaseSmoke({});
  const defaultMigration = await runGuardedMigration({});

  const migrationGateWithoutDb = await runGuardedMigration({
    CIDENTIA_DATABASE_MIGRATION_ENABLED: 'true',
  });

  const smokeGateWithoutUrl = await runGuardedLiveDatabaseSmoke({
    CIDENTIA_DATABASE_LIVE_SMOKE: 'true',
    CIDENTIA_DATABASE_ENABLED: 'true',
  });

  const migrationGateWithoutUrl = await runGuardedMigration({
    CIDENTIA_DATABASE_MIGRATION_ENABLED: 'true',
    CIDENTIA_DATABASE_ENABLED: 'true',
  });

  const requiredOrder = Object.freeze([
    'configure server-only CIDENTIA_DATABASE_URL outside Git',
    'run guarded live DB smoke with CIDENTIA_DATABASE_LIVE_SMOKE=true',
    'confirm DATABASE_LIVE_SMOKE_OK',
    'enable migration gate with CIDENTIA_DATABASE_MIGRATION_ENABLED=true',
    'run migration from backend/VPS only',
  ]);

  const requiredEnvKeys = Object.freeze([
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_URL',
    'CIDENTIA_DATABASE_SSL_MODE',
    'CIDENTIA_DATABASE_POOL_MAX',
    'CIDENTIA_DATABASE_LIVE_SMOKE',
    'CIDENTIA_DATABASE_MIGRATION_ENABLED',
  ]);

  const ok =
    defaultSmoke.code === 'DATABASE_LIVE_SMOKE_DISABLED' &&
    defaultMigration.code === 'MIGRATION_RUNNER_DISABLED' &&
    migrationGateWithoutDb.code === 'MIGRATION_DB_NOT_CONNECTED' &&
    migrationGateWithoutDb.databaseCode === 'DATABASE_DISABLED' &&
    smokeGateWithoutUrl.code === 'DATABASE_URL_MISSING' &&
    migrationGateWithoutUrl.code === 'MIGRATION_DB_NOT_CONNECTED' &&
    migrationGateWithoutUrl.databaseCode === 'DATABASE_URL_MISSING' &&
    defaultSmoke.dbConnected === false &&
    defaultMigration.migrationExecuted === false &&
    migrationGateWithoutDb.migrationExecuted === false &&
    migrationGateWithoutUrl.migrationExecuted === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          defaultSmoke,
          defaultMigration,
          migrationGateWithoutDb,
          smokeGateWithoutUrl,
          migrationGateWithoutUrl,
          requiredEnvKeys,
          requiredOrder,
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
        defaultSmokeCode: defaultSmoke.code,
        defaultMigrationCode: defaultMigration.code,
        migrationGateWithoutDbCode: migrationGateWithoutDb.code,
        migrationGateWithoutDbDatabaseCode: migrationGateWithoutDb.databaseCode,
        smokeGateWithoutUrlCode: smokeGateWithoutUrl.code,
        migrationGateWithoutUrlCode: migrationGateWithoutUrl.code,
        migrationGateWithoutUrlDatabaseCode: migrationGateWithoutUrl.databaseCode,
        requiredEnvKeys,
        requiredOrder,
        migrationExecuted: false,
        dbConnected: false,
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
