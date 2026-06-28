'use strict';

function main() {
  const dbLiveSmoke = Object.freeze({
    CIDENTIA_MEDIA_URL_GENERATION_ENABLED: 'missing',
    CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID: 'missing',
    CIDENTIA_OBJECT_STORAGE_BUCKET: 'missing',
    CIDENTIA_OBJECT_STORAGE_ENDPOINT: 'missing',
    CIDENTIA_OBJECT_STORAGE_READ_ENABLED: 'missing',
    CIDENTIA_OBJECT_STORAGE_REGION: 'missing',
    CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY: 'missing',
    CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED: 'missing',
  });

  const objectStorageLiveSmoke = Object.freeze({
    CIDENTIA_MEDIA_URL_GENERATION_ENABLED: 'missing',
    CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID: 'present_value_hidden',
    CIDENTIA_OBJECT_STORAGE_BUCKET: 'present_value_hidden',
    CIDENTIA_OBJECT_STORAGE_ENDPOINT: 'present_value_hidden',
    CIDENTIA_OBJECT_STORAGE_READ_ENABLED: 'missing',
    CIDENTIA_OBJECT_STORAGE_REGION: 'present_value_hidden',
    CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY: 'present_value_hidden',
    CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED: 'missing',
  });

  const allowedStatuses = new Set([
    'true',
    'false',
    'missing',
    'present_value_hidden',
  ]);

  const readGateKeys = [
    'CIDENTIA_MEDIA_URL_GENERATION_ENABLED',
    'CIDENTIA_OBJECT_STORAGE_READ_ENABLED',
    'CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED',
  ];

  const dbStatusesSafe = Object.values(dbLiveSmoke).every((value) =>
    allowedStatuses.has(value),
  );

  const objectStorageStatusesSafe = Object.values(objectStorageLiveSmoke).every(
    (value) => allowedStatuses.has(value),
  );

  const dbReadGatesMissing = readGateKeys.every(
    (key) => dbLiveSmoke[key] === 'missing',
  );

  const objectStorageReadGatesMissing = readGateKeys.every(
    (key) => objectStorageLiveSmoke[key] === 'missing',
  );

  const objectStorageConfigPresentHidden =
    objectStorageLiveSmoke.CIDENTIA_OBJECT_STORAGE_ENDPOINT ===
      'present_value_hidden' &&
    objectStorageLiveSmoke.CIDENTIA_OBJECT_STORAGE_BUCKET ===
      'present_value_hidden' &&
    objectStorageLiveSmoke.CIDENTIA_OBJECT_STORAGE_REGION ===
      'present_value_hidden' &&
    objectStorageLiveSmoke.CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID ===
      'present_value_hidden' &&
    objectStorageLiveSmoke.CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY ===
      'present_value_hidden';

  const report = Object.freeze({
    ok:
      dbStatusesSafe &&
      objectStorageStatusesSafe &&
      dbReadGatesMissing &&
      objectStorageReadGatesMissing &&
      objectStorageConfigPresentHidden,
    code: 'M21N_VPS_ENV_NAMES_ONLY_READ_GATES_CHECK',
    envDirectory: '/opt/cidentia-live/env',
    filesFound: ['db-live-smoke.env', 'object-storage-live-smoke.env'],
    dbReadGatesMissing,
    objectStorageReadGatesMissing,
    objectStorageConfigPresentHidden,
    allowedStatuses: Array.from(allowedStatuses),
    secretsExposed: false,
    vpsEnvChanged: false,
    objectStorageCalled: false,
    objectStorageRead: false,
    objectStorageWrite: false,
    signedUrlGenerated: false,
    apiOpened: false,
    flutterOpened: false,
    packageChanged: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main();
