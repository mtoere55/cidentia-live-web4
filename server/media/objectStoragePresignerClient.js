'use strict';

const { loadCidentiaEnvContract } = require('../runtime/envContract');

const DEFAULT_PRESIGN_EXPIRES_SECONDS = 900;
const MAX_PRESIGN_EXPIRES_SECONDS = 3600;

function readTextEnv(env, key) {
  const value = env[key];

  if (typeof value !== 'string') {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function readIntegerEnv(env, key, fallback) {
  const value = Number.parseInt(env[key], 10);

  if (!Number.isFinite(value) || value <= 0) {
    return fallback;
  }

  return Math.min(value, MAX_PRESIGN_EXPIRES_SECONDS);
}

function objectStoragePresignerDisabledBoundary(reasonCode, message) {
  return Object.freeze({
    ok: false,
    code: reasonCode,
    message,
    signedUploadUrlCreated: false,
    objectStorageConnected: false,
    objectStorageWrite: false,
    uploadCreated: false,
    mediaMetadataCreated: false,
    secretsExposed: false,
    expiresInSeconds: 0,
    uploadUrl: null,
    storageBucket: null,
    storageObjectKey: null,
  });
}

function loadObjectStorageConfig(env = process.env) {
  const contract = loadCidentiaEnvContract(env);

  const uploadEnabled = contract.gates.CIDENTIA_UPLOAD_ENABLED === true;
  const objectStorageEnabled =
    contract.gates.CIDENTIA_OBJECT_STORAGE_ENABLED === true;
  const objectStorageWriteEnabled =
    contract.gates.CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED === true;
  const signedUrlEnabled = contract.gates.CIDENTIA_SIGNED_URL_ENABLED === true;

  if (
    !uploadEnabled ||
    !objectStorageEnabled ||
    !objectStorageWriteEnabled ||
    !signedUrlEnabled
  ) {
    return {
      ok: false,
      code: 'OBJECT_STORAGE_PRESIGNER_DISABLED',
      message:
        'Object Storage presigner is disabled until upload, storage write, and signed URL gates are enabled.',
      contract,
    };
  }

  const endpoint = readTextEnv(env, 'CIDENTIA_OBJECT_STORAGE_ENDPOINT');
  const bucket = readTextEnv(env, 'CIDENTIA_OBJECT_STORAGE_BUCKET');
  const region =
    readTextEnv(env, 'CIDENTIA_OBJECT_STORAGE_REGION') || 'fsn1';
  const accessKeyId = readTextEnv(
    env,
    'CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID',
  );
  const secretAccessKey = readTextEnv(
    env,
    'CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY',
  );

  const missing = [];
  if (!endpoint) missing.push('CIDENTIA_OBJECT_STORAGE_ENDPOINT');
  if (!bucket) missing.push('CIDENTIA_OBJECT_STORAGE_BUCKET');
  if (!accessKeyId) missing.push('CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID');
  if (!secretAccessKey) {
    missing.push('CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY');
  }

  if (missing.length > 0) {
    return {
      ok: false,
      code: 'OBJECT_STORAGE_CONFIG_MISSING',
      message: `Object Storage config is missing: ${missing.join(', ')}`,
      missing,
      contract,
    };
  }

  return {
    ok: true,
    endpoint,
    bucket,
    region,
    accessKeyId,
    secretAccessKey,
    forcePathStyle: env.CIDENTIA_OBJECT_STORAGE_FORCE_PATH_STYLE !== 'false',
    expiresInSeconds: readIntegerEnv(
      env,
      'CIDENTIA_SIGNED_UPLOAD_TTL_SECONDS',
      DEFAULT_PRESIGN_EXPIRES_SECONDS,
    ),
    contract,
  };
}

function loadAwsS3PresignerDriver() {
  try {
    const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
    const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

    return {
      ok: true,
      S3Client,
      PutObjectCommand,
      getSignedUrl,
    };
  } catch (error) {
    return {
      ok: false,
      code: 'OBJECT_STORAGE_DRIVER_NOT_INSTALLED',
      message:
        'AWS S3 presigner dependencies are not installed in the server runtime.',
      errorName: error && error.name ? error.name : 'Error',
    };
  }
}

function safeObjectKeySegment(value) {
  return String(value || '')
    .trim()
    .replace(/[\\/]+/g, '-')
    .replace(/\.+/g, '-')
    .replace(/[^a-zA-Z0-9_-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+/, '')
    .replace(/-+$/, '')
    .slice(0, 120);
}

function buildUploadObjectKey({
  ownerCid,
  surface = 'media',
  filename = 'upload.bin',
  now = new Date(),
}) {
  const safeCid = safeObjectKeySegment(ownerCid) || 'cid-required';
  const safeSurface = safeObjectKeySegment(surface) || 'media';
  const safeFilename = safeObjectKeySegment(filename) || 'upload.bin';
  const iso = now.toISOString().replace(/[:.]/g, '-');

  return `uploads/${safeCid}/${safeSurface}/${iso}-${safeFilename}`;
}

async function createSignedUploadUrl({
  ownerCid,
  filename,
  mimeType,
  surface,
  env = process.env,
}) {
  if (!ownerCid) {
    return objectStoragePresignerDisabledBoundary(
      'CID_REQUIRED_FOR_UPLOAD',
      'A verified CID is required before a signed upload URL can be created.',
    );
  }

  const config = loadObjectStorageConfig(env);

  if (!config.ok) {
    return objectStoragePresignerDisabledBoundary(config.code, config.message);
  }

  const driver = loadAwsS3PresignerDriver();

  if (!driver.ok) {
    return objectStoragePresignerDisabledBoundary(driver.code, driver.message);
  }

  const storageObjectKey = buildUploadObjectKey({
    ownerCid,
    surface,
    filename,
  });

  const client = new driver.S3Client({
    region: config.region,
    endpoint: config.endpoint,
    forcePathStyle: config.forcePathStyle,
    credentials: {
      accessKeyId: config.accessKeyId,
      secretAccessKey: config.secretAccessKey,
    },
  });

  const command = new driver.PutObjectCommand({
    Bucket: config.bucket,
    Key: storageObjectKey,
    ContentType: mimeType || 'application/octet-stream',
    Metadata: {
      ownerCid,
      surface: surface || 'media',
    },
  });

  const uploadUrl = await driver.getSignedUrl(client, command, {
    expiresIn: config.expiresInSeconds,
  });

  return Object.freeze({
    ok: true,
    code: 'SIGNED_UPLOAD_URL_CREATED',
    message: 'Signed upload URL created by guarded Object Storage presigner.',
    signedUploadUrlCreated: true,
    objectStorageConnected: false,
    objectStorageWrite: false,
    uploadCreated: false,
    mediaMetadataCreated: false,
    secretsExposed: false,
    expiresInSeconds: config.expiresInSeconds,
    uploadUrl,
    storageBucket: config.bucket,
    storageObjectKey,
  });
}

module.exports = {
  buildUploadObjectKey,
  createSignedUploadUrl,
  loadAwsS3PresignerDriver,
  loadObjectStorageConfig,
  objectStoragePresignerDisabledBoundary,
};
