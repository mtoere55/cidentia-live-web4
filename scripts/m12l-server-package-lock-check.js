'use strict';

const fs = require('fs');
const path = require('path');

const rootPackage = path.join(__dirname, '..', 'package.json');
const rootLock = path.join(__dirname, '..', 'package-lock.json');
const serverPackage = path.join(__dirname, '..', 'server', 'package.json');
const serverLock = path.join(__dirname, '..', 'server', 'package-lock.json');
const databaseClient = path.join(__dirname, '..', 'server', 'db', 'databaseClient.js');

const parsed = JSON.parse(fs.readFileSync(serverPackage, 'utf8'));
const lock = JSON.parse(fs.readFileSync(serverLock, 'utf8'));
const databaseClientText = fs.readFileSync(databaseClient, 'utf8');

const pgDependency = parsed.dependencies?.pg || null;
const lockPg = lock.packages?.['node_modules/pg'] || null;
const databaseClientRequiresPg =
  databaseClientText.includes("require('pg')") ||
  databaseClientText.includes('require("pg")');

const ok =
  fs.existsSync(rootPackage) === false &&
  fs.existsSync(rootLock) === false &&
  fs.existsSync(serverPackage) === true &&
  fs.existsSync(serverLock) === true &&
  typeof pgDependency === 'string' &&
  lockPg !== null &&
  databaseClientRequiresPg === false;

if (!ok) {
  console.error(
    JSON.stringify(
      {
        ok: false,
        rootPackageExists: fs.existsSync(rootPackage),
        rootLockExists: fs.existsSync(rootLock),
        serverPackageExists: fs.existsSync(serverPackage),
        serverLockExists: fs.existsSync(serverLock),
        pgDependency,
        lockPgVersion: lockPg?.version || null,
        databaseClientRequiresPg,
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
      rootPackageExists: false,
      rootLockExists: false,
      serverPackageExists: true,
      serverLockExists: true,
      pgDependency,
      lockPgVersion: lockPg.version,
      databaseClientRequiresPg,
      dbConnected: false,
      queryEnabled: false,
      secretsCommitted: false,
    },
    null,
    2,
  ),
);
