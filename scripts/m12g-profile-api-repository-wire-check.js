'use strict';

const profileMe = require('../api/profile/me');
const profileUpdate = require('../api/profile/update');

function createResponse() {
  return {
    statusCode: null,
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

function createRequest(method, headers = {}, body = {}) {
  return {
    method,
    headers,
    body,
  };
}

async function main() {
  const missingReadRes = createResponse();
  await profileMe(createRequest('GET'), missingReadRes);

  const readRes = createResponse();
  await profileMe(
    createRequest('GET', { 'x-cidentia-cid': 'Cid-Test' }),
    readRes,
  );

  const missingWriteRes = createResponse();
  await profileUpdate(createRequest('POST'), missingWriteRes);

  const writeRes = createResponse();
  await profileUpdate(
    createRequest(
      'POST',
      { 'x-cidentia-cid': 'Cid-Test' },
      { displayName: 'Murat Toere' },
    ),
    writeRes,
  );

  const ok =
    missingReadRes.statusCode === 401 &&
    missingReadRes.payload.code === 'PROFILE_CID_REQUIRED' &&
    readRes.statusCode === 503 &&
    readRes.payload.code === 'PROFILE_READ_DISABLED' &&
    readRes.payload.repositoryCode === 'DATABASE_DISABLED' &&
    missingWriteRes.statusCode === 401 &&
    missingWriteRes.payload.code === 'PROFILE_CID_REQUIRED' &&
    writeRes.statusCode === 503 &&
    writeRes.payload.code === 'PROFILE_WRITE_DISABLED' &&
    writeRes.payload.repositoryCode === 'DATABASE_DISABLED' &&
    writeRes.payload.profileUpdated === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          missingRead: missingReadRes,
          read: readRes,
          missingWrite: missingWriteRes,
          write: writeRes,
        },
        null,
        2,
      ),
    );
    process.exit(1);
  }

  console.log(
    JSON.stringify(
      {
        ok: true,
        missingReadCode: missingReadRes.payload.code,
        readCode: readRes.payload.code,
        readRepositoryCode: readRes.payload.repositoryCode,
        missingWriteCode: missingWriteRes.payload.code,
        writeCode: writeRes.payload.code,
        writeRepositoryCode: writeRes.payload.repositoryCode,
        profileUpdated: writeRes.payload.profileUpdated,
        queryEnabled: writeRes.payload.queryEnabled,
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
