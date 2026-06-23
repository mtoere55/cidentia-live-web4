'use strict';

const path = require('path');
const {
  createSignedUploadUrl,
  loadObjectStorageConfig,
} = require('../server/media/objectStoragePresignerClient');

function isEnabled(value) {
  return value === true || value === 'true' || value === '1' || value === 'yes';
}

function loadS3DriverFromServerPackage() {
  try {
    const serverPackagePath = path.join(__dirname, '..', 'server');
    const s3 = require(require.resolve('@aws-sdk/client-s3', {
      paths: [serverPackagePath],
    }));

    return {
      ok: true,
      S3Client: s3.S3Client,
      HeadObjectCommand: s3.HeadObjectCommand,
      DeleteObjectCommand: s3.DeleteObjectCommand,
    };
  } catch (error) {
    return {
      ok: false,
      code: 'OBJECT_STORAGE_DRIVER_NOT_INSTALLED',
      message:
        'AWS S3 dependencies are not installed in the server runtime.',
      errorName: error && error.name ? error.name : 'Error',
    };
  }
}

async function runControlledPutSmoke(env = process.env) {
  if (!isEnabled(env.CIDENTIA_OBJECT_STORAGE_PUT_SMOKE)) {
    return {
      ok: true,
      check: 'M14H_OBJECT_STORAGE_CONTROLLED_PUT_SMOKE',
      code: 'OBJECT_STORAGE_PUT_SMOKE_DISABLED',
      putSmokeEnabled: false,
      signedUploadUrlCreated: false,
      objectStorageWrite: false,
      uploadCreated: false,
      cleanupDone: false,
      mediaMetadataCreated: false,
      secretsExposed: false,
    };
  }

  const payload = Buffer.from(
    `Cidentia.Live M14H controlled PUT smoke ${new Date().toISOString()}\n`,
    'utf8',
  );

  const presign = await createSignedUploadUrl({
    ownerCid: 'Cid-M14H-Put-Smoke',
    surface: 'put-smoke',
    filename: 'm14h-put-smoke.txt',
    mimeType: 'text/plain; charset=utf-8',
    env,
  });

  if (!presign.ok || !presign.uploadUrl) {
    return {
      ...presign,
      check: 'M14H_OBJECT_STORAGE_CONTROLLED_PUT_SMOKE',
      putSmokeEnabled: true,
      cleanupDone: false,
      uploadUrl: undefined,
      uploadUrlPreview: null,
    };
  }

  const putResponse = await fetch(presign.uploadUrl, {
    method: 'PUT',
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
    },
    body: payload,
  });

  if (!putResponse.ok) {
    return {
      ok: false,
      check: 'M14H_OBJECT_STORAGE_CONTROLLED_PUT_SMOKE',
      code: 'OBJECT_STORAGE_PUT_FAILED',
      message: `Object Storage PUT failed with HTTP ${putResponse.status}.`,
      putSmokeEnabled: true,
      signedUploadUrlCreated: true,
      objectStorageWrite: false,
      uploadCreated: false,
      cleanupDone: false,
      mediaMetadataCreated: false,
      secretsExposed: false,
      storageBucket: presign.storageBucket,
      storageObjectKey: presign.storageObjectKey,
      httpStatus: putResponse.status,
    };
  }

  const config = loadObjectStorageConfig(env);
  const driver = loadS3DriverFromServerPackage();

  if (!config.ok || !driver.ok) {
    return {
      ok: false,
      check: 'M14H_OBJECT_STORAGE_CONTROLLED_PUT_SMOKE',
      code: !config.ok ? config.code : driver.code,
      message: !config.ok ? config.message : driver.message,
      putSmokeEnabled: true,
      signedUploadUrlCreated: true,
      objectStorageWrite: true,
      uploadCreated: true,
      cleanupDone: false,
      mediaMetadataCreated: false,
      secretsExposed: false,
      storageBucket: presign.storageBucket,
      storageObjectKey: presign.storageObjectKey,
    };
  }

  const client = new driver.S3Client({
    region: config.region,
    endpoint: config.endpoint,
    forcePathStyle: config.forcePathStyle,
    credentials: {
      accessKeyId: config.accessKeyId,
      secretAccessKey: config.secretAccessKey,
    },
  });

  await client.send(
    new driver.HeadObjectCommand({
      Bucket: presign.storageBucket,
      Key: presign.storageObjectKey,
    }),
  );

  await client.send(
    new driver.DeleteObjectCommand({
      Bucket: presign.storageBucket,
      Key: presign.storageObjectKey,
    }),
  );

  return {
    ok: true,
    check: 'M14H_OBJECT_STORAGE_CONTROLLED_PUT_SMOKE',
    code: 'OBJECT_STORAGE_PUT_SMOKE_OK',
    message:
      'Controlled Object Storage PUT smoke uploaded, verified, and cleaned up a tiny disposable object.',
    putSmokeEnabled: true,
    signedUploadUrlCreated: true,
    objectStorageWrite: true,
    uploadCreated: true,
    uploadedBytes: payload.length,
    cleanupDone: true,
    mediaMetadataCreated: false,
    secretsExposed: false,
    storageBucket: presign.storageBucket,
    storageObjectKey: presign.storageObjectKey,
  };
}

if (require.main === module) {
  runControlledPutSmoke()
    .then((result) => {
      console.log(JSON.stringify(result, null, 2));
      process.exit(result.ok ? 0 : 1);
    })
    .catch((error) => {
      console.log(
        JSON.stringify(
          {
            ok: false,
            check: 'M14H_OBJECT_STORAGE_CONTROLLED_PUT_SMOKE',
            code: 'OBJECT_STORAGE_PUT_SMOKE_ERROR',
            message: 'Controlled Object Storage PUT smoke failed safely.',
            errorName: error && error.name ? error.name : 'Error',
            putSmokeEnabled: true,
            signedUploadUrlCreated: false,
            objectStorageWrite: false,
            uploadCreated: false,
            cleanupDone: false,
            mediaMetadataCreated: false,
            secretsExposed: false,
          },
          null,
          2,
        ),
      );
      process.exit(1);
    });
}

module.exports = {
  runControlledPutSmoke,
};
