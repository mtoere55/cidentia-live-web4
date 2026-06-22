const http = require('http');

const routes = {
  'GET /api/profile/me': require('../api/profile/me'),
  'POST /api/profile/update': require('../api/profile/update'),
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
        'X-Cidentia-Profile-Boundary': 'guarded',
      });
      nativeRes.end(body);
    },
  };
}

function readJsonBody(req) {
  return new Promise((resolve) => {
    let raw = '';

    req.on('data', (chunk) => {
      raw += chunk;
    });

    req.on('end', () => {
      if (!raw) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(raw));
      } catch (_) {
        resolve({});
      }
    });

    req.on('error', () => {
      resolve({});
    });
  });
}

const server = http.createServer(async (req, res) => {
  const route = req.url.split('?')[0];
  const key = `${req.method} ${route}`;
  const handler = routes[key];

  if (!handler) {
    res.writeHead(404, {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store',
    });
    res.end(
      JSON.stringify({
        ok: false,
        code: 'PROFILE_ROUTE_NOT_FOUND',
        route,
      }),
    );
    return;
  }

  try {
    const body = req.method === 'POST' ? await readJsonBody(req) : {};
    await handler(
      {
        method: req.method,
        url: req.url,
        headers: req.headers,
        body,
      },
      createResponse(res),
    );
  } catch (error) {
    res.writeHead(500, {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store',
    });
    res.end(
      JSON.stringify({
        ok: false,
        code: 'PROFILE_LOCAL_SMOKE_SERVER_ERROR',
        message: error.message,
      }),
    );
  }
});

const port = Number(process.env.CIDENTIA_PROFILE_SMOKE_PORT || 3011);

server.listen(port, '127.0.0.1', () => {
  console.log(
    `Cidentia profile API smoke server listening on http://127.0.0.1:${port}`,
  );
  console.log(
    'Profile routes are guarded. No DB connection, profile write, upload, storage, wallet, CidenDB live session, RTMP, or deploy is opened.',
  );
});
