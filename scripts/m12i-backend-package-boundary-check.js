'use strict';

const fs = require('fs');
const path = require('path');

const rootPackage = path.join(__dirname, '..', 'package.json');
const serverPackage = path.join(__dirname, '..', 'server', 'package.json');
const doc = path.join(__dirname, '..', 'docs', 'M12I_BACKEND_PACKAGE_BOUNDARY.md');

const rootPackageExists = fs.existsSync(rootPackage);
const serverPackageExists = fs.existsSync(serverPackage);
const docText = fs.readFileSync(doc, 'utf8');

const requiredMarkers = [
  'There is currently no package.json anywhere in the repository.',
  'Do not add PostgreSQL dependencies blindly.',
  'The preferred direction is `server/package.json`',
  'no pg dependency added',
  'no DATABASE_URL committed',
];

const missing = requiredMarkers.filter((marker) => !docText.includes(marker));

const ok =
  rootPackageExists === false &&
  serverPackageExists === false &&
  missing.length === 0;

if (!ok) {
  console.error(
    JSON.stringify(
      {
        ok: false,
        rootPackageExists,
        serverPackageExists,
        missing,
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
      packageDecision: 'server/package.json preferred, not created in M12I',
      pgDependencyAdded: false,
      secretsCommitted: false,
      dbConnected: false,
    },
    null,
    2,
  ),
);
