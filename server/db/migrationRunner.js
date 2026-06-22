'use strict';

const fs = require('fs');
const path = require('path');

const { createDatabaseClient } = require('./databaseClient');

function isEnabled(value) {
  return value === 'true' || value === '1';
}

function disabledMigrationResult(code, extra = {}) {
  return Object.freeze({
    ok: false,
    code,
    migrationRunnerEnabled: false,
    migrationExecuted: false,
    dbConnected: false,
    queryExecuted: false,
    secretsExposed: false,
    ...extra,
  });
}

function readMigrationSql(migrationFile = '001_m12a_social_media_foundation.sql') {
  const migrationPath = path.join(__dirname, 'migrations', migrationFile);

  if (!fs.existsSync(migrationPath)) {
    return Object.freeze({
      ok: false,
      code: 'MIGRATION_FILE_NOT_FOUND',
      migrationPath,
      sql: '',
    });
  }

  return Object.freeze({
    ok: true,
    code: 'MIGRATION_FILE_READY',
    migrationPath,
    sql: fs.readFileSync(migrationPath, 'utf8'),
  });
}

async function runGuardedMigration(env = process.env) {
  if (!isEnabled(env.CIDENTIA_DATABASE_MIGRATION_ENABLED)) {
    return disabledMigrationResult('MIGRATION_RUNNER_DISABLED');
  }

  const migration = readMigrationSql();

  if (!migration.ok) {
    return disabledMigrationResult(migration.code, {
      migrationRunnerEnabled: true,
    });
  }

  const client = createDatabaseClient(env);

  if (!client.queryEnabled || client.dbConnected !== true) {
    return disabledMigrationResult('MIGRATION_DB_NOT_CONNECTED', {
      migrationRunnerEnabled: true,
      databaseCode: client.code,
      migrationFileReady: true,
    });
  }

  return disabledMigrationResult('MIGRATION_EXECUTION_NOT_IMPLEMENTED', {
    migrationRunnerEnabled: true,
    migrationFileReady: true,
  });
}

module.exports = {
  readMigrationSql,
  runGuardedMigration,
};
