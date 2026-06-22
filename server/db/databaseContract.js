'use strict';

const DATABASE_ENV_KEYS = Object.freeze([
  'CIDENTIA_DATABASE_ENABLED',
  'CIDENTIA_DATABASE_URL',
  'CIDENTIA_DATABASE_SSL_MODE',
  'CIDENTIA_DATABASE_POOL_MAX',
]);

function loadDatabaseContract(env = process.env) {
  const databaseUrlPresent =
    typeof env.CIDENTIA_DATABASE_URL === 'string' &&
    env.CIDENTIA_DATABASE_URL.trim().length > 0;

  const deployActive =
    env.CIDENTIA_BACKEND_DEPLOY_ACTIVE === 'true' ||
    env.CIDENTIA_BACKEND_DEPLOY_ACTIVE === '1';

  const productionMode =
    env.CIDENTIA_PRODUCTION_MODE === 'true' ||
    env.CIDENTIA_PRODUCTION_MODE === '1';

  const databaseEnabled =
    env.CIDENTIA_DATABASE_ENABLED === 'true' ||
    env.CIDENTIA_DATABASE_ENABLED === '1';

  return Object.freeze({
    ok: true,
    databaseContractVersion: 'm12e-db-connection-guard-v1',
    databaseUrlPresent,
    databaseEnabled,
    dbConnected: false,
    migrationExecuted: false,
    productionDeploy: deployActive && productionMode,
    secretsExposed: false,
    envKeys: DATABASE_ENV_KEYS,
    locked: Object.freeze({
      databaseLocked: !databaseEnabled,
      migrationLocked: true,
      writeLocked: true,
    }),
  });
}

module.exports = {
  DATABASE_ENV_KEYS,
  loadDatabaseContract,
};
