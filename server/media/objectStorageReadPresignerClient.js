'use strict';

const DEFAULT_SIGNED_MEDIA_READ_URL_POLICY = Object.freeze({
  mediaUrlGenerationEnabled: false,
  objectStorageReadEnabled: false,
  signedMediaReadUrlEnabled: false,
  expiresInSeconds: 300,
});

function normalizeText(value) {
  if (typeof value !== 'string') {
    return '';
  }

  return value.trim();
}

function normalizeReadMediaAsset(input = {}) {
  return Object.freeze({
    id: normalizeText(input.id),
    ownerCid: normalizeText(input.ownerCid || input.owner_cid),
    surface: normalizeText(input.surface || input.mediaSurface || input.media_surface),
    storageBucket: normalizeText(input.storageBucket || input.storage_bucket),
    storageObjectKey: normalizeText(input.storageObjectKey || input.storage_object_key),
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

module.exports = {
  DEFAULT_SIGNED_MEDIA_READ_URL_POLICY,
  evaluateSignedMediaReadUrlPolicy,
  normalizeReadMediaAsset,
  signedMediaReadUrlDisabledResult,
};
