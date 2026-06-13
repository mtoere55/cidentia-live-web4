'use strict';

const bridge = require('../../_lib/cidendbOtpBridge');

module.exports = async function handler(req, res) {
  return bridge.withBridgeErrors(res, () => bridge.handleOtpVerify(req, res));
};
