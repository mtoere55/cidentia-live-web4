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
          'x-cidentia-cid': 'Cid-M21I-Media',
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
      await request('/api/media/read-url');
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
        CIDENTIA_MEDIA_URL_GENERATION_ENABLED: 'true',
        CIDENTIA_OBJECT_STORAGE_READ_ENABLED: 'true',
        CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED: 'true',
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

    const response = await request('/api/media/read-url', {
      id: 'media-m21i-positive-gates',
      ownerCid: 'Cid-M21I-Media',
      surface: 'profile_cover',
      storageBucket: 'private-bucket',
      storageObjectKey: 'm21i/private.png',
      visibility: 'public',
      moderationStatus: 'approved',
    });

    const body = response.body;

    const ok =
      response.statusCode === 503 &&
      body.envContractRead === true &&
      body.code === 'SIGNED_MEDIA_READ_URL_SIGNER_NOT_IMPLEMENTED' &&
      body.mediaUrlGenerationLocked === false &&
      body.objectStorageReadLocked === false &&
      body.signedMediaReadUrlLocked === false &&
      body.publicMediaUrl === null &&
      body.signedMediaReadUrl === null &&
      body.publicMediaUrlsCreated === false &&
      body.signedMediaReadUrlCreated === false &&
      body.storageSignedUrlCreated === false &&
      body.objectStorageCalled === false &&
      body.objectStorageRead === false &&
      body.objectStorageWrite === false &&
      body.storageBucketExposed === false &&
      body.storageObjectKeyExposed === false &&
      body.storageSecretExposed === false &&
      body.frontendSecretExposed === false &&
      body.secretsExposed === false &&
      body.uploadPresignerTouched === false &&
      body.flutterOpened === false;

    const report = Object.freeze({
      ok,
      code: ok
        ? 'M21I_POSITIVE_READ_GATE_CONTRACT_SMOKE_OK'
        : 'M21I_POSITIVE_READ_GATE_CONTRACT_SMOKE_FAILED',
      statusCode: response.statusCode,
      routeCode: body.code,
      envContractRead: body.envContractRead,
      mediaUrlGenerationLocked: body.mediaUrlGenerationLocked,
      objectStorageReadLocked: body.objectStorageReadLocked,
      signedMediaReadUrlLocked: body.signedMediaReadUrlLocked,
      publicMediaUrl: body.publicMediaUrl,
      signedMediaReadUrl: body.signedMediaReadUrl,
      signedMediaReadUrlCreated: body.signedMediaReadUrlCreated,
      storageSignedUrlCreated: body.storageSignedUrlCreated,
      objectStorageCalled: body.objectStorageCalled,
      objectStorageRead: body.objectStorageRead,
      objectStorageWrite: body.objectStorageWrite,
      uploadPresignerTouched: body.uploadPresignerTouched,
      flutterOpened: body.flutterOpened,
      secretsExposed: body.secretsExposed,
      vpsEnvChanged: false,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!ok) {
      process.exitCode = 1;
    }
  } catch (error) {
    console.error(JSON.stringify({
      ok: false,
      code: 'M21I_POSITIVE_READ_GATE_CONTRACT_SMOKE_CRASHED',
      message: error.message,
      secretsExposed: false,
    }, null, 2));
    process.exitCode = 1;
  } finally {
    child.kill();
  }
}

main();
