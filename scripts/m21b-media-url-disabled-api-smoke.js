'use strict';

const http = require('http');
const { spawn } = require('child_process');

function request(pathname, body = {}) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(body);

    const req = http.request(
      {
        hostname: '127.0.0.1',
        port: 3010,
        path: pathname,
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'content-length': Buffer.byteLength(payload),
          'x-cidentia-cid': 'Cid-M21B-Media',
        },
      },
      (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          resolve({
            statusCode: res.statusCode,
            body: JSON.parse(data),
          });
        });
      },
    );

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForServer() {
  for (let index = 0; index < 30; index += 1) {
    try {
      await request('/api/media/url');
      return true;
    } catch (_) {
      await wait(100);
    }
  }

  return false;
}

async function main() {
  const child = spawn(
    process.execPath,
    ['scripts/m10h-disabled-backend-local-server.js'],
    {
      stdio: ['ignore', 'pipe', 'pipe'],
      env: {
        ...process.env,
        CIDENTIA_DATABASE_ENABLED: 'false',
        CIDENTIA_DATABASE_QUERY_ENABLED: 'false',
        CIDENTIA_DATABASE_URL: '',
      },
    },
  );

  child.stdout.on('data', () => {});
  child.stderr.on('data', () => {});

  try {
    const ready = await waitForServer();

    if (!ready) {
      throw new Error('disabled backend server did not become ready');
    }

    const response = await request('/api/media/url', {
      id: 'media-m21b-disabled',
      ownerCid: 'Cid-M21B-Media',
      surface: 'profile_cover',
      storageBucket: 'private-bucket',
      storageObjectKey: 'm21b/private.png',
      visibility: 'public',
      moderationStatus: 'approved',
    });

    const body = response.body;

    const ok =
      response.statusCode === 503 &&
      body.code === 'MEDIA_URL_GENERATION_DISABLED' &&
      body.publicMediaUrl === null &&
      body.publicMediaUrlsCreated === false &&
      body.storageSignedUrlCreated === false &&
      body.storageBucketExposed === false &&
      body.storageSecretExposed === false &&
      body.frontendSecretExposed === false &&
      body.secretsExposed === false &&
      body.objectStorageCalled === false &&
      body.flutterOpened === false;

    const report = Object.freeze({
      ok,
      code: ok
        ? 'M21B_MEDIA_URL_DISABLED_API_SMOKE_OK'
        : 'M21B_MEDIA_URL_DISABLED_API_SMOKE_FAILED',
      statusCode: response.statusCode,
      routeCode: body.code,
      publicMediaUrl: body.publicMediaUrl,
      publicMediaUrlsCreated: body.publicMediaUrlsCreated,
      storageSignedUrlCreated: body.storageSignedUrlCreated,
      storageBucketExposed: body.storageBucketExposed,
      storageSecretExposed: body.storageSecretExposed,
      frontendSecretExposed: body.frontendSecretExposed,
      objectStorageCalled: body.objectStorageCalled,
      flutterOpened: body.flutterOpened,
      secretsExposed: body.secretsExposed,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!ok) {
      process.exitCode = 1;
    }
  } catch (error) {
    console.error(JSON.stringify({
      ok: false,
      code: 'M21B_MEDIA_URL_DISABLED_API_SMOKE_CRASHED',
      message: error.message,
      secretsExposed: false,
    }, null, 2));
    process.exitCode = 1;
  } finally {
    child.kill();
  }
}

main();
