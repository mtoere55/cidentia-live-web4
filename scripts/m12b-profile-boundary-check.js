'use strict';

const { loadDatabaseContract } = require('../server/db/databaseContract');
const {
  profileCidRequiredBoundary,
  profileReadDisabledBoundary,
  profileWriteDisabledBoundary,
} = require('../server/profile/profileBoundary');

const database = loadDatabaseContract({});
const cidRequired = profileCidRequiredBoundary('/api/profile/me');
const readDisabled = profileReadDisabledBoundary('/api/profile/me', 'Cid-Test');
const writeDisabled = profileWriteDisabledBoundary(
  '/api/profile/update',
  'Cid-Test',
);

const ok =
  cidRequired.code === 'PROFILE_CID_REQUIRED' &&
  readDisabled.code === 'PROFILE_READ_DISABLED' &&
  writeDisabled.code === 'PROFILE_WRITE_DISABLED' &&
  database.dbConnected === false &&
  database.locked.writeLocked === true &&
  readDisabled.profileRead === false &&
  writeDisabled.profileUpdated === false;

if (!ok) {
  console.error(
    JSON.stringify(
      {
        ok: false,
        cidRequired,
        readDisabled,
        writeDisabled,
        database,
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
      profileCidRequired: cidRequired.code,
      profileReadDisabled: readDisabled.code,
      profileWriteDisabled: writeDisabled.code,
      dbConnected: database.dbConnected,
      writeLocked: database.locked.writeLocked,
      profileRead: readDisabled.profileRead,
      profileUpdated: writeDisabled.profileUpdated,
    },
    null,
    2,
  ),
);
