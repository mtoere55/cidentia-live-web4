'use strict';

const http = require('http');
const { spawn } = require('child_process');

function request(pathname, headers = {}) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: '127.0.0.1',
        port: 3010,
        path: pathname,
        method: 'GET',
        headers,
      },
      (res) => {
        let body = '';

        res.on('data', (chunk) => {
          body += chunk;
        });

        res.on('end', () => {
          try {
            resolve({
              statusCode: res.statusCode,
              body: JSON.parse(body),
            });
          } catch (error) {
            reject(error);
          }
        });
      },
    );

    req.on('error', reject);
    req.end();
  });
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForServer() {
  for (let index = 0; index < 30; index += 1) {
    try {
      await request('/api/profile/posts');
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

    const routes = [
      ['/api/profile/posts', 'posts'],
      ['/api/profile/reels', 'reels'],
      ['/api/profile/media', 'media'],
    ];

    const missingCid = await request('/api/profile/posts');
    const results = [];

    for (const [route, tab] of routes) {
      const response = await request(route, {
        'x-cidentia-cid': 'Cid-M20B-Tabs',
      });

      results.push({
        route,
        tab,
        statusCode: response.statusCode,
        code: response.body.code,
        repositoryCode: response.body.repositoryCode,
        itemsRead: response.body.itemsRead,
        itemsLength: Array.isArray(response.body.items)
          ? response.body.items.length
          : null,
        dbConnected: response.body.dbConnected,
        queryEnabled: response.body.queryEnabled,
        secretsExposed: response.body.secretsExposed,
        publicMediaUrlsCreated: response.body.publicMediaUrlsCreated,
        fakeItemsCreated: response.body.fakeItemsCreated,
      });
    }

    const ok =
      missingCid.statusCode === 401 &&
      missingCid.body.code === 'PROFILE_CID_REQUIRED' &&
      results.every((result) =>
        result.statusCode === 503 &&
        result.code === 'PROFILE_TABS_DISABLED' &&
        result.repositoryCode === 'DATABASE_DISABLED' &&
        result.itemsRead === false &&
        result.itemsLength === 0 &&
        result.dbConnected === false &&
        result.queryEnabled === false &&
        result.secretsExposed === false &&
        result.publicMediaUrlsCreated === false &&
        result.fakeItemsCreated === false,
      );

    const report = Object.freeze({
      ok,
      code: ok
        ? 'M20B_PROFILE_TAB_API_ROUTES_DISABLED_OK'
        : 'M20B_PROFILE_TAB_API_ROUTES_DISABLED_FAILED',
      missingCidStatusCode: missingCid.statusCode,
      missingCidCode: missingCid.body.code,
      results,
      apiRoutesOpened: true,
      flutterOpened: false,
      publicMediaUrlsCreated: false,
      fakeItemsCreated: false,
      secretsExposed: false,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!ok) {
      process.exitCode = 1;
    }
  } catch (error) {
    console.error(JSON.stringify({
      ok: false,
      code: 'M20B_DISABLED_CHECK_CRASHED',
      message: error.message,
      secretsExposed: false,
    }, null, 2));
    process.exitCode = 1;
  } finally {
    child.kill();
  }
}

main();
