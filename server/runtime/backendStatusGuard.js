function backendStatusGuard() {
  return {
    ok: true,
    service: 'cidentia-live-api',
    deployActive: false,
    stagingRuntimeReady: true,
    uploadLocked: true,
    objectStorageWrite: false,
    walletPaymentLocked: true,
    cidenDbSessionLive: false,
    cidenBridgeLive: false,
    rtmpLive: false,
    replayRecording: false,
    productionDeploy: false,
  };
}

function sendStatus(res, extra = {}) {
  return res.status(200).json({
    ...backendStatusGuard(),
    ...extra,
    guarded: true,
    readOnly: true,
  });
}

function sendLocked(res, route, code, message, extra = {}) {
  return res.status(503).json({
    ok: false,
    route,
    code,
    message,
    deployActive: false,
    uploadLocked: true,
    objectStorageWrite: false,
    walletPaymentLocked: true,
    cidenDbSessionLive: false,
    cidenBridgeLive: false,
    rtmpLive: false,
    replayRecording: false,
    guarded: true,
    readOnly: true,
    ...extra,
  });
}

module.exports = {
  backendStatusGuard,
  sendStatus,
  sendLocked,
};
