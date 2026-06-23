const http = require('http');

const routes = {
  'GET /api/health': require('../api/health'),
  'GET /api/status': require('../api/status'),
  'GET /api/storage/status': require('../api/storage/status'),
  'POST /api/upload/request': require('../api/upload/request'),
  'GET /api/profile/me': require('../api/profile/me'),
  'POST /api/profile/update': require('../api/profile/update'),
  'POST /api/cidendb/otp/send': require('../api/cidendb/otp/send'),
  'POST /api/cidendb/otp/verify': require('../api/cidendb/otp/verify'),
  'GET /api/cidendb/session/status': require('../api/cidendb/session/status'),
};

function createResponse(nativeRes) {
  return {
    statusCode: 200,
    headersSent: false,

    status(code) {
      this.statusCode = code;
      return this;
    },

    setHeader(name, value) {
      nativeRes.setHeader(name, value);
      return this;
    },

    getHeader(name) {
      return nativeRes.getHeader(name);
    },

    hasHeader(name) {
      return nativeRes.hasHeader(name);
    },

    writeHead(statusCode, headers) {
      this.statusCode = statusCode;
      this.headersSent = true;
      nativeRes.writeHead(statusCode, headers);
      return this;
    },

    end(body) {
      nativeRes.statusCode = this.statusCode;
      this.headersSent = true;
      nativeRes.end(body);
    },

    json(payload) {
      const body = JSON.stringify(payload);

      if (!nativeRes.hasHeader('Content-Type')) {
        nativeRes.setHeader('Content-Type', 'application/json');
      }

      if (!nativeRes.hasHeader('Cache-Control')) {
        nativeRes.setHeader('Cache-Control', 'no-store');
      }

      nativeRes.statusCode = this.statusCode;
      this.headersSent = true;
      nativeRes.end(body);
    },
  };
}

const server = http.createServer(async (req, res) => {
  const key = `${req.method} ${req.url.split('?')[0]}`;
  const handler = routes[key];

  if (!handler) {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      ok: false,
      code: 'ROUTE_NOT_FOUND',
      route: req.url,
    }));
    return;
  }

  try {
    await handler(req, createResponse(res));
  } catch (error) {
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      ok: false,
      code: 'LOCAL_DISABLED_SERVER_ERROR',
      message: error.message,
    }));
  }
});

const port = Number(process.env.CIDENTIA_DISABLED_BACKEND_PORT || 3010);

server.listen(port, '127.0.0.1', () => {
  console.log(`Cidentia disabled backend test server listening on http://127.0.0.1:${port}`);
  console.log('Routes are locked/read-only. Profile API is CID-gated. No upload, storage write, wallet, CidenDB live session, RTMP, or deploy is opened.');
});
