const {
  getCidenDbBridgeState,
  sendJson,
  statusForCode,
} = require('../../../server/cidendb/cidenDbBridgeGuard');
const {
  readJsonBody,
  verifyOtp,
} = require('../../../server/cidendb/cidenDbOtpClient');

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

  if (!state.enabled) {
    return sendJson(response, statusForCode(state.response.code), {
      ...state.response,
      route: '/api/cidendb/otp/verify',
    });
  }

  try {
    const body = await readJsonBody(request);
    const result = await verifyOtp(body);

    return sendJson(response, result.statusCode, {
      ...result.payload,
      route: '/api/cidendb/otp/verify',
    });
  } catch (error) {
    return sendJson(response, 500, {
      ok: false,
      code: 'CIDENDB_VERIFY_BRIDGE_ERROR',
      message: String(error && error.message ? error.message : error),
      liveCidenDbCall: false,
      fakeSuccess: false,
      sessionCreated: false,
      route: '/api/cidendb/otp/verify',
    });
  }
};
