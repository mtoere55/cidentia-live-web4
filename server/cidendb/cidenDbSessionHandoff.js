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

  if (upstream.user && typeof upstream.user === 'object') {
    return upstream.user;
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

  const safeUser = {
    cid,
    email,
    display_name: user.display_name || user.displayName || null,
    trust_score: user.trust_score ?? user.trustScore ?? null,
    profile_complete: user.profile_complete ?? user.profileComplete ?? null,
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
