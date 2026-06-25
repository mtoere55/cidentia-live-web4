'use strict';

const {
  createMediaMetadata,
  sanitizeMediaMetadataDraft,
  validateMediaMetadataDraft,
} = require('../server/media/mediaMetadataRepository');

async function main() {
  const draft = sanitizeMediaMetadataDraft({
    ownerCid: 'Cid-M17B-Repository-Check',
    surface: 'profile-cover',
    storageBucket: 'cidentia-live-media',
    storageObjectKey:
      'uploads/Cid-M17B-Repository-Check/profile-cover/m17b-check.jpg',
    mimeType: 'image/jpeg',
    byteLength: 40,
    uploadStatus: 'uploaded',
  });

  const validationCode = validateMediaMetadataDraft(draft);
  const result = await createMediaMetadata(draft, {
    env: {
      CIDENTIA_DATABASE_ENABLED: 'false',
      CIDENTIA_DATABASE_QUERY_ENABLED: 'false',
    },
  });

  const report = Object.freeze({
    ok:
      validationCode === null &&
      result.ok === false &&
      result.mediaMetadataCreated === false &&
      result.dbConnected === false &&
      result.queryEnabled === false &&
      result.secretsExposed === false,
    validationCode,
    resultCode: result.code,
    mediaMetadataCreated: result.mediaMetadataCreated,
    dbConnected: result.dbConnected,
    queryEnabled: result.queryEnabled,
    secretsExposed: result.secretsExposed,
    surface: draft.surface,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
