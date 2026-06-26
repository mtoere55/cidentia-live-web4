'use strict';

const { randomUUID } = require('crypto');
const statsHandler = require('../api/profile/stats');
const { createDatabaseClient } = require('../server/db/databaseClient');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function requireSmokeGate() {
  const required = [
    'CIDENTIA_PROFILE_STATS_API_ROUTE_SMOKE',
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_QUERY_ENABLED',
  ];

  const missing = required.filter((key) => !envTrue(key));

  if (missing.length > 0) {
    return Object.freeze({
      ok: false,
      code: 'M19D_SMOKE_GATES_DISABLED',
      missing,
      routeRead: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  if (
    typeof process.env.CIDENTIA_DATABASE_URL !== 'string' ||
    process.env.CIDENTIA_DATABASE_URL.trim().length === 0
  ) {
    return Object.freeze({
      ok: false,
      code: 'DATABASE_URL_MISSING',
      routeRead: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  return Object.freeze({
    ok: true,
    code: 'M19D_SMOKE_GATES_READY',
  });
}

function createResponse() {
  return {
    statusCode: 200,
    payload: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.payload = payload;
      return this;
    },
  };
}

async function callStatsRoute(ownerCid) {
  const req = {
    method: 'GET',
    headers: {
      'x-cidentia-cid': ownerCid,
    },
    query: {},
  };
  const res = createResponse();

  await statsHandler(req, res);

  return res;
}

async function main() {
  const gate = requireSmokeGate();

  if (!gate.ok) {
    console.log(JSON.stringify(gate, null, 2));
    process.exitCode = 1;
    return;
  }

  const ownerCid = 'Cid-M19D-Stats-Route-Smoke';
  const followerCid = 'Cid-M19D-Stats-Route-Follower';
  const followingTargetCid = 'Cid-M19D-Stats-Route-Following';
  const db = createDatabaseClient(process.env);
  let cleanupDone = false;

  try {
    await db.query('DELETE FROM cidentia_posts WHERE owner_cid = $1', [
      ownerCid,
    ]);
    await db.query('DELETE FROM cidentia_reels WHERE owner_cid = $1', [
      ownerCid,
    ]);
    await db.query('DELETE FROM cidentia_media_assets WHERE owner_cid = $1', [
      ownerCid,
    ]);
    await db.query(
      `DELETE FROM cidentia_follows
        WHERE follower_cid IN ($1, $2, $3)
           OR followed_cid IN ($1, $2, $3)`,
      [ownerCid, followerCid, followingTargetCid],
    );

    await db.query(
      `INSERT INTO cidentia_posts (
        id, owner_cid, media_id, caption, visibility, created_at, updated_at
      ) VALUES
        ($1, $2, null, 'M19D route smoke post 1', 'private', now(), now()),
        ($3, $2, null, 'M19D route smoke post 2', 'private', now(), now())`,
      [randomUUID(), ownerCid, randomUUID()],
    );

    await db.query(
      `INSERT INTO cidentia_reels (
        id, owner_cid, media_id, caption, visibility, created_at
      ) VALUES
        ($1, $2, null, 'M19D route smoke reel', 'private', now())`,
      [randomUUID(), ownerCid],
    );

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
      ) VALUES
        ($1, $2, 'M19D Stats Route Smoke', 'profile_cover', 'image/jpeg', 42, 'cidentia-live-media', $3, 'private', 'pending', 'm19d_smoke', now()),
        ($4, $2, 'M19D Stats Route Smoke', 'post_media', 'image/jpeg', 43, 'cidentia-live-media', $5, 'private', 'pending', 'm19d_smoke', now()),
        ($6, $2, 'M19D Stats Route Smoke', 'reel_media', 'video/mp4', 44, 'cidentia-live-media', $7, 'private', 'pending', 'm19d_smoke', now())`,
      [
        randomUUID(),
        ownerCid,
        `uploads/${ownerCid}/m19d/profile-cover-smoke.jpg`,
        randomUUID(),
        `uploads/${ownerCid}/m19d/post-smoke.jpg`,
        randomUUID(),
        `uploads/${ownerCid}/m19d/reel-smoke.mp4`,
      ],
    );

    await db.query(
      `INSERT INTO cidentia_follows (
        id, follower_cid, followed_cid, created_at
      ) VALUES
        ($1, $2, $3, now()),
        ($4, $5, $6, now())
      ON CONFLICT (follower_cid, followed_cid)
      DO NOTHING`,
      [
        randomUUID(),
        followerCid,
        ownerCid,
        randomUUID(),
        ownerCid,
        followingTargetCid,
      ],
    );

    const routeResult = await callStatsRoute(ownerCid);
    const payload = routeResult.payload || {};

    await db.query('DELETE FROM cidentia_posts WHERE owner_cid = $1', [
      ownerCid,
    ]);
    await db.query('DELETE FROM cidentia_reels WHERE owner_cid = $1', [
      ownerCid,
    ]);
    await db.query('DELETE FROM cidentia_media_assets WHERE owner_cid = $1', [
      ownerCid,
    ]);
    await db.query(
      `DELETE FROM cidentia_follows
        WHERE follower_cid IN ($1, $2, $3)
           OR followed_cid IN ($1, $2, $3)`,
      [ownerCid, followerCid, followingTargetCid],
    );

    const remaining = await db.query(
      `SELECT
        (SELECT COUNT(*)::int FROM cidentia_posts WHERE owner_cid = $1) AS posts,
        (SELECT COUNT(*)::int FROM cidentia_reels WHERE owner_cid = $1) AS reels,
        (SELECT COUNT(*)::int FROM cidentia_media_assets WHERE owner_cid = $1) AS media,
        (SELECT COUNT(*)::int FROM cidentia_follows
          WHERE follower_cid IN ($1, $2, $3)
             OR followed_cid IN ($1, $2, $3)) AS follows`,
      [ownerCid, followerCid, followingTargetCid],
    );

    const cleanupRow = remaining.rows[0] || {};
    cleanupDone =
      Number(cleanupRow.posts || 0) === 0 &&
      Number(cleanupRow.reels || 0) === 0 &&
      Number(cleanupRow.media || 0) === 0 &&
      Number(cleanupRow.follows || 0) === 0;

    const report = Object.freeze({
      ok:
        routeResult.statusCode === 200 &&
        payload.ok === true &&
        payload.code === 'PROFILE_STATS_READ_OK' &&
        payload.statsRead === true &&
        payload.postsCount === 2 &&
        payload.reelsCount === 1 &&
        payload.mediaCount === 3 &&
        payload.followersCount === 1 &&
        payload.followingCount === 1 &&
        payload.trustScore === null &&
        cleanupDone === true,
      code: 'M19D_PROFILE_STATS_API_ROUTE_SMOKE_OK',
      routeStatusCode: routeResult.statusCode,
      routeCode: payload.code,
      ownerCid,
      statsRead: payload.statsRead,
      postsCount: payload.postsCount,
      reelsCount: payload.reelsCount,
      mediaCount: payload.mediaCount,
      followersCount: payload.followersCount,
      followingCount: payload.followingCount,
      trustScore: payload.trustScore,
      cleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicStatsRouteDefaultOpened: false,
      flutterStatsOpened: false,
      fakeCountersCreated: false,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!report.ok) {
      process.exitCode = 1;
    }
  } finally {
    if (!cleanupDone) {
      await db.query('DELETE FROM cidentia_posts WHERE owner_cid = $1', [
        ownerCid,
      ]);
      await db.query('DELETE FROM cidentia_reels WHERE owner_cid = $1', [
        ownerCid,
      ]);
      await db.query('DELETE FROM cidentia_media_assets WHERE owner_cid = $1', [
        ownerCid,
      ]);
      await db.query(
        `DELETE FROM cidentia_follows
          WHERE follower_cid IN ($1, $2, $3)
             OR followed_cid IN ($1, $2, $3)`,
        [ownerCid, followerCid, followingTargetCid],
      );
    }

    await db.close();
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M19D_PROFILE_STATS_API_ROUTE_SMOKE_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
