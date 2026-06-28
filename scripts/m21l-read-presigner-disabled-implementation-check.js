'use strict';

const {
  createSignedMediaReadUrl,
  loadAwsS3ReadPresignerDriver,
  loadObjectStorageReadConfig,
} = require('../server/media/objectStorageReadPresignerClient');

async function main() {
  const disabledConfig = loadObjectStorageReadConfig({});

  const disabledResult = await createSignedMediaReadUrl({
    mediaAsset: {
      id: 'media-m21l-disabled',
      ownerCid: 'Cid-M21L-Media',
      surface: 'profile_cover',
      storageBucket: 'private-bucket',
      storageObjectKey: 'm21l/private.png',
      visibility: 'public',
      moderationStatus: 'approved',
    },
    env: {},
  });

  const driver = loadAwsS3ReadPresignerDriver();

  const report = Object.freeze({
    ok:
      disabledConfig.ok === false &&
      disabledConfig.code === 'SIGNED_MEDIA_READ_URL_DISABLED' &&
      disabledResult.ok === false &&
      disabledResult.code === 'SIGNED_MEDIA_READ_URL_DISABLED' &&
      disabledResult.publicMediaUrl === null &&
      disabledResult.signedMediaReadUrl === null &&
      disabledResult.signedMediaReadUrlCreated === false &&
      disabledResult.storageSignedUrlCreated === false &&
      disabledResult.objectStorageCalled === false &&
      disabledResult.objectStorageRead === false &&
      disabledResult.objectStorageWrite === false &&
      disabledResult.storageBucketExposed === false &&
      disabledResult.storageObjectKeyExposed === false &&
      disabledResult.storageSecretExposed === false &&
      disabledResult.frontendSecretExposed === false &&
      disabledResult.secretsExposed === false &&
      driver.ok === true &&
      driver.s3ClientCreated === false &&
      driver.getObjectCommandCreated === false &&
      driver.signedUrlGenerated === false,
    code: 'M21L_READ_PRESIGNER_DISABLED_IMPLEMENTATION_CHECK',
    disabledConfigCode: disabledConfig.code,
    disabledResultCode: disabledResult.code,
    driverImportable: driver.ok,
    signedMediaReadUrl: disabledResult.signedMediaReadUrl,
    signedMediaReadUrlCreated: disabledResult.signedMediaReadUrlCreated,
    storageSignedUrlCreated: disabledResult.storageSignedUrlCreated,
    objectStorageCalled: disabledResult.objectStorageCalled,
    objectStorageRead: disabledResult.objectStorageRead,
    objectStorageWrite: disabledResult.objectStorageWrite,
    storageBucketExposed: disabledResult.storageBucketExposed,
    storageObjectKeyExposed: disabledResult.storageObjectKeyExposed,
    storageSecretExposed: disabledResult.storageSecretExposed,
    frontendSecretExposed: disabledResult.frontendSecretExposed,
    s3ClientCreated: driver.s3ClientCreated,
    getObjectCommandCreated: driver.getObjectCommandCreated,
    signedUrlGenerated: driver.signedUrlGenerated,
    secretsExposed: disabledResult.secretsExposed,
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
