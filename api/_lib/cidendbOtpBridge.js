'use strict';

const DEFAULT_UPSTREAM_BASE = 'https://api.cidendb.com/api/v1/auth/otp';
const MAX_IDENTIFIER_LENGTH = 160;
const MAX_OTP_LENGTH = 32;

function envFlag(name) {
  return String(process.env[name] || '').toLowerCase() === 'true';
}

function allowedOrigins() {
  return String(process.env.CIDENTIA_ALLOWED_ORIGIN || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

function setCors(req, res) {
  const requestOrigin = String(req.headers.origin || '').trim();
  const allowed = allowedOrigins();

  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'content-type');

  if (!allowed.length) {
    res.setHeader('Access-Control-Allow-Origin', requestOrigin || '*');
    return true;
  }

  if (requestOrigin && allowed.includes(requestOrigin)) {
    res.setHeader('Access-Control-Allow-Origin', requestOrigin);
    return true;
  }

  return false;
}

function sendJson(res, statusCode, payload) {
  res.statusCode = statusCode;
  res.setHeader('content-type', 'application/json; charset=utf-8');
  res.end(JSON.stringify(payload));
}

function handlePreflight(req, res) {
  const corsAllowed = setCors(req, res);

  if (!corsAllowed) {
    sendJson(res, 403, {
      ok: false,
      code: 'CIDENDB_ORIGIN_NOT_ALLOWED',
      message: 'CidenDB bridge origin is not allowed.',
    });
    return true;
  }

  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.end();
    return true;
  }

  return false;
}

function requirePost(req, res) {
  if (req.method === 'POST') return true;

  sendJson(res, 405, {
    ok: false,
    code: 'CIDENDB_METHOD_NOT_ALLOWED',
    message: 'Method not allowed.',
  });
  return false;
}

function requireEnabled(res) {
  if (!envFlag('CIDENDB_BRIDGE_ENABLED')) {
    sendJson(res, 503, {
      ok: false,
      code: 'CIDENDB_BRIDGE_DISABLED',
      message: 'CidenDB backend bridge is disabled.',
      session: null,
    });
    return false;
  }

  if (!envFlag('CIDENDB_CONTRACT_CONFIRMED')) {
    sendJson(res, 503, {
      ok: false,
      code: 'CIDENDB_CONTRACT_NOT_CONFIRMED',
      message: 'CidenDB backend contract is not confirmed.',
      session: null,
    });
    return false;
  }

  return true;
}

function parseBody(req) {
  if (!req.body) return {};

  if (typeof req.body === 'object') return req.body;

  if (typeof req.body === 'string') {
    const text = req.body.trim();
    if (!text) return {};
    return JSON.parse(text);
  }

  return {};
}

function sanitizeMessage(value, fallback) {
  const text = String(value || '').replace(/\s+/g, ' ').trim();
  if (!text) return fallback;
  return text.slice(0, 180);
}

function cleanIdentifier(value) {
  const identifier = String(value || '').trim();
  if (!identifier) return '';
  return identifier.slice(0, MAX_IDENTIFIER_LENGTH);
}

function cleanOtp(value) {
  const otp = String(value || '').trim();
  if (!otp) return '';
  return otp.slice(0, MAX_OTP_LENGTH);
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
    let found = true;

    for (const key of path.split('.')) {
      if (!cursor || typeof cursor !== 'object' || !(key in cursor)) {
        found = false;
        break;
      }
      cursor = cursor[key];
    }

    if (found && cursor !== undefined && cursor !== null) {
      const value = String(cursor).trim();
      if (value) return value;
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

async function postUpstream(path, payload) {
  const upstreamBase = String(
    process.env.CIDENDB_UPSTREAM_BASE || DEFAULT_UPSTREAM_BASE,
  ).replace(/\/$/, '');

  const response = await fetch(`${upstreamBase}/${path}`, {
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

async function handleOtpSend(req, res) {
  if (handlePreflight(req, res)) return;
  if (!requirePost(req, res)) return;
  if (!requireEnabled(res)) return;

  const body = parseBody(req);
  const identifier = cleanIdentifier(body.identifier);

  if (!identifier) {
    sendJson(res, 400, {
      ok: false,
      code: 'CIDENDB_IDENTIFIER_REQUIRED',
      message: 'CID, phone or email is required.',
    });
    return;
  }

  const upstream = await postUpstream('send', {
    contact: identifier,
    contact_type: contactType(identifier),
  });

  if (!upstream.ok || upstream.data.success === false) {
    sendJson(res, upstream.status || 502, {
      ok: false,
      code: 'CIDENDB_OTP_SEND_FAILED',
      message: sanitizeMessage(
        upstream.data.message || upstream.data.error,
        'CidenDB OTP send failed.',
      ),
    });
    return;
  }

  sendJson(res, 200, {
    ok: true,
    message: sanitizeMessage(upstream.data.message, 'OTP request accepted.'),
  });
}

async function handleOtpVerify(req, res) {
  if (handlePreflight(req, res)) return;
  if (!requirePost(req, res)) return;
  if (!requireEnabled(res)) return;

  const body = parseBody(req);
  const identifier = cleanIdentifier(body.identifier);
  const otp = cleanOtp(body.otp);

  if (!identifier || !otp) {
    sendJson(res, 400, {
      ok: false,
      code: 'CIDENDB_VERIFY_INPUT_REQUIRED',
      message: 'CID/email/phone and OTP are required.',
      session: null,
    });
    return;
  }

  const upstream = await postUpstream('verify', {
    contact: identifier,
    contact_type: contactType(identifier),
    code: otp,
  });

  if (!upstream.ok || upstream.data.success === false) {
    sendJson(res, upstream.status || 502, {
      ok: false,
      code: 'CIDENDB_OTP_VERIFY_FAILED',
      message: sanitizeMessage(
        upstream.data.message || upstream.data.error,
        'CidenDB OTP verify failed.',
      ),
      session: null,
    });
    return;
  }

  const session = safeSessionFrom(upstream.data, identifier);

  if (!session) {
    sendJson(res, 502, {
      ok: false,
      code: 'CIDENDB_SAFE_SESSION_MISSING',
      message: 'CidenDB verified, but no safe CID was returned.',
      session: null,
    });
    return;
  }

  sendJson(res, 200, {
    ok: true,
    message: sanitizeMessage(upstream.data.message, 'CID session verified.'),
    session,
  });
}

async function withBridgeErrors(res, fn) {
  try {
    await fn();
  } catch (_) {
    sendJson(res, 500, {
      ok: false,
      code: 'CIDENDB_BRIDGE_ERROR',
      message: 'CidenDB backend bridge error.',
      session: null,
    });
  }
}

module.exports = {
  handleOtpSend,
  handleOtpVerify,
  withBridgeErrors,
};
