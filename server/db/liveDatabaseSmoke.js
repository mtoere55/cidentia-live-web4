'use strict';

const { buildPgPoolConfig, loadPgDriver } = require('./databaseClient');
const { loadDatabaseContract } = require('./databaseContract');

function isEnabled(value) {
  return value === 'true' || value === '1';
}

function disabledResult(code, extra = {}) {
  return Object.freeze({
    ok: false,
    code,
    liveSmokeRequested: false,
    dbConnected: false,
    queryExecuted: false,
    queryEnabled: false,
    secretsExposed: false,
    ...extra,
  });
}

async function runGuardedLiveDatabaseSmoke(env = process.env) {
  if (!isEnabled(env.CIDENTIA_DATABASE_LIVE_SMOKE)) {
    return disabledResult('DATABASE_LIVE_SMOKE_DISABLED');
  }

  const contract = loadDatabaseContract(env);

  if (!contract.databaseEnabled) {
    return disabledResult('DATABASE_DISABLED', {
      liveSmokeRequested: true,
      contract,
    });
  }

  if (!contract.databaseUrlPresent) {
    return disabledResult('DATABASE_URL_MISSING', {
      liveSmokeRequested: true,
      contract,
    });
  }

  const driver = loadPgDriver();

  if (!driver.ok) {
    return disabledResult('PG_DRIVER_NOT_INSTALLED', {
      liveSmokeRequested: true,
      contract,
      pgDriverLoaded: false,
    });
  }

  const poolConfig = buildPgPoolConfig(env);

  if (!poolConfig.connectionStringPresent) {
    return disabledResult('DATABASE_URL_MISSING', {
      liveSmokeRequested: true,
      contract,
      pgDriverLoaded: true,
      poolPrepared: true,
    });
  }

  const pool = new driver.pg.Pool({
    connectionString: env.CIDENTIA_DATABASE_URL,
    ssl: poolConfig.ssl,
    max: 1,
    idleTimeoutMillis: poolConfig.idleTimeoutMillis,
    connectionTimeoutMillis: poolConfig.connectionTimeoutMillis,
  });

  try {
    const result = await pool.query('select 1 as ok');
    return Object.freeze({
      ok: true,
      code: 'DATABASE_LIVE_SMOKE_OK',
      liveSmokeRequested: true,
      pgDriverLoaded: true,
      poolPrepared: true,
      dbConnected: true,
      queryExecuted: true,
      queryEnabled: true,
      rowCount: result.rowCount,
      secretsExposed: false,
    });
  } finally {
    await pool.end();
  }
}

module.exports = {
  runGuardedLiveDatabaseSmoke,
};
