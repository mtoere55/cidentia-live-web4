'use strict';

const http = require('http');
const { spawn } = require('child_process');

const port = 3011;
const server = spawn(
  process.execPath,
  ['scripts/m12h-profile-api-local-smoke-server.js'],
  {
    env: {
      ...process.env,
      CIDENTIA_PROFILE_SMOKE_PORT: String(port),
    },
    stdio: ['ignore', 'pipe', 'pipe'],
  },
);

function request(method, path, headers = {}, body = null) {
  return new Promise((resolve, reject) => {
    const payload = body == null ? null : JSON.stringify(body);
    const req = http.request(
      {
        hostname: '127.0.0.1',
        port,
        method,
        path,
        headers: {
          ...headers,
          ...(payload
            ? {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(payload),
              }
            : {}),
        },
      },
      (res) => {
        let raw = '';

        res.on('data', (chunk) => {
          raw += chunk;
        });

        res.on('end', () => {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            payload: raw ? JSON.parse(raw) : {},
          });
        });
      },
    );

    req.on('error', reject);

    if (payload) {
      req.write(payload);
    }

    req.end();
  });
}

function waitForServer() {
  return new Promise((resolve) => {
    const timer = setInterval(async () => {
      try {
        await request('GET', '/missing');
        clearInterval(timer);
        resolve();
      } catch (_) {
        // server not ready yet
      }
    }, 100);
  });
}

async function main() {
  await waitForServer();

  const missingRead = await request('GET', '/api/profile/me');
  const read = await request('GET', '/api/profile/me', {
    'x-cidentia-cid': 'Cid-Test',
  });
  const missingWrite = await request('POST', '/api/profile/update');
  const write = await request(
    'POST',
    '/api/profile/update',
    { 'x-cidentia-cid': 'Cid-Test' },
    { displayName: 'Murat Toere' },
  );

  const ok =
    missingRead.statusCode === 401 &&
    missingRead.payload.code === 'PROFILE_CID_REQUIRED' &&
    read.statusCode === 503 &&
    read.payload.code === 'PROFILE_READ_DISABLED' &&
    read.payload.repositoryCode === 'DATABASE_DISABLED' &&
    missingWrite.statusCode === 401 &&
    missingWrite.payload.code === 'PROFILE_CID_REQUIRED' &&
    write.statusCode === 503 &&
    write.payload.code === 'PROFILE_WRITE_DISABLED' &&
    write.payload.repositoryCode === 'DATABASE_DISABLED' &&
    write.payload.profileUpdated === false &&
    write.payload.queryEnabled === false;

  if (!ok) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          missingRead,
          read,
          missingWrite,
          write,
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
        missingReadCode: missingRead.payload.code,
        readCode: read.payload.code,
        readRepositoryCode: read.payload.repositoryCode,
        missingWriteCode: missingWrite.payload.code,
        writeCode: write.payload.code,
        writeRepositoryCode: write.payload.repositoryCode,
        profileUpdated: write.payload.profileUpdated,
        queryEnabled: write.payload.queryEnabled,
        dbConnected: write.payload.dbConnected,
      },
      null,
      2,
    ),
  );
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(() => {
    server.kill();
  });
