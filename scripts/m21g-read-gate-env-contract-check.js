'use strict';

const {
  PRODUCTION_CAPABLE_FLAGS,
  loadCidentiaEnvContract,
} = require('../server/runtime/envContract');

function main() {
  const contract = loadCidentiaEnvContract({});

  const expectedFlags = [
    'CIDENTIA_MEDIA_URL_GENERATION_ENABLED',
    'CIDENTIA_OBJECT_STORAGE_READ_ENABLED',
    'CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED',
  ];

  const flagsPresent = expectedFlags.every((key) =>
    PRODUCTION_CAPABLE_FLAGS.includes(key),
  );

  const gatesDefaultFalse = expectedFlags.every((key) =>
    contract.gates[key] === false,
  );

  const locksDefaultTrue =
    contract.locked.mediaUrlGenerationLocked === true &&
    contract.locked.objectStorageReadLocked === true &&
    contract.locked.signedMediaReadUrlLocked === true;

  const enabledContract = loadCidentiaEnvContract({
    CIDENTIA_MEDIA_URL_GENERATION_ENABLED: 'true',
    CIDENTIA_OBJECT_STORAGE_READ_ENABLED: 'true',
    CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED: 'true',
  });

  const gatesCanEnable =
    enabledContract.gates.CIDENTIA_MEDIA_URL_GENERATION_ENABLED === true &&
    enabledContract.gates.CIDENTIA_OBJECT_STORAGE_READ_ENABLED === true &&
    enabledContract.gates.CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED === true;

  const locksCanOpen =
    enabledContract.locked.mediaUrlGenerationLocked === false &&
    enabledContract.locked.objectStorageReadLocked === false &&
    enabledContract.locked.signedMediaReadUrlLocked === false;

  const report = Object.freeze({
    ok:
      flagsPresent &&
      gatesDefaultFalse &&
      locksDefaultTrue &&
      gatesCanEnable &&
      locksCanOpen &&
      contract.secretsExposed === false,
    flagsPresent,
    gatesDefaultFalse,
    locksDefaultTrue,
    gatesCanEnable,
    locksCanOpen,
    secretsExposed: contract.secretsExposed,
    vpsEnvChanged: false,
    objectStorageCalled: false,
    signedUrlGenerated: false,
    apiOpened: false,
    flutterOpened: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main();
