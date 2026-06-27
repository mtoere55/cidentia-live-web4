const http = require('http');

const routes = {
  'GET /api/health': require('../api/health'),
  'GET /api/status': require('../api/status'),
  'GET /api/storage/status': require('../api/storage/status'),
  'POST /api/upload/request': require('../api/upload/request'),
  'GET /api/profile/me': require('../api/profile/me'),
  'GET /api/profile/stats': require('../api/profile/stats'),
  'GET /api/profile/posts': require('../api/profile/posts'),
  'GET /api/profile/reels': require('../api/profile/reels'),
  'GET /api/profile/media': require('../api/profile/media'),
  'POST /api/profile/update': require('../api/profile/update'),
  'POST /api/social/follow': require('../api/social/follow'),
  'POST /api/social/unfollow': require('../api/social/unfollow'),
  'GET /api/social/followers': require('../api/social/followers'),
  'GET /api/social/following': require('../api/social/following'),
  'GET /api/cidendb/session/status': require('../api/cidendb/session/status'),
};

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
      });
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
