'use strict';

const {
  sanitizeProfileDraft,
  readProfileByCid,
  upsertProfileByCid,
} = require('../server/profile/profileRepository');

async function main() {
  const draft = sanitizeProfileDraft({
    displayName: '  Murat Toere  ',
    email: '  mtoere55@gmail.com  ',
    bio: '  Cidentia creator  ',
  });

  const readResult = await readProfileByCid('Cid-Test', { env: {} });
  const writeResult = await upsertProfileByCid('Cid-Test', draft, { env: {} });

  const ok =
    draft.displayName === 'Murat Toere' &&
    draft.email === 'mtoere55@gmail.com' &&
    readResult.code === 'DATABASE_DISABLED' &&
    writeResult.code === 'DATABASE_DISABLED' &&
    readResult.profileRead === false &&
    writeResult.profileUpdated === false &&
    readResult.dbConnected === false &&
    writeResult.queryEnabled === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          draft,
          readResult,
          writeResult,
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
        draft,
        readCode: readResult.code,
        writeCode: writeResult.code,
        profileRead: readResult.profileRead,
        profileUpdated: writeResult.profileUpdated,
        dbConnected: readResult.dbConnected,
        queryEnabled: writeResult.queryEnabled,
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
