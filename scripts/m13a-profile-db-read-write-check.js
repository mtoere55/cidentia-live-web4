'use strict';

const {
  readProfileByCid,
  upsertProfileByCid,
} = require('../server/profile/profileRepository');

function createFakeDb() {
  const rows = new Map();

  return Object.freeze({
    dbConnected: true,
    queryEnabled: true,
    async query(sql, params = []) {
      if (sql.includes('INSERT INTO cidentia_profiles')) {
        const row = {
          id: params[0],
          owner_cid: params[1],
          display_name: params[2],
          email: params[3],
          bio: params[4],
          avatar_media_id: params[5],
          cover_media_id: params[6],
          created_at: 'created',
          updated_at: 'updated',
        };

        rows.set(params[1], row);

        return Object.freeze({
          ok: true,
          code: 'DATABASE_QUERY_OK',
          rows: [row],
          rowCount: 1,
          dbConnected: true,
        });
      }

      if (sql.includes('FROM cidentia_profiles')) {
        const row = rows.get(params[0]);

        return Object.freeze({
          ok: true,
          code: 'DATABASE_QUERY_OK',
          rows: row ? [row] : [],
          rowCount: row ? 1 : 0,
          dbConnected: true,
        });
      }

      throw new Error('Unexpected SQL in M13A check');
    },
  });
}

async function main() {
  const lockedRead = await readProfileByCid('Cid-Test', { env: {} });
  const lockedWrite = await upsertProfileByCid(
    'Cid-Test',
    { displayName: 'Locked' },
    { env: {} },
  );

  const db = createFakeDb();

  const missing = await readProfileByCid('Cid-Test', { db });
  const write = await upsertProfileByCid(
    'Cid-Test',
    {
      displayName: 'Murat Toere',
      email: 'murat@example.test',
      bio: 'Cidentia profile',
    },
    { db },
  );
  const read = await readProfileByCid('Cid-Test', { db });

  const ok =
    lockedRead.ok === false &&
    lockedRead.code === 'DATABASE_DISABLED' &&
    lockedWrite.ok === false &&
    lockedWrite.code === 'DATABASE_DISABLED' &&
    missing.ok === true &&
    missing.code === 'PROFILE_NOT_FOUND' &&
    write.ok === true &&
    write.code === 'PROFILE_WRITE_OK' &&
    write.profileUpdated === true &&
    write.profile.ownerCid === 'Cid-Test' &&
    write.profile.displayName === 'Murat Toere' &&
    read.ok === true &&
    read.code === 'PROFILE_READ_OK' &&
    read.profile.ownerCid === 'Cid-Test' &&
    read.profile.displayName === 'Murat Toere';

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          lockedRead,
          lockedWrite,
          missing,
          write,
          read,
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
        lockedReadCode: lockedRead.code,
        lockedWriteCode: lockedWrite.code,
        missingCode: missing.code,
        writeCode: write.code,
        readCode: read.code,
        profileUpdated: write.profileUpdated,
        ownerCid: read.profile.ownerCid,
        dbConnected: read.dbConnected,
        queryEnabled: read.queryEnabled,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
