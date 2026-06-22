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

  return createDisabledDatabaseClient('PG_DRIVER_GUARDED_NOT_CONNECTED', contract, {
    pgDriverLoaded: true,
  });
}

module.exports = {
  createDatabaseClient,
  loadPgDriver,
};
