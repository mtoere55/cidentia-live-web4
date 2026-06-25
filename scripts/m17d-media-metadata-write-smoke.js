'use strict';

const { createDatabaseClient } = require('../server/db/databaseClient');
const { createMediaMetadata } = require('../server/media/mediaMetadataRepository');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function requireSmokeGate() {
  const required = [
    'CIDENTIA_MEDIA_METADATA_WRITE_SMOKE',
    'CIDENTIA_MEDIA_METADATA_WRITE_ENABLED',
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_QUERY_ENABLED',
  ];

  const missing = required.filter((key) => !envTrue(key));

  if (missing.length > 0) {
    return Object.freeze({
      ok: false,
      code: 'M17D_SMOKE_GATES_DISABLED',
      missing,
      mediaMetadataCreated: false,
      dbConnected: false,
      queryEnabled: false,
      cleanupDone: false,
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
      dbConnected: false,
      queryEnabled: false,
      cleanupDone: false,
      secretsExposed: false,
    });
  }

  return Object.freeze({
    ok: true,
    code: 'M17D_SMOKE_GATES_READY',
  });
}

async function main() {
  const gate = requireSmokeGate();

  if (!gate.ok) {
    console.log(JSON.stringify(gate, null, 2));
    process.exitCode = 1;
    return;
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const ownerCid = 'Cid-M17D-Metadata-Smoke';
  const storageObjectKey =
    `uploads/${ownerCid}/profile-cover/${timestamp}-m17d-metadata-smoke.jpg`;

  const db = createDatabaseClient(process.env);

  try {
    const result = await createMediaMetadata(
      {
        ownerCid,
        surface: 'profile-cover',
        storageBucket: 'cidentia-live-media',
        storageObjectKey,
        mimeType: 'image/jpeg',
        byteLength: 40,
        uploadStatus: 'uploaded',
      },
      { db },
    );

    let cleanupDone = false;

    if (result.ok && result.mediaAsset && result.mediaAsset.id) {
      const cleanup = await db.query(
        'DELETE FROM cidentia_media_assets WHERE id = $1',
        [result.mediaAsset.id],
      );

      cleanupDone = cleanup.rowCount === 1;
    }

    const report = Object.freeze({
      ok:
        result.ok === true &&
        result.code === 'MEDIA_METADATA_WRITE_OK' &&
        result.mediaMetadataCreated === true &&
        cleanupDone === true &&
        result.dbConnected === true &&
        result.queryEnabled === true &&
        result.secretsExposed === false,
      code: result.code,
      ownerCid,
      surface: result.draft.surface,
      mediaMetadataCreated: result.mediaMetadataCreated,
      mediaAssetIdCreated: Boolean(result.mediaAsset && result.mediaAsset.id),
      cleanupDone,
      dbConnected: result.dbConnected,
      queryEnabled: result.queryEnabled,
      secretsExposed: result.secretsExposed,
      storageObjectKey,
      publicRouteOpened: false,
      profileUpdated: false,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!report.ok) {
      process.exitCode = 1;
    }
  } finally {
    await db.close();
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M17D_MEDIA_METADATA_WRITE_SMOKE_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
