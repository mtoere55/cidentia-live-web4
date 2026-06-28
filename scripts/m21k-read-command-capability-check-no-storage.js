'use strict';

function loadReadPresignerCapability() {
  try {
    const {
      S3Client,
      GetObjectCommand,
      PutObjectCommand,
    } = require('../server/node_modules/@aws-sdk/client-s3');

    const {
      getSignedUrl,
    } = require('../server/node_modules/@aws-sdk/s3-request-presigner');

    return Object.freeze({
      ok: true,
      s3ClientImportable: typeof S3Client === 'function',
      getObjectCommandImportable: typeof GetObjectCommand === 'function',
      putObjectCommandImportable: typeof PutObjectCommand === 'function',
      getSignedUrlImportable: typeof getSignedUrl === 'function',
      objectStorageCalled: false,
      s3ClientCreated: false,
      getObjectCommandCreated: false,
      signedUrlGenerated: false,
      packageChanged: false,
      secretsExposed: false,
    });
  } catch (error) {
    return Object.freeze({
      ok: false,
      code: 'READ_PRESIGNER_CAPABILITY_IMPORT_FAILED',
      errorName: error && error.name ? error.name : 'Error',
      objectStorageCalled: false,
      s3ClientCreated: false,
      getObjectCommandCreated: false,
      signedUrlGenerated: false,
      packageChanged: false,
      secretsExposed: false,
    });
  }
}

function main() {
  const capability = loadReadPresignerCapability();

  const ok =
    capability.ok === true &&
    capability.s3ClientImportable === true &&
    capability.getObjectCommandImportable === true &&
    capability.getSignedUrlImportable === true &&
    capability.objectStorageCalled === false &&
    capability.s3ClientCreated === false &&
    capability.getObjectCommandCreated === false &&
    capability.signedUrlGenerated === false &&
    capability.packageChanged === false &&
    capability.secretsExposed === false;

  const report = Object.freeze({
    ok,
    code: ok
      ? 'M21K_READ_COMMAND_CAPABILITY_CHECK_OK'
      : 'M21K_READ_COMMAND_CAPABILITY_CHECK_FAILED',
    ...capability,
    apiOpened: false,
    flutterOpened: false,
    vpsEnvChanged: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!ok) {
    process.exitCode = 1;
  }
}

main();
