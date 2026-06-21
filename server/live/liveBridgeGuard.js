function liveBridgeGuard() {
  const bridgeEnabled = process.env.LIVE_BRIDGE_ENABLED === 'true';
  const contractConfirmed = process.env.LIVE_CONTRACT_CONFIRMED === 'true';

  if (!bridgeEnabled) {
    return {
      enabled: false,
      statusCode: 503,
      code: 'LIVE_BRIDGE_DISABLED',
      message: 'Cidentia live bridge is disabled.',
      liveSessionCreated: false,
      liveBroadcastStarted: false,
      cameraStreamOpened: false,
      microphoneStreamOpened: false,
      screenCaptureOpened: false,
      rtmpConnected: false,
      webRtcConnected: false,
      recordingFileCreated: false,
      replayCreated: false,
    };
  }

  if (!contractConfirmed) {
    return {
      enabled: false,
      statusCode: 503,
      code: 'LIVE_CONTRACT_NOT_CONFIRMED',
      message: 'Cidentia live contract is not confirmed.',
      liveSessionCreated: false,
      liveBroadcastStarted: false,
      cameraStreamOpened: false,
      microphoneStreamOpened: false,
      screenCaptureOpened: false,
      rtmpConnected: false,
      webRtcConnected: false,
      recordingFileCreated: false,
      replayCreated: false,
    };
  }

  return {
    enabled: true,
    statusCode: 503,
    code: 'LIVE_UPSTREAM_NOT_IMPLEMENTED',
    message: 'Cidentia live upstream client is not implemented yet.',
    liveSessionCreated: false,
    liveBroadcastStarted: false,
    cameraStreamOpened: false,
    microphoneStreamOpened: false,
    screenCaptureOpened: false,
    rtmpConnected: false,
    webRtcConnected: false,
    recordingFileCreated: false,
    replayCreated: false,
  };
}

function sendJson(res, payload) {
  const statusCode = payload.statusCode || 503;
  return res.status(statusCode).json({
    ok: false,
    ...payload,
    readOnly: true,
    guarded: true,
    liveOrdersLocked: true,
  });
}

module.exports = {
  liveBridgeGuard,
  sendJson,
};
