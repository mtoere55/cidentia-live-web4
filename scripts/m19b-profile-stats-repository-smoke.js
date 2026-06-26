'use strict';

const { randomUUID } = require('crypto');
const { createDatabaseClient } = require('../server/db/databaseClient');
const { readProfileStatsByCid } = require('../server/profile/profileStatsRepository');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function requireSmokeGate() {
  const required = [
    'CIDENTIA_PROFILE_STATS_REPOSITORY_SMOKE',
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_QUERY_ENABLED',
  ];

  const missing = required.filter((key) => !envTrue(key));

  if (missing.length > 0) {
    return Object.freeze({
      ok: false,
      code: 'M19B_SMOKE_GATES_DISABLED',
      missing,
      statsRead: false,
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
      statsRead: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  return Object.freeze({
    ok: true,
    code: 'M19B_SMOKE_GATES_READY',
  });
}

async function main() {
  const gate = requireSmokeGate();

  if (!gate.ok) {
    console.log(JSON.stringify(gate, null, 2));
    process.exitCode = 1;
    return;
  }

  const ownerCid = 'Cid-M19B-Stats-Smoke';
  const followerCid = 'Cid-M19B-Stats-Follower';
  const followingTargetCid = 'Cid-M19B-Stats-Following';
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
        ($1, $2, null, 'M19B stats smoke post 1', 'private', now(), now()),
        ($3, $2, null, 'M19B stats smoke post 2', 'private', now(), now())`,
      [randomUUID(), ownerCid, randomUUID()],
    );

    await db.query(
      `INSERT INTO cidentia_reels (
        id, owner_cid, media_id, caption, visibility, created_at
      ) VALUES
        ($1, $2, null, 'M19B stats smoke reel', 'private', now())`,
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
        ($1, $2, 'M19B Stats Smoke', 'profile_cover', 'image/jpeg', 42, 'cidentia-live-media', $3, 'private', 'pending', 'm19b_smoke', now()),
        ($4, $2, 'M19B Stats Smoke', 'post_media', 'image/jpeg', 43, 'cidentia-live-media', $5, 'private', 'pending', 'm19b_smoke', now()),
        ($6, $2, 'M19B Stats Smoke', 'reel_media', 'video/mp4', 44, 'cidentia-live-media', $7, 'private', 'pending', 'm19b_smoke', now())`,
      [
        randomUUID(),
        ownerCid,
        `uploads/${ownerCid}/m19b/profile-cover-smoke.jpg`,
        randomUUID(),
        `uploads/${ownerCid}/m19b/post-smoke.jpg`,
        randomUUID(),
        `uploads/${ownerCid}/m19b/reel-smoke.mp4`,
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

    const stats = await readProfileStatsByCid(ownerCid, { db });

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
        stats.ok === true &&
        stats.code === 'PROFILE_STATS_READ_OK' &&
        stats.statsRead === true &&
        stats.postsCount === 2 &&
        stats.reelsCount === 1 &&
        stats.mediaCount === 3 &&
        stats.followersCount === 1 &&
        stats.followingCount === 1 &&
        stats.trustScore === null &&
        cleanupDone === true,
      code: 'M19B_PROFILE_STATS_REPOSITORY_SMOKE_OK',
      ownerCid,
      statsCode: stats.code,
      statsRead: stats.statsRead,
      postsCount: stats.postsCount,
      reelsCount: stats.reelsCount,
      mediaCount: stats.mediaCount,
      followersCount: stats.followersCount,
      followingCount: stats.followingCount,
      trustScore: stats.trustScore,
      cleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicStatsRouteOpened: false,
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
    code: 'M19B_PROFILE_STATS_REPOSITORY_SMOKE_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});


