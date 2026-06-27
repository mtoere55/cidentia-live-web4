'use strict';

const DEFAULT_MEDIA_URL_POLICY = Object.freeze({
  mediaUrlGenerationEnabled: false,
  signedUrlGenerationEnabled: false,
  publicUrlGenerationEnabled: false,
  allowedVisibility: Object.freeze(['public']),
  allowedModerationStatus: Object.freeze(['approved']),
  allowedSurfaces: Object.freeze([]),
});

function normalizeText(value) {
  if (typeof value !== 'string') {
    return '';
  }

  return value.trim();
}

function normalizeMediaAsset(input = {}) {
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

function mediaUrlLockedResult(code, mediaAsset, policy = {}) {
  return Object.freeze({
    ok: false,
    code,
    mediaAssetId: mediaAsset.id || null,
    ownerCid: mediaAsset.ownerCid || null,
    surface: mediaAsset.surface || null,
    publicMediaUrl: null,
    publicMediaUrlsCreated: false,
    storageSignedUrlCreated: false,
    storageBucketExposed: false,
    storageSecretExposed: false,
    frontendSecretExposed: false,
    mediaUrlGenerationEnabled: policy.mediaUrlGenerationEnabled === true,
    signedUrlGenerationEnabled: policy.signedUrlGenerationEnabled === true,
    publicUrlGenerationEnabled: policy.publicUrlGenerationEnabled === true,
    secretsExposed: false,
  });
}

function evaluateMediaUrlPolicy(input = {}, options = {}) {
  const mediaAsset = normalizeMediaAsset(input.mediaAsset || input);
  const policy = Object.freeze({
    ...DEFAULT_MEDIA_URL_POLICY,
    ...(options.policy || {}),
  });

  if (!mediaAsset.id) {
    return mediaUrlLockedResult('MEDIA_ASSET_REQUIRED', mediaAsset, policy);
  }

  if (!mediaAsset.ownerCid) {
    return mediaUrlLockedResult('MEDIA_OWNER_CID_REQUIRED', mediaAsset, policy);
  }

  if (!mediaAsset.storageBucket) {
    return mediaUrlLockedResult('STORAGE_BUCKET_REQUIRED', mediaAsset, policy);
  }

  if (!mediaAsset.storageObjectKey) {
    return mediaUrlLockedResult('STORAGE_OBJECT_KEY_REQUIRED', mediaAsset, policy);
  }

  if (!policy.mediaUrlGenerationEnabled) {
    return mediaUrlLockedResult('MEDIA_URL_GENERATION_DISABLED', mediaAsset, policy);
  }

  if (!policy.allowedSurfaces.includes(mediaAsset.surface)) {
    return mediaUrlLockedResult('MEDIA_SURFACE_URL_NOT_ALLOWED', mediaAsset, policy);
  }

  if (!policy.allowedVisibility.includes(mediaAsset.visibility)) {
    return mediaUrlLockedResult('MEDIA_VISIBILITY_URL_NOT_ALLOWED', mediaAsset, policy);
  }

  if (!policy.allowedModerationStatus.includes(mediaAsset.moderationStatus)) {
    return mediaUrlLockedResult(
      'MEDIA_MODERATION_URL_NOT_ALLOWED',
      mediaAsset,
      policy,
    );
  }

  if (!policy.signedUrlGenerationEnabled && !policy.publicUrlGenerationEnabled) {
    return mediaUrlLockedResult('MEDIA_URL_RUNTIME_DISABLED', mediaAsset, policy);
  }

  return mediaUrlLockedResult('MEDIA_URL_SIGNER_NOT_IMPLEMENTED', mediaAsset, policy);
}

module.exports = {
  DEFAULT_MEDIA_URL_POLICY,
  normalizeMediaAsset,
  evaluateMediaUrlPolicy,
};
