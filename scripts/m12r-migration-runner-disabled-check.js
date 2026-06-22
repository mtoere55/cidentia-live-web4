'use strict';

const {
  readMigrationSql,
  runGuardedMigration,
} = require('../server/db/migrationRunner');

async function main() {
  const migration = readMigrationSql();
  const disabled = await runGuardedMigration({});
  const enabledNoDb = await runGuardedMigration({
    CIDENTIA_DATABASE_MIGRATION_ENABLED: 'true',
  });
  const enabledMissingUrl = await runGuardedMigration({
    CIDENTIA_DATABASE_MIGRATION_ENABLED: 'true',
    CIDENTIA_DATABASE_ENABLED: 'true',
  });

  const ok =
    migration.ok === true &&
    migration.sql.includes('CREATE TABLE IF NOT EXISTS cidentia_profiles') &&
    migration.sql.includes('CREATE TABLE IF NOT EXISTS cidentia_media_assets') &&
    migration.sql.includes('CREATE TABLE IF NOT EXISTS cidentia_posts') &&
    disabled.code === 'MIGRATION_RUNNER_DISABLED' &&
    enabledNoDb.code === 'MIGRATION_DB_NOT_CONNECTED' &&
    enabledNoDb.databaseCode === 'DATABASE_DISABLED' &&
    enabledMissingUrl.code === 'MIGRATION_DB_NOT_CONNECTED' &&
    enabledMissingUrl.databaseCode === 'DATABASE_URL_MISSING' &&
    disabled.migrationExecuted === false &&
    enabledNoDb.migrationExecuted === false &&
    enabledMissingUrl.migrationExecuted === false &&
    disabled.queryExecuted === false &&
    enabledNoDb.queryExecuted === false &&
    enabledMissingUrl.queryExecuted === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          migration: {
            ok: migration.ok,
            code: migration.code,
            sqlLength: migration.sql.length,
          },
          disabled,
          enabledNoDb,
          enabledMissingUrl,
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
        migrationCode: migration.code,
        migrationSqlLength: migration.sql.length,
        disabledCode: disabled.code,
        enabledNoDbCode: enabledNoDb.code,
        enabledNoDbDatabaseCode: enabledNoDb.databaseCode,
        enabledMissingUrlCode: enabledMissingUrl.code,
        enabledMissingUrlDatabaseCode: enabledMissingUrl.databaseCode,
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
