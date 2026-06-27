'use strict';

const {
  evaluateSignedMediaReadUrlPolicy,
} = require('../server/media/objectStorageReadPresignerClient');

function main() {
  const result = evaluateSignedMediaReadUrlPolicy({
    mediaAsset: {
      id: 'media-m21d-disabled',
      ownerCid: 'Cid-M21D-Media',
      surface: 'profile_cover',
      storageBucket: 'private-bucket',
      storageObjectKey: 'm21d/private.png',
      visibility: 'public',
      moderationStatus: 'approved',
    },
  });

  const report = Object.freeze({
    ok:
      result.ok === false &&
      result.code === 'MEDIA_URL_GENERATION_DISABLED' &&
      result.publicMediaUrl === null &&
      result.signedMediaReadUrl === null &&
      result.publicMediaUrlsCreated === false &&
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
    code: result.code,
    publicMediaUrl: result.publicMediaUrl,
    signedMediaReadUrl: result.signedMediaReadUrl,
    publicMediaUrlsCreated: result.publicMediaUrlsCreated,
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
    uploadPresignerTouched: false,
    apiOpened: false,
    flutterOpened: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main();
