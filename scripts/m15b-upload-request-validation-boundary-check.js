'use strict';

const uploadRequestHandler = require('../api/upload/request');

function createMockRequest({ method = 'POST', headers = {}, body = {} } = {}) {
  return {
    method,
    headers,
    body,
    on() {
      return this;
    },
  };
}

function createMockResponse() {
  return {
    statusCode: 200,
    payload: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.payload = payload;
      return this;
    },
  };
}

async function callUploadRequest({ headers = {}, body = {} } = {}) {
  const req = createMockRequest({ headers, body });
  const res = createMockResponse();

  await uploadRequestHandler(req, res);

  return {
    statusCode: res.statusCode,
    payload: res.payload,
  };
}

function assertEqual(actual, expected, label) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

function assertFalse(value, label) {
  if (value !== false) {
    throw new Error(`${label}: expected false, got ${value}`);
  }
}

async function main() {
  const headers = {
    'x-cidentia-cid': 'Cid-M15B-Validation-Smoke',
  };

  const invalidSurface = await callUploadRequest({
    headers,
    body: {
      ownerCid: 'Cid-M15B-Validation-Smoke',
      filename: 'cover.jpg',
      mimeType: 'image/jpeg',
      surface: 'bad_surface',
      byteLength: 1024,
    },
  });

  assertEqual(invalidSurface.statusCode, 400, 'invalid surface status');
  assertEqual(
    invalidSurface.payload.code,
    'UPLOAD_REQUEST_VALIDATION_FAILED',
    'invalid surface code',
  );
  assertEqual(
    invalidSurface.payload.reason,
    'SURFACE_NOT_ALLOWED',
    'invalid surface reason',
  );
  assertFalse(invalidSurface.payload.uploadCreated, 'invalid surface uploadCreated');
  assertFalse(
    invalidSurface.payload.mediaMetadataCreated,
    'invalid surface mediaMetadataCreated',
  );

  const invalidMime = await callUploadRequest({
    headers,
    body: {
      ownerCid: 'Cid-M15B-Validation-Smoke',
      filename: 'cover.exe',
      mimeType: 'application/x-msdownload',
      surface: 'profile-cover',
      byteLength: 1024,
    },
  });

  assertEqual(invalidMime.statusCode, 400, 'invalid mime status');
  assertEqual(
    invalidMime.payload.reason,
    'MIME_TYPE_NOT_ALLOWED',
    'invalid mime reason',
  );

  const tooLarge = await callUploadRequest({
    headers,
    body: {
      ownerCid: 'Cid-M15B-Validation-Smoke',
      filename: 'cover.jpg',
      mimeType: 'image/jpeg',
      surface: 'profile-cover',
      byteLength: 11 * 1024 * 1024,
    },
  });

  assertEqual(tooLarge.statusCode, 400, 'too large status');
  assertEqual(
    tooLarge.payload.reason,
    'BYTE_LENGTH_TOO_LARGE',
    'too large reason',
  );

  const validButLocked = await callUploadRequest({
    headers,
    body: {
      ownerCid: 'Cid-M15B-Validation-Smoke',
      filename: 'cover.jpg',
      mimeType: 'image/jpeg',
      surface: 'profile-cover',
      byteLength: 1024,
    },
  });

  assertEqual(validButLocked.statusCode, 503, 'valid locked status');
  assertEqual(
    validButLocked.payload.code,
    'OBJECT_STORAGE_PRESIGNER_DISABLED',
    'valid locked code',
  );
  assertFalse(
    validButLocked.payload.signedUploadUrlCreated,
    'valid signedUploadUrlCreated',
  );
  assertFalse(validButLocked.payload.objectStorageWrite, 'valid objectStorageWrite');
  assertFalse(validButLocked.payload.uploadCreated, 'valid uploadCreated');
  assertFalse(
    validButLocked.payload.mediaMetadataCreated,
    'valid mediaMetadataCreated',
  );
  assertFalse(validButLocked.payload.secretsExposed, 'valid secretsExposed');

  console.log(JSON.stringify({
    ok: true,
    code: 'M15B_UPLOAD_REQUEST_VALIDATION_OK',
    invalidSurface: {
      statusCode: invalidSurface.statusCode,
      code: invalidSurface.payload.code,
      reason: invalidSurface.payload.reason,
    },
    invalidMime: {
      statusCode: invalidMime.statusCode,
      code: invalidMime.payload.code,
      reason: invalidMime.payload.reason,
    },
    tooLarge: {
      statusCode: tooLarge.statusCode,
      code: tooLarge.payload.code,
      reason: tooLarge.payload.reason,
    },
    validButLocked: {
      statusCode: validButLocked.statusCode,
      code: validButLocked.payload.code,
      signedUploadUrlCreated: validButLocked.payload.signedUploadUrlCreated,
      objectStorageWrite: validButLocked.payload.objectStorageWrite,
      uploadCreated: validButLocked.payload.uploadCreated,
      mediaMetadataCreated: validButLocked.payload.mediaMetadataCreated,
      secretsExposed: validButLocked.payload.secretsExposed,
    },
  }, null, 2));
}

main().catch((error) => {
  console.error(JSON.stringify({
    ok: false,
    code: 'M15B_UPLOAD_REQUEST_VALIDATION_FAILED',
    message: error.message,
  }, null, 2));
  process.exit(1);
});
