'use strict';

const { loadCidentiaEnvContract } = require('../runtime/envContract');

const DEFAULT_SIGNED_MEDIA_READ_URL_POLICY = Object.freeze({
  mediaUrlGenerationEnabled: false,
  objectStorageReadEnabled: false,
  signedMediaReadUrlEnabled: false,
  expiresInSeconds: 300,
});

const DEFAULT_SIGNED_MEDIA_READ_EXPIRES_SECONDS = 300;
const MAX_SIGNED_MEDIA_READ_EXPIRES_SECONDS = 900;

function normalizeText(value) {
  if (typeof value !== 'string') {
    return '';
  }

  return value.trim();
}

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

  return Math.min(value, MAX_SIGNED_MEDIA_READ_EXPIRES_SECONDS);
}

function normalizeReadMediaAsset(input = {}) {
  return Object.freeze({
    id: normalizeText(input.id),
    ownerCid: normalizeText(input.ownerCid || input.owner_cid),
    surface: normalizeText(
      input.surface || input.mediaSurface || input.media_surface,
    ),
    storageBucket: normalizeText(input.storageBucket || input.storage_bucket),
    storageObjectKey: normalizeText(
      input.storageObjectKey || input.storage_object_key,
    ),
    visibility: normalizeText(input.visibility),
    moderationStatus: normalizeText(
      input.moderationStatus || input.moderation_status,
    ),
  });
}

function signedMediaReadUrlDisabledResult(code, mediaAsset, policy = {}) {
  return Object.freeze({
    ok: false,
    code,
    mediaAssetId: mediaAsset.id || null,
    ownerCid: mediaAsset.ownerCid || null,
    surface: mediaAsset.surface || null,
    publicMediaUrl: null,
    signedMediaReadUrl: null,
    publicMediaUrlsCreated: false,
    signedMediaReadUrlCreated: false,
    storageSignedUrlCreated: false,
    objectStorageCalled: false,
    objectStorageRead: false,
    objectStorageWrite: false,
    storageBucketExposed: false,
    storageObjectKeyExposed: false,
    storageSecretExposed: false,
    frontendSecretExposed: false,
    secretsExposed: false,
    mediaUrlGenerationEnabled: policy.mediaUrlGenerationEnabled === true,
    objectStorageReadEnabled: policy.objectStorageReadEnabled === true,
    signedMediaReadUrlEnabled: policy.signedMediaReadUrlEnabled === true,
    expiresInSeconds: 0,
  });
}

function loadObjectStorageReadConfig(env = process.env) {
  const contract = loadCidentiaEnvContract(env);

  const mediaUrlGenerationEnabled =
    contract.gates.CIDENTIA_MEDIA_URL_GENERATION_ENABLED === true;
  const objectStorageReadEnabled =
    contract.gates.CIDENTIA_OBJECT_STORAGE_READ_ENABLED === true;
  const signedMediaReadUrlEnabled =
    contract.gates.CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED === true;

  if (
    !mediaUrlGenerationEnabled ||
    !objectStorageReadEnabled ||
    !signedMediaReadUrlEnabled
  ) {
    return Object.freeze({
      ok: false,
      code: 'SIGNED_MEDIA_READ_URL_DISABLED',
      message:
        'Signed media read URL generation is disabled until read gates are enabled.',
      contract,
      objectStorageCalled: false,
      secretsExposed: false,
    });
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
    return Object.freeze({
      ok: false,
      code: 'OBJECT_STORAGE_READ_CONFIG_MISSING',
      message: `Object Storage read config is missing: ${missing.join(', ')}`,
      missing,
      contract,
      objectStorageCalled: false,
      secretsExposed: false,
    });
  }

  return Object.freeze({
    ok: true,
    endpoint,
    bucket,
    region,
    accessKeyId,
    secretAccessKey,
    forcePathStyle: env.CIDENTIA_OBJECT_STORAGE_FORCE_PATH_STYLE !== 'false',
    expiresInSeconds: readIntegerEnv(
      env,
      'CIDENTIA_SIGNED_MEDIA_READ_TTL_SECONDS',
      DEFAULT_SIGNED_MEDIA_READ_EXPIRES_SECONDS,
    ),
    contract,
    objectStorageCalled: false,
    secretsExposed: false,
  });
}

function loadAwsS3ReadPresignerDriver() {
  try {
    const {
      S3Client,
      GetObjectCommand,
    } = require('../node_modules/@aws-sdk/client-s3');
    const {
      getSignedUrl,
    } = require('../node_modules/@aws-sdk/s3-request-presigner');

    return Object.freeze({
      ok: true,
      S3Client,
      GetObjectCommand,
      getSignedUrl,
      objectStorageCalled: false,
      s3ClientCreated: false,
      getObjectCommandCreated: false,
      signedUrlGenerated: false,
      secretsExposed: false,
    });
  } catch (error) {
    return Object.freeze({
      ok: false,
      code: 'READ_PRESIGNER_DRIVER_NOT_INSTALLED',
      message:
        'AWS S3 read presigner dependencies are not installed in the server runtime.',
      errorName: error && error.name ? error.name : 'Error',
      objectStorageCalled: false,
      s3ClientCreated: false,
      getObjectCommandCreated: false,
      signedUrlGenerated: false,
      secretsExposed: false,
    });
  }
}

function evaluateSignedMediaReadUrlPolicy(input = {}, options = {}) {
  const mediaAsset = normalizeReadMediaAsset(input.mediaAsset || input);
  const policy = Object.freeze({
    ...DEFAULT_SIGNED_MEDIA_READ_URL_POLICY,
    ...(options.policy || {}),
  });

  if (!mediaAsset.id) {
    return signedMediaReadUrlDisabledResult(
      'MEDIA_ASSET_REQUIRED',
      mediaAsset,
      policy,
    );
  }

  if (!mediaAsset.ownerCid) {
    return signedMediaReadUrlDisabledResult(
      'MEDIA_OWNER_CID_REQUIRED',
      mediaAsset,
      policy,
    );
  }

  if (!mediaAsset.storageBucket) {
    return signedMediaReadUrlDisabledResult(
      'STORAGE_BUCKET_REQUIRED',
      mediaAsset,
      policy,
    );
  }

  if (!mediaAsset.storageObjectKey) {
    return signedMediaReadUrlDisabledResult(
      'STORAGE_OBJECT_KEY_REQUIRED',
      mediaAsset,
      policy,
    );
  }

  if (!policy.mediaUrlGenerationEnabled) {
    return signedMediaReadUrlDisabledResult(
      'MEDIA_URL_GENERATION_DISABLED',
      mediaAsset,
      policy,
    );
  }

  if (!policy.objectStorageReadEnabled) {
    return signedMediaReadUrlDisabledResult(
      'OBJECT_STORAGE_READ_DISABLED',
      mediaAsset,
      policy,
    );
  }

  if (!policy.signedMediaReadUrlEnabled) {
    return signedMediaReadUrlDisabledResult(
      'SIGNED_MEDIA_READ_URL_DISABLED',
      mediaAsset,
      policy,
    );
  }

  return signedMediaReadUrlDisabledResult(
    'SIGNED_MEDIA_READ_URL_SIGNER_NOT_IMPLEMENTED',
    mediaAsset,
    policy,
  );
}

async function createSignedMediaReadUrl({
  mediaAsset,
  env = process.env,
} = {}) {
  const normalizedMediaAsset = normalizeReadMediaAsset(mediaAsset || {});
  const config = loadObjectStorageReadConfig(env);

  if (!config.ok) {
    return signedMediaReadUrlDisabledResult(
      config.code,
      normalizedMediaAsset,
      {
        mediaUrlGenerationEnabled:
          config.contract?.gates?.CIDENTIA_MEDIA_URL_GENERATION_ENABLED,
        objectStorageReadEnabled:
          config.contract?.gates?.CIDENTIA_OBJECT_STORAGE_READ_ENABLED,
        signedMediaReadUrlEnabled:
          config.contract?.gates?.CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED,
      },
    );
  }

  const policyResult = evaluateSignedMediaReadUrlPolicy(
    { mediaAsset: normalizedMediaAsset },
    {
      policy: {
        mediaUrlGenerationEnabled: true,
        objectStorageReadEnabled: true,
        signedMediaReadUrlEnabled: true,
      },
    },
  );

  if (policyResult.code !== 'SIGNED_MEDIA_READ_URL_SIGNER_NOT_IMPLEMENTED') {
    return policyResult;
  }

  const driver = loadAwsS3ReadPresignerDriver();

  if (!driver.ok) {
    return signedMediaReadUrlDisabledResult(
      driver.code,
      normalizedMediaAsset,
      {
        mediaUrlGenerationEnabled: true,
        objectStorageReadEnabled: true,
        signedMediaReadUrlEnabled: true,
      },
    );
  }

  return signedMediaReadUrlDisabledResult(
    'SIGNED_MEDIA_READ_URL_SIGNER_NOT_IMPLEMENTED',
    normalizedMediaAsset,
    {
      mediaUrlGenerationEnabled: true,
      objectStorageReadEnabled: true,
      signedMediaReadUrlEnabled: true,
    },
  );
}

module.exports = {
  DEFAULT_SIGNED_MEDIA_READ_EXPIRES_SECONDS,
  DEFAULT_SIGNED_MEDIA_READ_URL_POLICY,
  MAX_SIGNED_MEDIA_READ_EXPIRES_SECONDS,
  createSignedMediaReadUrl,
  evaluateSignedMediaReadUrlPolicy,
  loadAwsS3ReadPresignerDriver,
  loadObjectStorageReadConfig,
  normalizeReadMediaAsset,
  signedMediaReadUrlDisabledResult,
};
