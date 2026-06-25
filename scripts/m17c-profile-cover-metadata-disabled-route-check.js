'use strict';

const handler = require('../api/profile/cover/metadata');

function createMockReq({ method = 'POST', headers = {}, body = {} } = {}) {
  return {
    method,
    headers,
    body,
  };
}

function createMockRes() {
  const res = {
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

  return res;
}

async function callHandler(req) {
  const res = createMockRes();
  await handler(req, res);

  return Object.freeze({
    statusCode: res.statusCode,
    payload: res.payload,
  });
}

async function main() {
  const missingCid = await callHandler(
    createMockReq({
      body: {
        surface: 'profile-cover',
        storageBucket: 'cidentia-live-media',
        storageObjectKey:
          'uploads/Cid-M17C-Route-Check/profile-cover/m17c-check.jpg',
        mimeType: 'image/jpeg',
        byteLength: 40,
      },
    }),
  );

  const cidPresent = await callHandler(
    createMockReq({
      headers: {
        'x-cidentia-cid': 'Cid-M17C-Route-Check',
      },
      body: {
        surface: 'profile-cover',
        storageBucket: 'cidentia-live-media',
        storageObjectKey:
          'uploads/Cid-M17C-Route-Check/profile-cover/m17c-check.jpg',
        mimeType: 'image/jpeg',
        byteLength: 40,
      },
    }),
  );

  const report = Object.freeze({
    ok:
      missingCid.statusCode === 401 &&
      missingCid.payload.code === 'PROFILE_CID_REQUIRED' &&
      cidPresent.statusCode === 503 &&
      cidPresent.payload.code === 'MEDIA_METADATA_WRITE_DISABLED' &&
      cidPresent.payload.mediaMetadataCreated === false &&
      cidPresent.payload.profileUpdated === false &&
      cidPresent.payload.secretsExposed === false,
    missingCid: {
      statusCode: missingCid.statusCode,
      code: missingCid.payload.code,
    },
    cidPresent: {
      statusCode: cidPresent.statusCode,
      code: cidPresent.payload.code,
      mediaMetadataCreated: cidPresent.payload.mediaMetadataCreated,
      profileUpdated: cidPresent.payload.profileUpdated,
      secretsExposed: cidPresent.payload.secretsExposed,
      surface: cidPresent.payload.draft.surface,
    },
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
