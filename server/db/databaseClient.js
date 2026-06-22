'use strict';

const { loadDatabaseContract } = require('./databaseContract');

function createDisabledDatabaseClient(reason, contract, extra = {}) {
  return Object.freeze({
    ok: false,
    code: reason,
    dbConnected: false,
    migrationExecuted: false,
    queryEnabled: false,
    secretsExposed: false,
    contract,
    ...extra,
    async query() {
      return Object.freeze({
        ok: false,
        code: reason,
        rows: [],
        rowCount: 0,
        dbConnected: false,
      });
    },
    async close() {
      return Object.freeze({
        ok: true,
        dbConnected: false,
      });
    },
  });
}

function loadPgDriver() {
  try {
    // Loaded only after DB env gates pass. Do not move this to top-level.
    return {
      ok: true,
      pg: require('pg'),
    };
  } catch (_) {
    return {
      ok: false,
      pg: null,
    };
  }
}

function buildPgPoolConfig(env = process.env) {
  const sslMode = env.CIDENTIA_DATABASE_SSL_MODE || 'require';
  const maxRaw = Number(env.CIDENTIA_DATABASE_POOL_MAX || 5);
  const max = Number.isFinite(maxRaw) && maxRaw > 0 ? maxRaw : 5;

  return Object.freeze({
    connectionStringPresent:
      typeof env.CIDENTIA_DATABASE_URL === 'string' &&
      env.CIDENTIA_DATABASE_URL.trim().length > 0,
    ssl: sslMode === 'disable' ? false : { rejectUnauthorized: false },
    max,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
    secretsExposed: false,
  });
}

function createDatabaseClient(env = process.env) {
  const contract = loadDatabaseContract(env);

  if (!contract.databaseEnabled) {
    return createDisabledDatabaseClient('DATABASE_DISABLED', contract);
  }

  if (!contract.databaseUrlPresent) {
    return createDisabledDatabaseClient('DATABASE_URL_MISSING', contract);
  }

  const driver = loadPgDriver();

  if (!driver.ok) {
    return createDisabledDatabaseClient('PG_DRIVER_NOT_INSTALLED', contract, {
      pgDriverLoaded: false,
    });
  }

  const poolConfig = buildPgPoolConfig(env);

  return createDisabledDatabaseClient('PG_POOL_GUARDED_NOT_CONNECTED', contract, {
    pgDriverLoaded: true,
    poolPrepared: true,
    poolConfig,
  });
}

module.exports = {
  buildPgPoolConfig,
  createDatabaseClient,
  loadPgDriver,
};
