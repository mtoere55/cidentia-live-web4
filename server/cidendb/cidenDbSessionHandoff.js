const crypto = require('crypto');

const localSessions = new Map();
const CIDENTIA_APP_ONBOARDING_URL = 'https://cidentiaapp.com';

function nowSeconds() {
  return Math.floor(Date.now() / 1000);
}

function pickUser(upstream) {
  if (!upstream || typeof upstream !== 'object') {
    return {};
  }

  const candidates = [
    upstream.user,
    upstream.data && upstream.data.user,
    upstream.identity,
    upstream.profile,
    upstream.data && upstream.data.identity,
    upstream.data && upstream.data.profile,
    upstream.data,
  ];

  for (const candidate of candidates) {
    if (candidate && typeof candidate === 'object') {
      return candidate;
    }
  }

  return {};
}

function pickCid(user) {
  return (
    user.cid ||
    user.cid_number ||
    user.cidNumber ||
    user.ciden_id ||
    user.cidenId ||
    user.cidentia_id ||
    user.cidentiaId ||
    user.id ||
    null
  );
}


function cleanText(value, limit = 160) {
  const text = String(value ?? '').trim();
  return text ? text.slice(0, limit) : null;
}

function pickText(sources, keys) {
  for (const source of sources) {
    if (!source || typeof source !== 'object') {
      continue;
    }

    for (const key of keys) {
      const value = cleanText(source[key]);
      if (value) {
        return value;
      }
    }
  }

  return null;
}

function buildDisplayName(upstream, user) {
  const sources = [
    user,
    upstream && upstream.user,
    upstream && upstream.identity,
    upstream && upstream.profile,
    upstream && upstream.data && upstream.data.user,
    upstream && upstream.data && upstream.data.identity,
    upstream && upstream.data && upstream.data.profile,
    upstream && upstream.data,
  ];

  const direct = pickText(sources, [
    'display_name',
    'displayName',
    'public_name',
    'publicName',
    'full_name',
    'fullName',
    'real_name',
    'realName',
    'legal_name',
    'legalName',
    'name',
    'company_name',
    'companyName',
  ]);

  if (direct) {
    return direct;
  }

  const firstName = pickText(sources, [
    'first_name',
    'firstName',
    'firstname',
    'given_name',
    'givenName',
  ]);
  const middleName = pickText(sources, [
    'middle_name',
    'middleName',
    'middlename',
  ]);
  const lastName = pickText(sources, [
    'last_name',
    'lastName',
    'lastname',
    'family_name',
    'familyName',
    'surname',
  ]);

  const parts = [firstName, middleName, lastName].filter(Boolean);
  return parts.length ? parts.join(' ') : null;
}

function buildSafeSessionFromVerify(upstream, fallbackContact) {
  const user = pickUser(upstream);
  const cid = pickCid(user);
  const email = user.email || fallbackContact || null;

  if (!cid) {
    return {
      sessionCreated: false,
      onboardingRequired: true,
      redirectUrl: CIDENTIA_APP_ONBOARDING_URL,
      code: 'CIDENDB_VERIFY_OK_CID_REQUIRED',
      message:
        'CidenDB verify succeeded, but no CID was returned. User must complete CidentiaApp onboarding before Cidentia.Live can create a verified session.',
      safeUser: {
        email,
        is_new_user: upstream ? upstream.is_new_user : null,
      },
      safeSession: null,
    };
  }

  const upstreamSession =
    upstream.session && typeof upstream.session === 'object'
      ? upstream.session
      : {};

  const expiresInSeconds = Number(
    upstreamSession.expires_in_seconds ||
      upstreamSession.expiresInSeconds ||
      86400,
  );

  const issuedAt = nowSeconds();
  const expiresAt = issuedAt + expiresInSeconds;
  const sessionId =
    upstreamSession.session_id || upstreamSession.sessionId || crypto.randomUUID();

  const displayName = buildDisplayName(upstream, user);
  const profileIncomplete = !displayName;

  const safeUser = {
    cid,
    email,
    display_name: displayName,
    displayName,
    full_name: displayName,
    display_name_available: Boolean(displayName),
    profile_incomplete: profileIncomplete,
    trust_score: user.trust_score ?? user.trustScore ?? null,
    profile_complete:
      user.profile_complete ??
      user.profileComplete ??
      (profileIncomplete ? false : null),
    is_new_user: upstream.is_new_user ?? user.is_new_user ?? user.isNewUser ?? false,
  };

  const safeSession = {
    session_id: sessionId,
    expires_in_seconds: expiresInSeconds,
    safe_claims: {
      sub: cid,
      scope:
        upstreamSession.safe_claims && upstreamSession.safe_claims.scope
          ? upstreamSession.safe_claims.scope
          : 'user:read,user:profile',
      iat:
        upstreamSession.safe_claims && upstreamSession.safe_claims.iat
          ? upstreamSession.safe_claims.iat
          : issuedAt,
      exp:
        upstreamSession.safe_claims && upstreamSession.safe_claims.exp
          ? upstreamSession.safe_claims.exp
          : expiresAt,
    },
  };

  localSessions.set(sessionId, {
    cid,
    email,
    expiresAt,
    createdAt: issuedAt,
  });

  return {
    sessionCreated: true,
    onboardingRequired: false,
    redirectUrl: null,
    code: 'CIDENDB_SAFE_SESSION_CREATED',
    message:
      'Safe Cidentia.Live session reference created after CidenDB verify success.',
    safeUser,
    safeSession,
  };
}

function getLocalSession(sessionId) {
  const session = localSessions.get(sessionId);

  if (!session) {
    return null;
  }

  if (session.expiresAt <= nowSeconds()) {
    localSessions.delete(sessionId);
    return null;
  }

  return session;
}

module.exports = {
  buildSafeSessionFromVerify,
  getLocalSession,
};
