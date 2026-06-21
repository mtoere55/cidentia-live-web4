function mediaBridgeGuard() {
  const bridgeEnabled = process.env.MEDIA_BRIDGE_ENABLED === 'true';
  const contractConfirmed = process.env.MEDIA_CONTRACT_CONFIRMED === 'true';

  if (!bridgeEnabled) {
    return {
      enabled: false,
      statusCode: 503,
      code: 'MEDIA_BRIDGE_DISABLED',
      message: 'Cidentia media bridge is disabled.',
      liveUpload: false,
      storageWrite: false,
      postCreated: false,
    };
  }

  if (!contractConfirmed) {
    return {
      enabled: false,
      statusCode: 503,
      code: 'MEDIA_CONTRACT_NOT_CONFIRMED',
      message: 'Cidentia media contract is not confirmed.',
      liveUpload: false,
      storageWrite: false,
      postCreated: false,
    };
  }

  return {
    enabled: true,
    statusCode: 503,
    code: 'MEDIA_UPSTREAM_NOT_IMPLEMENTED',
    message: 'Cidentia media upstream client is not implemented yet.',
    liveUpload: false,
    storageWrite: false,
    postCreated: false,
  };
}

function sendJson(res, payload) {
  const statusCode = payload.statusCode || 503;
  return res.status(statusCode).json({
    ok: false,
    ...payload,
    readOnly: true,
    guarded: true,
  });
}

module.exports = {
  mediaBridgeGuard,
  sendJson,
};
