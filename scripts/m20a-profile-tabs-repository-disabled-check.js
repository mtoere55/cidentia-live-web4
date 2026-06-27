'use strict';

const {
  readProfilePostsByCid,
  readProfileReelsByCid,
  readProfileMediaByCid,
} = require('../server/profile/profileTabsRepository');

async function main() {
  const env = {
    CIDENTIA_DATABASE_ENABLED: 'false',
    CIDENTIA_DATABASE_QUERY_ENABLED: 'false',
    CIDENTIA_DATABASE_URL: '',
  };

  const missingCid = await readProfilePostsByCid('', { env });
  const posts = await readProfilePostsByCid('Cid-M20A-Tabs', { env });
  const reels = await readProfileReelsByCid('Cid-M20A-Tabs', { env });
  const media = await readProfileMediaByCid('Cid-M20A-Tabs', { env });

  const lockedResults = [posts, reels, media];

  const report = Object.freeze({
    ok:
      missingCid.code === 'PROFILE_CID_REQUIRED' &&
      lockedResults.every((result) =>
        result.ok === false &&
        result.code === 'DATABASE_DISABLED' &&
        result.itemsRead === false &&
        Array.isArray(result.items) &&
        result.items.length === 0 &&
        result.dbConnected === false &&
        result.queryEnabled === false &&
        result.secretsExposed === false,
      ),
    missingCidCode: missingCid.code,
    postsCode: posts.code,
    reelsCode: reels.code,
    mediaCode: media.code,
    postsItemsRead: posts.itemsRead,
    reelsItemsRead: reels.itemsRead,
    mediaItemsRead: media.itemsRead,
    postsItems: posts.items.length,
    reelsItems: reels.items.length,
    mediaItems: media.items.length,
    dbConnected: lockedResults.some((result) => result.dbConnected === true),
    queryEnabled: lockedResults.some((result) => result.queryEnabled === true),
    secretsExposed: lockedResults.some((result) => result.secretsExposed === true),
    publicMediaUrlsCreated: false,
    fakeItemsCreated: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M20A_PROFILE_TABS_REPOSITORY_DISABLED_CHECK_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
