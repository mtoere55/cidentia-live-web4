'use strict';

const http = require('http');

const uploadRequestHandler = require('../api/upload/request');

const port = Number(process.env.CIDENTIA_UPLOAD_SMOKE_PORT || 3011);
const host = process.env.CIDENTIA_UPLOAD_SMOKE_HOST || '127.0.0.1';

function createResponse(nativeRes) {
  return {
    statusCode: 200,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      const body = JSON.stringify(payload);
      nativeRes.writeHead(this.statusCode, {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-store',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers':
          'content-type, x-cidentia-cid, x-cid',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'X-Cidentia-Upload-Smoke': 'true',
      });
      nativeRes.end(body);
    },
  };
}

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'content-type, x-cidentia-cid, x-cid',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'X-Cidentia-Upload-Smoke': 'true',
  });
  res.end(JSON.stringify(payload));
}

const server = http.createServer(async (req, res) => {
  const route = req.url.split('?')[0];

  if (req.method === 'OPTIONS') {
    sendJson(res, 204, {});
    return;
  }

  if (req.method === 'GET' && route === '/api/health') {
    sendJson(res, 200, {
      ok: true,
      code: 'M16F_UPLOAD_SMOKE_SERVER_READY',
      uploadSmoke: true,
      publicApiChanged: false,
      metadataWriteEnabled: false,
      profileWriteEnabled: false,
      publicPublishEnabled: false,
      secretsExposed: false,
    });
    return;
  }

  if (req.method === 'POST' && route === '/api/upload/request') {
    try {
      await uploadRequestHandler(req, createResponse(res));
    } catch (error) {
      sendJson(res, 503, {
        ok: false,
        code: 'M16F_UPLOAD_SMOKE_ROUTE_ERROR',
        message: 'Upload smoke route failed safely.',
        errorName: error && error.name ? error.name : 'Error',
        signedUploadUrlCreated: false,
        uploadCreated: false,
        mediaMetadataCreated: false,
        profileDbWrite: false,
        secretsExposed: false,
      });
    }
    return;
  }

  sendJson(res, 404, {
    ok: false,
    code: 'M16F_UPLOAD_SMOKE_ROUTE_NOT_FOUND',
    route,
  });
});

server.listen(port, host, () => {
  console.log(
    `M16F upload smoke server listening on http://${host}:${port}`,
  );
  console.log(
    'Smoke only. No metadata DB write, no profile DB write, no public publish, no Flutter secrets.',
  );
});
