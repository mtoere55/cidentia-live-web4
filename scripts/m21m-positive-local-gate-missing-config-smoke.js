'use strict';

const {
  createSignedMediaReadUrl,
  loadObjectStorageReadConfig,
} = require('../server/media/objectStorageReadPresignerClient');

async function main() {
  const positiveGatesMissingConfigEnv = Object.freeze({
    CIDENTIA_MEDIA_URL_GENERATION_ENABLED: 'true',
    CIDENTIA_OBJECT_STORAGE_READ_ENABLED: 'true',
    CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED: 'true',
  });

  const config = loadObjectStorageReadConfig(positiveGatesMissingConfigEnv);

  const result = await createSignedMediaReadUrl({
    mediaAsset: {
      id: 'media-m21m-missing-config',
      ownerCid: 'Cid-M21M-Media',
      surface: 'profile_cover',
      storageBucket: 'private-bucket',
      storageObjectKey: 'm21m/private.png',
      visibility: 'public',
      moderationStatus: 'approved',
    },
    env: positiveGatesMissingConfigEnv,
  });

  const report = Object.freeze({
    ok:
      config.ok === false &&
      config.code === 'OBJECT_STORAGE_READ_CONFIG_MISSING' &&
      result.ok === false &&
      result.code === 'OBJECT_STORAGE_READ_CONFIG_MISSING' &&
      result.publicMediaUrl === null &&
      result.signedMediaReadUrl === null &&
      result.signedMediaReadUrlCreated === false &&
      result.storageSignedUrlCreated === false &&
      result.objectStorageCalled === false &&
      result.objectStorageRead === false &&
      result.objectStorageWrite === false &&
      result.storageBucketExposed === false &&
      result.storageObjectKeyExposed === false &&
      result.storageSecretExposed === false &&
      result.frontendSecretExposed === false &&
      result.secretsExposed === false,
    code: 'M21M_POSITIVE_LOCAL_GATE_MISSING_CONFIG_SMOKE',
    configCode: config.code,
    resultCode: result.code,
    missing: config.missing,
    mediaUrlGenerationEnabled: result.mediaUrlGenerationEnabled,
    objectStorageReadEnabled: result.objectStorageReadEnabled,
    signedMediaReadUrlEnabled: result.signedMediaReadUrlEnabled,
    signedMediaReadUrl: result.signedMediaReadUrl,
    signedMediaReadUrlCreated: result.signedMediaReadUrlCreated,
    storageSignedUrlCreated: result.storageSignedUrlCreated,
    objectStorageCalled: result.objectStorageCalled,
    objectStorageRead: result.objectStorageRead,
    objectStorageWrite: result.objectStorageWrite,
    storageBucketExposed: result.storageBucketExposed,
    storageObjectKeyExposed: result.storageObjectKeyExposed,
    storageSecretExposed: result.storageSecretExposed,
    frontendSecretExposed: result.frontendSecretExposed,
    secretsExposed: result.secretsExposed,
    signedUrlGenerated: false,
    packageChanged: false,
    apiOpened: false,
    flutterOpened: false,
    vpsEnvChanged: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main();
