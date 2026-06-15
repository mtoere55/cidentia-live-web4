const {
  buildSafeSessionFromVerify,
} = require('./cidenDbSessionHandoff');

const DEFAULT_SEND_URL = 'https://api.cidendb.com/api/v1/auth/otp/send';
const DEFAULT_VERIFY_URL = 'https://api.cidendb.com/api/v1/auth/otp/verify';

const SENSITIVE_KEYS = new Set([
  'access_token',
  'id_token',
  'refresh_token',
  'token',
  'jwt',
  'secret',
  'password',
  'api_key',
  'apikey',
  'authorization',
]);

async function readJsonBody(request) {
  if (request.body && typeof request.body === 'object') {
    return request.body;
  }

  if (typeof request.body === 'string' && request.body.trim()) {
    return JSON.parse(request.body);
  }

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

function sanitizeValue(value) {
  if (Array.isArray(value)) {
    return value.map(sanitizeValue);
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value)
        .filter(([key]) => !SENSITIVE_KEYS.has(key.toLowerCase()))
        .map(([key, child]) => [key, sanitizeValue(child)]),
    );
  }

  return value;
}

function normalizeContact(body) {
  return `${body.contact || body.identifier || body.email || ''}`.trim();
}

function normalizeCode(body) {
  return `${body.code || body.otp || ''}`.trim();
}

async function postToCidenDb(url, payload) {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const text = await response.text();

  let upstreamBody;
  try {
    upstreamBody = text ? JSON.parse(text) : {};
  } catch (_) {
    upstreamBody = { message: text };
  }

  return {
    response,
    upstreamBody: sanitizeValue(upstreamBody),
  };
}

async function sendOtp(body, env = process.env) {
  const contact = normalizeContact(body);

  if (!contact) {
    return {
      statusCode: 400,
      payload: {
        ok: false,
        code: 'CIDENDB_CONTACT_REQUIRED',
        message: 'Email/contact is required.',
        liveCidenDbCall: false,
        fakeSuccess: false,
        sessionCreated: false,
      },
    };
  }

  const { response, upstreamBody } = await postToCidenDb(
    env.CIDENDB_OTP_SEND_URL || DEFAULT_SEND_URL,
    {
      contact,
      contact_type: body.contact_type || 'email',
    },
  );

  return {
    statusCode: response.status,
    payload: {
      ok: response.ok,
      code: response.ok ? 'CIDENDB_UPSTREAM_OK' : 'CIDENDB_UPSTREAM_ERROR',
      upstreamStatus: response.status,
      upstream: upstreamBody,
      liveCidenDbCall: true,
      fakeSuccess: false,
      sessionCreated: false,
    },
  };
}

async function verifyOtp(body, env = process.env) {
  const contact = normalizeContact(body);
  const code = normalizeCode(body);

  if (!contact || !code) {
    return {
      statusCode: 400,
      payload: {
        ok: false,
        code: 'CIDENDB_CONTACT_AND_CODE_REQUIRED',
        message: 'Email/contact and OTP code are required.',
        liveCidenDbCall: false,
        fakeSuccess: false,
        sessionCreated: false,
      },
    };
  }

  const { response, upstreamBody } = await postToCidenDb(
    env.CIDENDB_OTP_VERIFY_URL || DEFAULT_VERIFY_URL,
    {
      contact,
      contact_type: body.contact_type || 'email',
      code,
    },
  );

  if (!response.ok) {
    return {
      statusCode: response.status,
      payload: {
        ok: false,
        code: 'CIDENDB_UPSTREAM_ERROR',
        upstreamStatus: response.status,
        upstream: upstreamBody,
        liveCidenDbCall: true,
        fakeSuccess: false,
        sessionCreated: false,
      },
    };
  }

  const handoff = buildSafeSessionFromVerify(upstreamBody, contact);

  return {
    statusCode: response.status,
    payload: {
      ok: true,
      code: handoff.code,
      message: handoff.message,
      upstreamStatus: response.status,
      upstream: upstreamBody,
      user: handoff.safeUser,
      session: handoff.safeSession,
      onboardingRequired: handoff.onboardingRequired,
      redirectUrl: handoff.redirectUrl,
      liveCidenDbCall: true,
      fakeSuccess: false,
      sessionCreated: handoff.sessionCreated,
    },
  };
}

module.exports = {
  readJsonBody,
  sendOtp,
  verifyOtp,
};
