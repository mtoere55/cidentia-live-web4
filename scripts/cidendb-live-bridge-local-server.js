const http = require('http');

const {
  getCidenDbBridgeState,
  statusForCode,
} = require('../server/cidendb/cidenDbBridgeGuard');
const {
  sendOtp,
  verifyOtp,
} = require('../server/cidendb/cidenDbOtpClient');

const PORT = Number(process.env.CIDENDB_LOCAL_BRIDGE_PORT || 3000);

function sendJson(response, statusCode, payload) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-store',
  });
  response.end(JSON.stringify(payload, null, 2));
}

function readBody(request) {
  return new Promise((resolve, reject) => {
    let raw = '';

    request.on('data', (chunk) => {
      raw += chunk;
    });

    request.on('end', () => {
      if (!raw.trim()) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(raw));
      } catch (error) {
        reject(error);
      }
    });

    request.on('error', reject);
  });
}

async function handleOtp(request, response, route, action) {
  if (request.method !== 'POST') {
    return sendJson(response, 405, {
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST for CidenDB OTP routes.',
      liveCidenDbCall: false,
      fakeSuccess: false,
      sessionCreated: false,
      route,
    });
  }

  const state = getCidenDbBridgeState();

  if (!state.enabled) {
    return sendJson(response, statusForCode(state.response.code), {
      ...state.response,
      route,
    });
  }

  try {
    const body = await readBody(request);
    const result = await action(body);

    return sendJson(response, result.statusCode, {
      ...result.payload,
      route,
    });
  } catch (error) {
    return sendJson(response, 500, {
      ok: false,
      code: 'CIDENDB_LOCAL_LIVE_BRIDGE_ERROR',
      message: String(error && error.message ? error.message : error),
      liveCidenDbCall: false,
      fakeSuccess: false,
      sessionCreated: false,
      route,
    });
  }
}

const server = http.createServer((request, response) => {
  if (request.url === '/api/cidendb/otp/send') {
    return handleOtp(
      request,
      response,
      '/api/cidendb/otp/send',
      sendOtp,
    );
  }

  if (request.url === '/api/cidendb/otp/verify') {
    return handleOtp(
      request,
      response,
      '/api/cidendb/otp/verify',
      verifyOtp,
    );
  }

  return sendJson(response, 404, {
    ok: false,
    code: 'NOT_FOUND',
    message: 'Route not found.',
    liveCidenDbCall: false,
    fakeSuccess: false,
    sessionCreated: false,
  });
});

server.listen(PORT, () => {
  console.log(`CidenDB live local bridge listening on http://localhost:${PORT}`);
  console.log('Required env: CIDENDB_BRIDGE_ENABLED=true');
  console.log('Required env: CIDENDB_CONTRACT_CONFIRMED=true');
});