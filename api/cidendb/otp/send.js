'use strict';

const bridge = require('../../_lib/cidendbOtpBridge');

module.exports = async function handler(req, res) {
  await bridge.withBridgeErrors(res, async () => {
    await bridge.handleOtpSend(req, res);
  });
};
