'use strict';

const assert = require('node:assert/strict');

const {
  createSignedUploadUrl,
  loadObjectStorageConfig,
} = require('../server/media/objectStoragePresignerClient');

function liveSmokeEnabled(env = process.env) {
  return (
    env.CIDENTIA_OBJECT_STORAGE_LIVE_SMOKE === 'true' ||
    env.CIDENTIA_OBJECT_STORAGE_LIVE_SMOKE === '1' ||
    env.CIDENTIA_OBJECT_STORAGE_LIVE_SMOKE === 'yes'
  );
}

function redactUrl(value) {
  if (typeof value !== 'string' || value.length === 0) {
    return null;
  }

  try {
    const parsed = new URL(value);
    return `${parsed.protocol}//${parsed.host}${parsed.pathname}`;
  } catch (_) {
    return '[redacted-url]';
  }
}

async function main() {
  if (!liveSmokeEnabled()) {
    console.log(
      JSON.stringify(
        {
          ok: true,
          check: 'M14D_OBJECT_STORAGE_LIVE_SMOKE_GATE',
          code: 'OBJECT_STORAGE_LIVE_SMOKE_DISABLED',
          liveSmokeEnabled: false,
          signedUploadUrlCreated: false,
          objectStorageWrite: false,
          uploadCreated: false,
          mediaMetadataCreated: false,
          secretsExposed: false,
        },
        null,
        2,
      ),
    );
    return;
  }

  const config = loadObjectStorageConfig(process.env);

  if (!config.ok) {
    console.log(
      JSON.stringify(
        {
          ok: false,
          check: 'M14D_OBJECT_STORAGE_LIVE_SMOKE_GATE',
          code: config.code,
          message: config.message,
          liveSmokeEnabled: true,
          signedUploadUrlCreated: false,
          objectStorageWrite: false,
          uploadCreated: false,
          mediaMetadataCreated: false,
          secretsExposed: false,
        },
        null,
        2,
      ),
    );
    process.exit(1);
  }

  const result = await createSignedUploadUrl({
    ownerCid: 'Cid-M14D-Live-Smoke',
    filename: 'm14d-live-smoke.txt',
    mimeType: 'text/plain',
    surface: 'live-smoke',
    env: process.env,
  });

  assert.equal(result.secretsExposed, false);
  assert.equal(result.objectStorageWrite, false);
  assert.equal(result.uploadCreated, false);
  assert.equal(result.mediaMetadataCreated, false);

  if (!result.ok) {
    console.log(
      JSON.stringify(
        {
          ok: false,
          check: 'M14D_OBJECT_STORAGE_LIVE_SMOKE_GATE',
          code: result.code,
          message: result.message,
          liveSmokeEnabled: true,
          signedUploadUrlCreated: false,
          objectStorageWrite: false,
          uploadCreated: false,
          mediaMetadataCreated: false,
          secretsExposed: false,
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
        check: 'M14D_OBJECT_STORAGE_LIVE_SMOKE_GATE',
        code: result.code,
        liveSmokeEnabled: true,
        signedUploadUrlCreated: result.signedUploadUrlCreated,
        uploadUrlPreview: redactUrl(result.uploadUrl),
        storageBucket: result.storageBucket,
        storageObjectKey: result.storageObjectKey,
        expiresInSeconds: result.expiresInSeconds,
        objectStorageWrite: result.objectStorageWrite,
        uploadCreated: result.uploadCreated,
        mediaMetadataCreated: result.mediaMetadataCreated,
        secretsExposed: result.secretsExposed,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(
    JSON.stringify(
      {
        ok: false,
        check: 'M14D_OBJECT_STORAGE_LIVE_SMOKE_GATE',
        code: 'OBJECT_STORAGE_LIVE_SMOKE_ERROR',
        message: error && error.message ? error.message : 'Live smoke failed.',
        signedUploadUrlCreated: false,
        objectStorageWrite: false,
        uploadCreated: false,
        mediaMetadataCreated: false,
        secretsExposed: false,
      },
      null,
      2,
    ),
  );
  process.exit(1);
});
