'use strict';

const {
  ALLOWED_MEDIA_SURFACES,
  ALLOWED_MIME_TYPES,
  MEDIA_SIZE_LIMITS_BYTES,
} = require('./mediaMetadataSchema');

function normalizeCid(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const cid = value.trim();

  if (cid.length < 3) {
    return null;
  }

  return cid;
}

function cidFromUploadRequest(req, body = {}) {
  const headers = req.headers || {};
  const cid =
    normalizeCid(headers['x-cidentia-cid']) ||
    normalizeCid(headers['x-cid']) ||
    normalizeCid(body.ownerCid) ||
    normalizeCid(body.cid);

  return cid;
}

function normalizeText(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : null;
}

function maxBytesForMimeType(mimeType) {
  if (typeof mimeType !== 'string') {
    return MEDIA_SIZE_LIMITS_BYTES.image;
  }

  if (mimeType.startsWith('video/')) {
    return MEDIA_SIZE_LIMITS_BYTES.shortVideo;
  }

  return MEDIA_SIZE_LIMITS_BYTES.image;
}

function uploadValidationErrorBoundary(route, reason, details = {}) {
  return Object.freeze({
    ok: false,
    route,
    code: 'UPLOAD_REQUEST_VALIDATION_FAILED',
    reason,
    details,
    message: 'Upload request validation failed safely.',
    uploadCreated: false,
    signedUploadUrlCreated: false,
    objectStorageConnected: false,
    objectStorageWrite: false,
    mediaMetadataCreated: false,
    cidRequired: true,
    cidVerified: true,
    guarded: true,
    readOnly: true,
  });
}

function validateUploadRequestBody(body = {}, route = '/api/upload/request') {
  const filename = normalizeText(body.filename);
  const mimeType = normalizeText(body.mimeType);
  const surface = normalizeText(body.surface)?.replace(/-/g, '_');
  const byteLength = Number(body.byteLength);

  if (!filename) {
    return uploadValidationErrorBoundary(route, 'FILENAME_REQUIRED');
  }

  if (filename.length > 180) {
    return uploadValidationErrorBoundary(route, 'FILENAME_TOO_LONG', {
      maxLength: 180,
    });
  }

  if (!surface || !ALLOWED_MEDIA_SURFACES.includes(surface)) {
    return uploadValidationErrorBoundary(route, 'SURFACE_NOT_ALLOWED', {
      surface,
      allowedMediaSurfaces: ALLOWED_MEDIA_SURFACES,
    });
  }

  if (!mimeType || !ALLOWED_MIME_TYPES.includes(mimeType)) {
    return uploadValidationErrorBoundary(route, 'MIME_TYPE_NOT_ALLOWED', {
      mimeType,
      allowedMimeTypes: ALLOWED_MIME_TYPES,
    });
  }

  if (!Number.isFinite(byteLength) || byteLength <= 0) {
    return uploadValidationErrorBoundary(route, 'BYTE_LENGTH_REQUIRED');
  }

  const maxBytes = maxBytesForMimeType(mimeType);

  if (byteLength > maxBytes) {
    return uploadValidationErrorBoundary(route, 'BYTE_LENGTH_TOO_LARGE', {
      byteLength,
      maxBytes,
    });
  }

  return Object.freeze({
    ok: true,
    filename,
    mimeType,
    surface,
    byteLength,
  });
}

function uploadCidRequiredBoundary(route) {
  return Object.freeze({
    ok: false,
    route,
    code: 'CID_REQUIRED_FOR_UPLOAD',
    message:
      'A verified CidenDB/CID session is required before upload can be requested.',
    uploadCreated: false,
    signedUploadUrlCreated: false,
    mediaMetadataCreated: false,
    cidRequired: true,
    cidVerified: false,
    guarded: true,
    readOnly: true,
  });
}

module.exports = {
  cidFromUploadRequest,
  uploadCidRequiredBoundary,
  uploadValidationErrorBoundary,
  validateUploadRequestBody,
};

