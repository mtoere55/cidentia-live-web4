'use strict';

const { loadDatabaseContract } = require('./databaseContract');

function createDisabledDatabaseClient(reason, contract) {
  return Object.freeze({
    ok: false,
    code: reason,
    dbConnected: false,
    migrationExecuted: false,
    queryEnabled: false,
    secretsExposed: false,
    contract,
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

function createDatabaseClient(env = process.env) {
  const contract = loadDatabaseContract(env);

  if (!contract.databaseEnabled) {
    return createDisabledDatabaseClient('DATABASE_DISABLED', contract);
  }

  if (!contract.databaseUrlPresent) {
    return createDisabledDatabaseClient('DATABASE_URL_MISSING', contract);
  }

  return createDisabledDatabaseClient(
    'DATABASE_CLIENT_NOT_IMPLEMENTED',
    contract,
  );
}

module.exports = {
  createDatabaseClient,
};
