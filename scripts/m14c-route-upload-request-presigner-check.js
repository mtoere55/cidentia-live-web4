'use strict';

const assert = require('node:assert/strict');
const { EventEmitter } = require('node:events');

const handler = require('../api/upload/request');

class MockRequest extends EventEmitter {
  constructor({ method = 'POST', headers = {}, body = undefined } = {}) {
    super();
    this.method = method;
    this.headers = headers;
    this.body = body;
  }
}

class MockResponse {
  constructor() {
    this.statusCode = 200;
    this.payload = null;
  }

  status(code) {
    this.statusCode = code;
    return this;
  }

  json(payload) {
    this.payload = payload;
    return this;
  }
}

async function callHandler(options) {
  const req = new MockRequest(options);
  const res = new MockResponse();

  const result = handler(req, res);

  if (options.body === undefined) {
    process.nextTick(() => {
      req.emit('end');
    });
  }

  await result;

  return res;
}

async function main() {
  const getResponse = await callHandler({ method: 'GET' });
  assert.equal(getResponse.statusCode, 405);
  assert.equal(getResponse.payload.code, 'METHOD_NOT_ALLOWED');

  const noCid = await callHandler({
    method: 'POST',
    body: {
      filename: 'avatar.png',
      mimeType: 'image/png',
      surface: 'profile-avatar',
    },
  });

  assert.equal(noCid.statusCode, 401);
  assert.equal(noCid.payload.code, 'CID_REQUIRED_FOR_UPLOAD');
  assert.equal(noCid.payload.signedUploadUrlCreated, false);

  const disabled = await callHandler({
    method: 'POST',
    headers: {
      'x-cidentia-cid': 'Cid-26-00004',
    },
    body: {
      filename: 'avatar.png',
      mimeType: 'image/png',
      surface: 'profile-avatar',
    },
  });

  assert.equal(disabled.statusCode, 503);
  assert.equal(disabled.payload.code, 'OBJECT_STORAGE_PRESIGNER_DISABLED');
  assert.equal(disabled.payload.route, '/api/upload/request');
  assert.equal(disabled.payload.ownerCid, 'Cid-26-00004');
  assert.equal(disabled.payload.cidRequired, true);
  assert.equal(disabled.payload.cidVerified, true);
  assert.equal(disabled.payload.signedUploadUrlCreated, false);
  assert.equal(disabled.payload.objectStorageWrite, false);
  assert.equal(disabled.payload.secretsExposed, false);

  const originalEnv = process.env;
  process.env = {
    ...process.env,
    CIDENTIA_UPLOAD_ENABLED: 'true',
    CIDENTIA_OBJECT_STORAGE_ENABLED: 'true',
    CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED: 'true',
    CIDENTIA_SIGNED_URL_ENABLED: 'true',
  };

  try {
    const missingConfig = await callHandler({
      method: 'POST',
      body: {
        ownerCid: 'Cid-26-00004',
        filename: 'avatar.png',
        mimeType: 'image/png',
        surface: 'profile-avatar',
      },
    });

    assert.equal(missingConfig.statusCode, 503);
    assert.equal(missingConfig.payload.code, 'OBJECT_STORAGE_CONFIG_MISSING');
    assert.equal(missingConfig.payload.signedUploadUrlCreated, false);
    assert.equal(missingConfig.payload.secretsExposed, false);
  } finally {
    process.env = originalEnv;
  }

  console.log(
    JSON.stringify(
      {
        ok: true,
        check: 'M14C_ROUTE_UPLOAD_REQUEST_PRESIGNER',
        methodGuard: getResponse.payload.code,
        noCidCode: noCid.payload.code,
        disabledCode: disabled.payload.code,
        route: disabled.payload.route,
        signedUploadUrlCreated: false,
        objectStorageWrite: false,
        mediaMetadataCreated: false,
        secretsExposed: false,
        uiChanged: false,
        flutterChanged: false,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
