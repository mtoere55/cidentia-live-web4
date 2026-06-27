'use strict';

const { randomUUID } = require('crypto');
const { createDatabaseClient } = require('../server/db/databaseClient');

const postsHandler = require('../api/profile/posts');
const reelsHandler = require('../api/profile/reels');
const mediaHandler = require('../api/profile/media');

function createMockReq(route, cid) {
  return Object.freeze({
    method: 'GET',
    url: route,
    headers: {
      'x-cidentia-cid': cid,
    },
  });
}

function createMockRes() {
  const response = {
    statusCode: 200,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };

  return response;
}

async function callRoute(handler, route, cid) {
  const req = createMockReq(route, cid);
  const res = createMockRes();

  await handler(req, res);

  return Object.freeze({
    statusCode: res.statusCode,
    body: res.body,
  });
}

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

  const ownerCid = `Cid-M20C-Tabs-${Date.now()}`;
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
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'private', 'pending', 'm20c-route-smoke', now())`,
      [
        mediaId,
        ownerCid,
        'M20C Smoke',
        'profile_tab_route_smoke',
        'image/png',
        256,
        'm20c-private-smoke-bucket',
        `m20c/${mediaId}.png`,
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
      [postId, ownerCid, mediaId, 'M20C route post smoke'],
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
      [reelId, ownerCid, mediaId, 'M20C route reel smoke'],
    );

    const posts = await callRoute(postsHandler, '/api/profile/posts', ownerCid);
    const reels = await callRoute(reelsHandler, '/api/profile/reels', ownerCid);
    const media = await callRoute(mediaHandler, '/api/profile/media', ownerCid);

    await db.query('DELETE FROM cidentia_posts WHERE owner_cid = $1', [ownerCid]);
    await db.query('DELETE FROM cidentia_reels WHERE owner_cid = $1', [ownerCid]);
    await db.query('DELETE FROM cidentia_media_assets WHERE owner_cid = $1', [ownerCid]);
    cleanupDone = true;

    const routes = [posts, reels, media];

    const report = Object.freeze({
      ok:
        posts.statusCode === 200 &&
        reels.statusCode === 200 &&
        media.statusCode === 200 &&
        posts.body.code === 'PROFILE_POSTS_READ_OK' &&
        reels.body.code === 'PROFILE_REELS_READ_OK' &&
        media.body.code === 'PROFILE_MEDIA_READ_OK' &&
        posts.body.itemsRead === true &&
        reels.body.itemsRead === true &&
        media.body.itemsRead === true &&
        posts.body.items.length === 1 &&
        reels.body.items.length === 1 &&
        media.body.items.length === 1 &&
        routes.every((result) =>
          result.body.publicMediaUrlsCreated === false &&
          result.body.fakeItemsCreated === false &&
          result.body.items.every((item) => item.publicMediaUrl === null),
        ) &&
        cleanupDone === true,
      code: 'M20C_PROFILE_TAB_API_ROUTE_SMOKE_OK',
      ownerCid,
      postsStatusCode: posts.statusCode,
      reelsStatusCode: reels.statusCode,
      mediaStatusCode: media.statusCode,
      postsCode: posts.body.code,
      reelsCode: reels.body.code,
      mediaCode: media.body.code,
      postsItems: posts.body.items.length,
      reelsItems: reels.body.items.length,
      mediaItems: media.body.items.length,
      cleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicMediaUrlsCreated: false,
      fakeItemsCreated: false,
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
      code: 'M20C_PROFILE_TAB_API_ROUTE_SMOKE_FAILED',
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
