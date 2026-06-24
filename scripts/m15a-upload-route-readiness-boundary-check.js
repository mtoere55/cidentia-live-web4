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
  const noCid = await callUploadRequest({
    body: {
      filename: 'm15a-cover.jpg',
      mimeType: 'image/jpeg',
      surface: 'profile-cover',
      byteLength: 1024,
    },
  });

  assertEqual(noCid.statusCode, 401, 'no CID status');
  assertEqual(noCid.payload.code, 'CID_REQUIRED_FOR_UPLOAD', 'no CID code');
  assertFalse(noCid.payload.uploadCreated, 'no CID uploadCreated');
  assertFalse(
    noCid.payload.signedUploadUrlCreated,
    'no CID signedUploadUrlCreated',
  );
  assertFalse(noCid.payload.mediaMetadataCreated, 'no CID mediaMetadataCreated');

  const withCid = await callUploadRequest({
    headers: {
      'x-cidentia-cid': 'Cid-M15A-Readiness-Smoke',
    },
    body: {
      ownerCid: 'Cid-M15A-Readiness-Smoke',
      filename: 'm15a-cover.jpg',
      mimeType: 'image/jpeg',
      surface: 'profile-cover',
      byteLength: 1024,
      metadataWriteRequested: false,
      profileWriteRequested: false,
    },
  });

  assertEqual(withCid.statusCode, 503, 'CID locked status');
  assertEqual(
    withCid.payload.code,
    'OBJECT_STORAGE_PRESIGNER_DISABLED',
    'CID locked code',
  );
  assertFalse(
    withCid.payload.signedUploadUrlCreated,
    'CID signedUploadUrlCreated',
  );
  assertFalse(withCid.payload.objectStorageWrite, 'CID objectStorageWrite');
  assertFalse(withCid.payload.uploadCreated, 'CID uploadCreated');
  assertFalse(
    withCid.payload.mediaMetadataCreated,
    'CID mediaMetadataCreated',
  );
  assertFalse(withCid.payload.secretsExposed, 'CID secretsExposed');

  console.log(JSON.stringify({
    ok: true,
    code: 'M15A_UPLOAD_ROUTE_READINESS_OK',
    noCid: {
      statusCode: noCid.statusCode,
      code: noCid.payload.code,
      uploadCreated: noCid.payload.uploadCreated,
      signedUploadUrlCreated: noCid.payload.signedUploadUrlCreated,
      mediaMetadataCreated: noCid.payload.mediaMetadataCreated,
    },
    withCid: {
      statusCode: withCid.statusCode,
      code: withCid.payload.code,
      signedUploadUrlCreated: withCid.payload.signedUploadUrlCreated,
      objectStorageWrite: withCid.payload.objectStorageWrite,
      uploadCreated: withCid.payload.uploadCreated,
      mediaMetadataCreated: withCid.payload.mediaMetadataCreated,
      secretsExposed: withCid.payload.secretsExposed,
    },
  }, null, 2));
}

main().catch((error) => {
  console.error(JSON.stringify({
    ok: false,
    code: 'M15A_UPLOAD_ROUTE_READINESS_FAILED',
    message: error.message,
  }, null, 2));
  process.exit(1);
});
