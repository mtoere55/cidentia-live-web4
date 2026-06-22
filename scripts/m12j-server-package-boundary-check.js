'use strict';

const fs = require('fs');
const path = require('path');

const rootPackage = path.join(__dirname, '..', 'package.json');
const serverPackage = path.join(__dirname, '..', 'server', 'package.json');

const rootPackageExists = fs.existsSync(rootPackage);
const serverPackageExists = fs.existsSync(serverPackage);
const parsed = JSON.parse(fs.readFileSync(serverPackage, 'utf8'));

const dependencies = parsed.dependencies || {};
const devDependencies = parsed.devDependencies || {};

const pgDependencyAdded =
  Object.prototype.hasOwnProperty.call(dependencies, 'pg') ||
  Object.prototype.hasOwnProperty.call(devDependencies, 'pg');

const ok =
  rootPackageExists === false &&
  serverPackageExists === true &&
  parsed.private === true &&
  parsed.type === 'commonjs' &&
  pgDependencyAdded === false &&
  Object.keys(dependencies).length === 0 &&
  Object.keys(devDependencies).length === 0;

if (!ok) {
  console.error(
    JSON.stringify(
      {
        ok: false,
        rootPackageExists,
        serverPackageExists,
        private: parsed.private,
        type: parsed.type,
        dependencies,
        devDependencies,
        pgDependencyAdded,
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
      rootPackageExists,
      serverPackageExists,
      backendPackageName: parsed.name,
      private: parsed.private,
      type: parsed.type,
      dependencyCount: Object.keys(dependencies).length,
      devDependencyCount: Object.keys(devDependencies).length,
      pgDependencyAdded,
      npmInstallRequired: false,
      dbConnected: false,
      secretsCommitted: false,
    },
    null,
    2,
  ),
);
