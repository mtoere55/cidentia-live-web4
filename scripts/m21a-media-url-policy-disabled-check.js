'use strict';

const {
  evaluateMediaUrlPolicy,
} = require('../server/media/mediaUrlPolicy');

function main() {
  const mediaAsset = {
    id: 'media-m21a-disabled',
    ownerCid: 'Cid-M21A-Media',
    surface: 'profile_cover',
    storageBucket: 'private-bucket',
    storageObjectKey: 'm21a/private.png',
    visibility: 'public',
    moderationStatus: 'approved',
  };

  const result = evaluateMediaUrlPolicy({ mediaAsset });

  const report = Object.freeze({
    ok:
      result.ok === false &&
      result.code === 'MEDIA_URL_GENERATION_DISABLED' &&
      result.publicMediaUrl === null &&
      result.publicMediaUrlsCreated === false &&
      result.storageSignedUrlCreated === false &&
      result.storageBucketExposed === false &&
      result.storageSecretExposed === false &&
      result.frontendSecretExposed === false &&
      result.secretsExposed === false,
    code: result.code,
    publicMediaUrl: result.publicMediaUrl,
    publicMediaUrlsCreated: result.publicMediaUrlsCreated,
    storageSignedUrlCreated: result.storageSignedUrlCreated,
    storageBucketExposed: result.storageBucketExposed,
    storageSecretExposed: result.storageSecretExposed,
    frontendSecretExposed: result.frontendSecretExposed,
    secretsExposed: result.secretsExposed,
    signedUrlGenerationOpened: false,
    objectStorageCalled: false,
    flutterOpened: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main();
