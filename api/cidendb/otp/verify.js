const {
  getCidenDbBridgeState,
  sendJson,
  statusForCode,
} = require('../../../server/cidendb/cidenDbBridgeGuard');

module.exports = async function handler(request, response) {
  if (request.method !== 'POST') {
    return sendJson(response, 405, {
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST for CidenDB OTP verify.',
      liveCidenDbCall: false,
      fakeSuccess: false,
      sessionCreated: false,
    });
  }

  const state = getCidenDbBridgeState();

  return sendJson(response, statusForCode(state.response.code), {
    ...state.response,
    route: '/api/cidendb/otp/verify',
  });
};
