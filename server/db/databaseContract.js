'use strict';

const DATABASE_ENV_KEYS = Object.freeze([
  'CIDENTIA_DATABASE_ENABLED',
  'CIDENTIA_DATABASE_QUERY_ENABLED',
  'CIDENTIA_DATABASE_URL',
  'CIDENTIA_DATABASE_SSL_MODE',
  'CIDENTIA_DATABASE_POOL_MAX',
]);

function envTrue(env, key) {
  return env[key] === 'true' || env[key] === '1';
}

function loadDatabaseContract(env = process.env) {
  const databaseUrlPresent =
    typeof env.CIDENTIA_DATABASE_URL === 'string' &&
    env.CIDENTIA_DATABASE_URL.trim().length > 0;

  const deployActive = envTrue(env, 'CIDENTIA_BACKEND_DEPLOY_ACTIVE');
  const productionMode = envTrue(env, 'CIDENTIA_PRODUCTION_MODE');
  const databaseEnabled = envTrue(env, 'CIDENTIA_DATABASE_ENABLED');
  const queryEnabled = envTrue(env, 'CIDENTIA_DATABASE_QUERY_ENABLED');

  return Object.freeze({
    ok: true,
    databaseContractVersion: 'm13a-profile-db-read-write-v1',
    databaseUrlPresent,
    databaseEnabled,
    queryEnabled,
    dbConnected: false,
    migrationExecuted: false,
    productionDeploy: deployActive && productionMode,
    secretsExposed: false,
    envKeys: DATABASE_ENV_KEYS,
    locked: Object.freeze({
      databaseLocked: !databaseEnabled,
      queryLocked: !queryEnabled,
      migrationLocked: true,
      writeLocked: !queryEnabled,
    }),
  });
}

module.exports = {
  DATABASE_ENV_KEYS,
  loadDatabaseContract,
};
