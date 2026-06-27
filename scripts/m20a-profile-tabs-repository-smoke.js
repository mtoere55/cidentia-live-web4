'use strict';

const { randomUUID } = require('crypto');
const { createDatabaseClient } = require('../server/db/databaseClient');
const {
  readProfilePostsByCid,
  readProfileReelsByCid,
  readProfileMediaByCid,
} = require('../server/profile/profileTabsRepository');

async function main() {
  const db = createDatabaseClient(process.env);

  if (!db.queryEnabled) {
    console.log(JSON.stringify({
      ok: false,
      code: db.code || 'DATABASE_DISABLED',
      smokeRan: false,
      dbConnected: db.dbConnected === true,
      queryEnabled: db.queryEnabled === true,
      secretsExposed: false,
    }, null, 2));
    process.exitCode = 1;
    return;
  }

  const ownerCid = `Cid-M20A-Tabs-${Date.now()}`;
  const mediaId = randomUUID();
  const postId = randomUUID();
  const reelId = randomUUID();

  let cleanupDone = false;

  try {
    await db.query(
      `INSERT INTO cidentia_media_assets (
        id,
        owner_cid,
        owner_display_name_snapshot,
        media_surface,
        mime_type,
        byte_size,
        storage_bucket,
        storage_object_key,
        visibility,
        moderation_status,
        upload_source,
        created_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'private', 'pending', 'm20a-smoke', now())`,
      [
        mediaId,
        ownerCid,
        'M20A Smoke',
        'profile_tab_smoke',
        'image/png',
        128,
        'm20a-private-smoke-bucket',
        `m20a/${mediaId}.png`,
      ],
    );

    await db.query(
      `INSERT INTO cidentia_posts (
        id,
        owner_cid,
        media_id,
        caption,
        visibility,
        created_at,
        updated_at
      )
      VALUES ($1, $2, $3, $4, 'private', now(), now())`,
      [postId, ownerCid, mediaId, 'M20A repository post smoke'],
    );

    await db.query(
      `INSERT INTO cidentia_reels (
        id,
        owner_cid,
        media_id,
        caption,
        visibility,
        created_at
      )
      VALUES ($1, $2, $3, $4, 'private', now())`,
      [reelId, ownerCid, mediaId, 'M20A repository reel smoke'],
    );

    const posts = await readProfilePostsByCid(ownerCid, { db });
    const reels = await readProfileReelsByCid(ownerCid, { db });
    const media = await readProfileMediaByCid(ownerCid, { db });

    await db.query('DELETE FROM cidentia_posts WHERE owner_cid = $1', [ownerCid]);
    await db.query('DELETE FROM cidentia_reels WHERE owner_cid = $1', [ownerCid]);
    await db.query('DELETE FROM cidentia_media_assets WHERE owner_cid = $1', [ownerCid]);
    cleanupDone = true;

    const report = Object.freeze({
      ok:
        posts.code === 'PROFILE_POSTS_READ_OK' &&
        reels.code === 'PROFILE_REELS_READ_OK' &&
        media.code === 'PROFILE_MEDIA_READ_OK' &&
        posts.itemsRead === true &&
        reels.itemsRead === true &&
        media.itemsRead === true &&
        posts.items.length === 1 &&
        reels.items.length === 1 &&
        media.items.length === 1 &&
        posts.items[0].publicMediaUrl === null &&
        reels.items[0].publicMediaUrl === null &&
        media.items[0].publicMediaUrl === null &&
        cleanupDone === true,
      code: 'M20A_PROFILE_TABS_REPOSITORY_SMOKE_OK',
      ownerCid,
      postsCode: posts.code,
      reelsCode: reels.code,
      mediaCode: media.code,
      postsItems: posts.items.length,
      reelsItems: reels.items.length,
      mediaItems: media.items.length,
      cleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicMediaUrlsCreated: false,
      fakeItemsCreated: false,
      apiRoutesOpened: false,
      flutterOpened: false,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!report.ok) {
      process.exitCode = 1;
    }
  } catch (error) {
    if (!cleanupDone) {
      await db.query('DELETE FROM cidentia_posts WHERE owner_cid = $1', [ownerCid]).catch(() => {});
      await db.query('DELETE FROM cidentia_reels WHERE owner_cid = $1', [ownerCid]).catch(() => {});
      await db.query('DELETE FROM cidentia_media_assets WHERE owner_cid = $1', [ownerCid]).catch(() => {});
    }

    console.error(JSON.stringify({
      ok: false,
      code: 'M20A_PROFILE_TABS_REPOSITORY_SMOKE_FAILED',
      message: error.message,
      cleanupAttempted: true,
      secretsExposed: false,
    }, null, 2));
    process.exitCode = 1;
  } finally {
    await db.close();
  }
}

main();
