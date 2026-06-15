const BRIDGE_DISABLED = {
  ok: false,
  code: 'CIDENDB_BRIDGE_DISABLED',
  message:
    'CidenDB OTP bridge is disabled. Set CIDENDB_BRIDGE_ENABLED=true and CIDENDB_CONTRACT_CONFIRMED=true only after the contract is confirmed.',
  liveCidenDbCall: false,
  fakeSuccess: false,
  sessionCreated: false,
};

function getCidenDbBridgeState(env = process.env) {
  const bridgeEnabled = env.CIDENDB_BRIDGE_ENABLED === 'true';
  const contractConfirmed = env.CIDENDB_CONTRACT_CONFIRMED === 'true';

  if (!bridgeEnabled) {
    return {
      enabled: false,
      response: BRIDGE_DISABLED,
    };
  }

  if (!contractConfirmed) {
    return {
      enabled: false,
      response: {
        ok: false,
        code: 'CIDENDB_CONTRACT_NOT_CONFIRMED',
        message:
          'CidenDB OTP bridge is enabled but the CidenDB request/response contract is not confirmed.',
        liveCidenDbCall: false,
        fakeSuccess: false,
        sessionCreated: false,
      },
    };
  }

  return {
    enabled: false,
    response: {
      ok: false,
      code: 'CIDENDB_UPSTREAM_CLIENT_NOT_IMPLEMENTED',
      message:
        'CidenDB OTP contract flags are enabled, but the upstream client is intentionally not implemented in this skeleton.',
      liveCidenDbCall: false,
      fakeSuccess: false,
      sessionCreated: false,
    },
  };
}

function sendJson(response, statusCode, payload) {
  response.statusCode = statusCode;
  response.setHeader('Content-Type', 'application/json; charset=utf-8');
  response.end(JSON.stringify(payload));
}

function statusForCode(code) {
  switch (code) {
    case 'CIDENDB_BRIDGE_DISABLED':
    case 'CIDENDB_CONTRACT_NOT_CONFIRMED':
    case 'CIDENDB_UPSTREAM_CLIENT_NOT_IMPLEMENTED':
      return 503;
    default:
      return 500;
  }
}

module.exports = {
  getCidenDbBridgeState,
  sendJson,
  statusForCode,
};
