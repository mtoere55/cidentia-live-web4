'use strict';

const PRODUCTION_CAPABLE_FLAGS = Object.freeze([
  'CIDENTIA_BACKEND_DEPLOY_ACTIVE',
  'CIDENTIA_PRODUCTION_MODE',
  'CIDENTIA_UPLOAD_ENABLED',
  'CIDENTIA_OBJECT_STORAGE_ENABLED',
  'CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED',
  'CIDENTIA_SIGNED_URL_ENABLED',
  'CIDENTIA_MEDIA_METADATA_WRITE_ENABLED',
  'CIDENTIA_CIDENDB_SESSION_ENABLED',
  'CIDENTIA_CIDENBRIDGE_ENABLED',
  'CIDENTIA_WALLET_ENABLED',
  'CIDENTIA_PAYMENT_ENABLED',
  'CIDENTIA_RTMP_ENABLED',
  'CIDENTIA_WEBRTC_ENABLED',
  'CIDENTIA_REPLAY_RECORDING_ENABLED',
  'CIDENTIA_AI_PROVIDER_ENABLED',
]);

function readBooleanEnv(env, key) {
  const value = env[key];

  if (value === true || value === 'true' || value === '1' || value === 'yes') {
    return true;
  }

  return false;
}

function loadCidentiaEnvContract(env = process.env) {
  const gates = {};

  for (const key of PRODUCTION_CAPABLE_FLAGS) {
    gates[key] = readBooleanEnv(env, key);
  }

  const locked = {
    uploadLocked: !gates.CIDENTIA_UPLOAD_ENABLED,
    objectStorageWriteLocked: !gates.CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED,
    signedUrlLocked: !gates.CIDENTIA_SIGNED_URL_ENABLED,
    mediaMetadataWriteLocked: !gates.CIDENTIA_MEDIA_METADATA_WRITE_ENABLED,
    cidenDbSessionLocked: !gates.CIDENTIA_CIDENDB_SESSION_ENABLED,
    cidenBridgeLocked: !gates.CIDENTIA_CIDENBRIDGE_ENABLED,
    walletLocked: !gates.CIDENTIA_WALLET_ENABLED,
    paymentLocked: !gates.CIDENTIA_PAYMENT_ENABLED,
    rtmpLocked: !gates.CIDENTIA_RTMP_ENABLED,
    webRtcLocked: !gates.CIDENTIA_WEBRTC_ENABLED,
    replayRecordingLocked: !gates.CIDENTIA_REPLAY_RECORDING_ENABLED,
    aiProviderLocked: !gates.CIDENTIA_AI_PROVIDER_ENABLED,
  };

  return Object.freeze({
    ok: true,
    source: 'process.env',
    secretsExposed: false,
    dbConnected: false,
    objectStorageConnected: false,
    cidenDbLiveCall: false,
    cidenBridgeLiveCall: false,
    productionDeploy: gates.CIDENTIA_BACKEND_DEPLOY_ACTIVE && gates.CIDENTIA_PRODUCTION_MODE,
    gates: Object.freeze(gates),
    locked: Object.freeze(locked),
  });
}

module.exports = {
  PRODUCTION_CAPABLE_FLAGS,
  loadCidentiaEnvContract,
};
