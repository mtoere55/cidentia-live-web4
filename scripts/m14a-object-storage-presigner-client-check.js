'use strict';

const assert = require('node:assert/strict');

const {
  buildUploadObjectKey,
  createSignedUploadUrl,
  loadAwsS3PresignerDriver,
  loadObjectStorageConfig,
} = require('../server/media/objectStoragePresignerClient');

async function main() {
  const defaultConfig = loadObjectStorageConfig({});

  assert.equal(defaultConfig.ok, false);
  assert.equal(defaultConfig.code, 'OBJECT_STORAGE_PRESIGNER_DISABLED');

  const missingConfig = loadObjectStorageConfig({
    CIDENTIA_UPLOAD_ENABLED: 'true',
    CIDENTIA_OBJECT_STORAGE_ENABLED: 'true',
    CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED: 'true',
    CIDENTIA_SIGNED_URL_ENABLED: 'true',
  });

  assert.equal(missingConfig.ok, false);
  assert.equal(missingConfig.code, 'OBJECT_STORAGE_CONFIG_MISSING');
  assert.ok(
    missingConfig.missing.includes('CIDENTIA_OBJECT_STORAGE_ENDPOINT'),
  );
  assert.ok(missingConfig.missing.includes('CIDENTIA_OBJECT_STORAGE_BUCKET'));
  assert.ok(
    missingConfig.missing.includes('CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID'),
  );
  assert.ok(
    missingConfig.missing.includes(
      'CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY',
    ),
  );

  const driver = loadAwsS3PresignerDriver();
  assert.equal(driver.ok, true);

  const objectKey = buildUploadObjectKey({
    ownerCid: 'Cid-26-00004',
    surface: 'profile-avatar',
    filename: 'Murat Töre avatar.png',
    now: new Date('2026-06-24T00:00:00.000Z'),
  });

  assert.equal(
    objectKey,
    'uploads/Cid-26-00004/profile-avatar/2026-06-24T00-00-00-000Z-Murat-T-re-avatar.png',
  );

  const noCid = await createSignedUploadUrl({
    ownerCid: '',
    filename: 'avatar.png',
    mimeType: 'image/png',
    surface: 'profile-avatar',
    env: {},
  });

  assert.equal(noCid.ok, false);
  assert.equal(noCid.code, 'CID_REQUIRED_FOR_UPLOAD');
  assert.equal(noCid.secretsExposed, false);
  assert.equal(noCid.signedUploadUrlCreated, false);

  const disabled = await createSignedUploadUrl({
    ownerCid: 'Cid-26-00004',
    filename: 'avatar.png',
    mimeType: 'image/png',
    surface: 'profile-avatar',
    env: {},
  });

  assert.equal(disabled.ok, false);
  assert.equal(disabled.code, 'OBJECT_STORAGE_PRESIGNER_DISABLED');
  assert.equal(disabled.secretsExposed, false);
  assert.equal(disabled.signedUploadUrlCreated, false);

  console.log(
    JSON.stringify(
      {
        ok: true,
        check: 'M14A_OBJECT_STORAGE_PRESIGNER_CLIENT',
        defaultCode: defaultConfig.code,
        missingCode: missingConfig.code,
        driverLoaded: driver.ok,
        sampleObjectKey: objectKey,
        noCidCode: noCid.code,
        disabledCode: disabled.code,
        signedUploadUrlCreated: false,
        objectStorageWrite: false,
        secretsExposed: false,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
