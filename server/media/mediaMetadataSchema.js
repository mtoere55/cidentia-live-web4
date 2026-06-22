'use strict';

const MEDIA_METADATA_SCHEMA_VERSION = 'm11e-disabled-media-metadata-schema-v1';

const ALLOWED_MEDIA_SURFACES = Object.freeze([
  'post_image',
  'post_video',
  'reel_video',
  'story_media',
  'profile_avatar',
  'profile_cover',
  'live_replay',
]);

const ALLOWED_MIME_TYPES = Object.freeze([
  'image/jpeg',
  'image/png',
  'image/webp',
  'video/mp4',
  'video/webm',
]);

const MEDIA_SIZE_LIMITS_BYTES = Object.freeze({
  image: 10 * 1024 * 1024,
  shortVideo: 100 * 1024 * 1024,
  storyVideo: 50 * 1024 * 1024,
});

const REQUIRED_MEDIA_METADATA_FIELDS = Object.freeze([
  'mediaId',
  'ownerCid',
  'ownerDisplayName',
  'mediaSurface',
  'mimeType',
  'byteSize',
  'storageBucket',
  'storageObjectKey',
  'visibility',
  'createdAt',
  'moderationStatus',
  'uploadSource',
]);

function mediaMetadataDisabledSchema() {
  return Object.freeze({
    ok: false,
    code: 'MEDIA_METADATA_WRITE_DISABLED',
    schemaVersion: MEDIA_METADATA_SCHEMA_VERSION,
    mediaMetadataCreated: false,
    dbConnected: false,
    writeEnabled: false,
    allowedMediaSurfaces: ALLOWED_MEDIA_SURFACES,
    allowedMimeTypes: ALLOWED_MIME_TYPES,
    sizeLimitsBytes: MEDIA_SIZE_LIMITS_BYTES,
    requiredFields: REQUIRED_MEDIA_METADATA_FIELDS,
  });
}

module.exports = {
  ALLOWED_MEDIA_SURFACES,
  ALLOWED_MIME_TYPES,
  MEDIA_METADATA_SCHEMA_VERSION,
  MEDIA_SIZE_LIMITS_BYTES,
  REQUIRED_MEDIA_METADATA_FIELDS,
  mediaMetadataDisabledSchema,
};
