const http = require('http');

const sendHandler = require('../api/cidendb/otp/send');
const verifyHandler = require('../api/cidendb/otp/verify');

const port = Number(process.env.PORT || 3000);

function readBody(request) {
  return new Promise((resolve) => {
    let body = '';

    request.on('data', (chunk) => {
      body += chunk;
    });

    request.on('end', () => {
      resolve(body);
    });
  });
}

function sendJson(response, statusCode, payload) {
  response.statusCode = statusCode;
  response.setHeader('Content-Type', 'application/json; charset=utf-8');
  response.end(JSON.stringify(payload));
}

const server = http.createServer(async (request, response) => {
  const url = new URL(request.url || '/', `http://localhost:${port}`);

  try {
    const rawBody = await readBody(request);
    request.body = rawBody ? JSON.parse(rawBody) : {};

    if (url.pathname === '/api/cidendb/otp/send') {
      return sendHandler(request, response);
    }

    if (url.pathname === '/api/cidendb/otp/verify') {
      return verifyHandler(request, response);
    }

    return sendJson(response, 404, {
      ok: false,
      code: 'LOCAL_ROUTE_NOT_FOUND',
      message: 'Unknown local CidenDB disabled bridge route.',
      liveCidenDbCall: false,
      fakeSuccess: false,
      sessionCreated: false,
    });
  } catch (error) {
    return sendJson(response, 500, {
      ok: false,
      code: 'LOCAL_DISABLED_BRIDGE_ERROR',
      message: String(error && error.message ? error.message : error),
      liveCidenDbCall: false,
      fakeSuccess: false,
      sessionCreated: false,
    });
  }
});

server.listen(port, () => {
  console.log(`M4G local disabled CidenDB bridge listening on http://localhost:${port}`);
  console.log('Routes:');
  console.log('POST /api/cidendb/otp/send');
  console.log('POST /api/cidendb/otp/verify');
  console.log('No live CidenDB call, no OTP, no fake success, no session.');
});
