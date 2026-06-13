const http = require('node:http');

const HOST = '127.0.0.1';
const PORT = Number(process.env.CIDENDB_LOCAL_BRIDGE_PORT || 8787);
const ENABLED = process.env.CIDENDB_LOCAL_BRIDGE_ENABLED === 'true';
const UPSTREAM_BASE =
  process.env.CIDENDB_UPSTREAM_BASE ||
  'https://api.cidendb.com/api/v1/auth/otp';

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'content-type': 'application/json; charset=utf-8',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'POST, OPTIONS',
    'access-control-allow-headers': 'content-type',
  });
  res.end(JSON.stringify(payload));
}

function contactType(identifier) {
  const value = String(identifier || '').trim();
  if (value.includes('@')) return 'email';
  if (/^\+?[0-9\s().-]+$/.test(value)) return 'phone';
  if (value.toUpperCase().startsWith('CID')) return 'cid';
  return 'email';
}

function pick(obj, paths) {
  for (const path of paths) {
    let cursor = obj;
    let ok = true;

    for (const key of path.split('.')) {
      if (!cursor || typeof cursor !== 'object' || !(key in cursor)) {
        ok = false;
        break;
      }
      cursor = cursor[key];
    }

    if (ok && cursor !== undefined && cursor !== null && String(cursor).trim()) {
      return String(cursor).trim();
    }
  }

  return '';
}

function safeSessionFrom(upstream, fallbackIdentifier) {
  const cid = pick(upstream, [
    'user.cid_number',
    'user.cid',
    'user.cidNumber',
    'data.user.cid_number',
    'data.user.cid',
    'data.user.cidNumber',
    'data.cid_number',
    'data.cid',
    'cid_number',
    'cid',
  ]);

  const displayName = pick(upstream, [
    'user.name',
    'user.full_name',
    'user.fullName',
    'user.email',
    'data.user.name',
    'data.user.full_name',
    'data.user.fullName',
    'data.user.email',
    'name',
    'email',
  ]);

  if (!cid) return null;

  return {
    status: 'signedIn',
    cid,
    identifier: fallbackIdentifier,
    displayName: displayName || 'Cidentia User',
  };
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const raw = Buffer.concat(chunks).toString('utf8');
  if (!raw.trim()) return {};
  return JSON.parse(raw);
}

async function postUpstream(path, payload) {
  const response = await fetch(`${UPSTREAM_BASE}/${path}`, {
    method: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify(payload),
  });

  const text = await response.text();
  let data = {};

  try {
    data = text ? JSON.parse(text) : {};
  } catch (_) {
    data = {message: text};
  }

  return {status: response.status, ok: response.ok, data};
}

async function handleSend(req, res) {
  if (!ENABLED) {
    return sendJson(res, 503, {
      ok: false,
      message: 'CidenDB local bridge is disabled.',
    });
  }

  const body = await readBody(req);
  const identifier = String(body.identifier || '').trim();

  if (!identifier) {
    return sendJson(res, 400, {
      ok: false,
      message: 'CID, phone or email is required.',
    });
  }

  const upstream = await postUpstream('send', {
    contact: identifier,
    contact_type: contactType(identifier),
  });

  if (!upstream.ok || upstream.data.success === false) {
    return sendJson(res, upstream.status || 502, {
      ok: false,
      message:
        upstream.data.message ||
        upstream.data.error ||
        'CidenDB OTP send failed.',
    });
  }

  return sendJson(res, 200, {
    ok: true,
    message: upstream.data.message || 'OTP request accepted.',
  });
}

async function handleVerify(req, res) {
  if (!ENABLED) {
    return sendJson(res, 503, {
      ok: false,
      message: 'CidenDB local bridge is disabled.',
    });
  }

  const body = await readBody(req);
  const identifier = String(body.identifier || '').trim();
  const otp = String(body.otp || '').trim();

  if (!identifier || !otp) {
    return sendJson(res, 400, {
      ok: false,
      message: 'CID/email/phone and OTP are required.',
    });
  }

  const upstream = await postUpstream('verify', {
    contact: identifier,
    contact_type: contactType(identifier),
    code: otp,
  });

  if (!upstream.ok || upstream.data.success === false) {
    return sendJson(res, upstream.status || 502, {
      ok: false,
      message:
        upstream.data.message ||
        upstream.data.error ||
        'CidenDB OTP verify failed.',
      session: null,
    });
  }

  const session = safeSessionFrom(upstream.data, identifier);

  if (!session) {
    return sendJson(res, 502, {
      ok: false,
      message: 'CidenDB verified, but no safe CID was returned.',
      session: null,
    });
  }

  return sendJson(res, 200, {
    ok: true,
    message: upstream.data.message || 'CID session verified.',
    session,
  });
}

const server = http.createServer(async (req, res) => {
  try {
    if (req.method === 'OPTIONS') return sendJson(res, 204, {});
    if (req.method !== 'POST') {
      return sendJson(res, 405, {ok: false, message: 'Method not allowed.'});
    }

    if (req.url === '/api/cidendb/otp/send') return handleSend(req, res);
    if (req.url === '/api/cidendb/otp/verify') return handleVerify(req, res);

    return sendJson(res, 404, {ok: false, message: 'Route not found.'});
  } catch (error) {
    return sendJson(res, 500, {
      ok: false,
      message: error && error.message ? error.message : 'Bridge error.',
    });
  }
});

server.listen(PORT, HOST, () => {
  console.log(`CidenDB local bridge listening on http://${HOST}:${PORT}`);
  console.log(`Enabled: ${ENABLED ? 'yes' : 'no'}`);
});
