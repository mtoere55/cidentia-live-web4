'use strict';

const { createDatabaseClient } = require('../server/db/databaseClient');
const { createMediaMetadata } = require('../server/media/mediaMetadataRepository');
const {
  readProfileByCid,
  upsertProfileByCid,
} = require('../server/profile/profileRepository');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function requireSmokeGate() {
  const required = [
    'CIDENTIA_PROFILE_COVER_PERSISTENCE_SMOKE',
    'CIDENTIA_MEDIA_METADATA_WRITE_ENABLED',
    'CIDENTIA_PROFILE_WRITE_ENABLED',
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_QUERY_ENABLED',
  ];

  const missing = required.filter((key) => !envTrue(key));

  if (missing.length > 0) {
    return Object.freeze({
      ok: false,
      code: 'M17E_SMOKE_GATES_DISABLED',
      missing,
      mediaMetadataCreated: false,
      profileUpdated: false,
      profileRead: false,
      coverLinked: false,
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
      mediaMetadataCreated: false,
      profileUpdated: false,
      profileRead: false,
      coverLinked: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  return Object.freeze({
    ok: true,
    code: 'M17E_SMOKE_GATES_READY',
  });
}

async function main() {
  const gate = requireSmokeGate();

  if (!gate.ok) {
    console.log(JSON.stringify(gate, null, 2));
    process.exitCode = 1;
    return;
  }

  const ownerCid = 'Cid-M17E-Profile-Cover-Smoke';
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const storageObjectKey =
    `uploads/${ownerCid}/profile-cover/${timestamp}-m17e-profile-cover-smoke.jpg`;

  const db = createDatabaseClient(process.env);
  let mediaAssetId = null;
  let profileCleanupDone = false;
  let mediaCleanupDone = false;

  try {
    await db.query('DELETE FROM cidentia_profiles WHERE owner_cid = $1', [
      ownerCid,
    ]);

    const mediaResult = await createMediaMetadata(
      {
        ownerCid,
        surface: 'profile-cover',
        storageBucket: 'cidentia-live-media',
        storageObjectKey,
        mimeType: 'image/jpeg',
        byteLength: 41,
        uploadStatus: 'uploaded',
      },
      { db },
    );

    if (!mediaResult.ok || !mediaResult.mediaAsset || !mediaResult.mediaAsset.id) {
      console.log(JSON.stringify({
        ok: false,
        code: mediaResult.code || 'M17E_MEDIA_METADATA_CREATE_FAILED',
        mediaMetadataCreated: mediaResult.mediaMetadataCreated === true,
        profileUpdated: false,
        profileRead: false,
        coverLinked: false,
        cleanupDone: false,
        dbConnected: mediaResult.dbConnected === true,
        queryEnabled: mediaResult.queryEnabled === true,
        secretsExposed: false,
      }, null, 2));
      process.exitCode = 1;
      return;
    }

    mediaAssetId = mediaResult.mediaAsset.id;

    const writeResult = await upsertProfileByCid(
      ownerCid,
      {
        displayName: 'M17E Profile Cover Smoke',
        email: 'm17e-smoke@cidentia.live',
        bio: 'M17E guarded profile cover persistence smoke',
        coverMediaId: mediaAssetId,
      },
      { db },
    );

    const readResult = await readProfileByCid(ownerCid, { db });

    const coverLinked =
      readResult.ok === true &&
      readResult.profileRead === true &&
      readResult.profile &&
      readResult.profile.coverMediaId === mediaAssetId;

    const profileCleanup = await db.query(
      'DELETE FROM cidentia_profiles WHERE owner_cid = $1',
      [ownerCid],
    );
    profileCleanupDone = profileCleanup.rowCount === 1;

    const mediaCleanup = await db.query(
      'DELETE FROM cidentia_media_assets WHERE id = $1',
      [mediaAssetId],
    );
    mediaCleanupDone = mediaCleanup.rowCount === 1;

    const report = Object.freeze({
      ok:
        mediaResult.code === 'MEDIA_METADATA_WRITE_OK' &&
        mediaResult.mediaMetadataCreated === true &&
        writeResult.code === 'PROFILE_WRITE_OK' &&
        writeResult.profileUpdated === true &&
        readResult.code === 'PROFILE_READ_OK' &&
        coverLinked === true &&
        profileCleanupDone === true &&
        mediaCleanupDone === true,
      code: 'M17E_PROFILE_COVER_PERSISTENCE_OK',
      ownerCid,
      mediaAssetIdCreated: true,
      mediaMetadataCreated: mediaResult.mediaMetadataCreated,
      profileUpdated: writeResult.profileUpdated,
      profileRead: readResult.profileRead,
      coverLinked,
      profileCleanupDone,
      mediaCleanupDone,
      cleanupDone: profileCleanupDone && mediaCleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicRouteOpened: false,
      flutterPersistenceOpened: false,
      storageObjectKey,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!report.ok) {
      process.exitCode = 1;
    }
  } finally {
    if (!profileCleanupDone) {
      await db.query('DELETE FROM cidentia_profiles WHERE owner_cid = $1', [
        ownerCid,
      ]);
    }

    if (mediaAssetId && !mediaCleanupDone) {
      await db.query('DELETE FROM cidentia_media_assets WHERE id = $1', [
        mediaAssetId,
      ]);
    }

    await db.close();
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M17E_PROFILE_COVER_PERSISTENCE_SMOKE_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
