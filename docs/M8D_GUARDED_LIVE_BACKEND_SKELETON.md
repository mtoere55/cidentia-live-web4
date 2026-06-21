# M8D Guarded Live Backend Skeleton

## Status

M8D adds a disabled and guarded live backend skeleton.

## Purpose

The purpose is to reserve the future live route shape without opening real streaming capability.

## Added guard

- server/live/liveBridgeGuard.js

Default guard states:

- LIVE_BRIDGE_DISABLED
- LIVE_CONTRACT_NOT_CONFIRMED
- LIVE_UPSTREAM_NOT_IMPLEMENTED

All states return safe flags:

- liveSessionCreated: false
- liveBroadcastStarted: false
- cameraStreamOpened: false
- microphoneStreamOpened: false
- screenCaptureOpened: false
- rtmpConnected: false
- webRtcConnected: false
- recordingFileCreated: false
- replayCreated: false
- readOnly: true
- guarded: true

## Added routes

- POST /api/live/session/create
- POST /api/live/session/start
- POST /api/live/session/stop
- GET /api/live/session/status
- POST /api/live/guest/invite
- POST /api/live/guest/approve
- POST /api/live/screen/start
- POST /api/live/screen/stop
- POST /api/live/destinations/index
- POST /api/live/destinations/test
- POST /api/live/replay/create
- GET /api/live/health/status

## Locked boundaries

M8D does not open:

- camera permission
- microphone permission
- screen capture permission
- MediaProjection
- Windows capture
- RTMP
- WebRTC
- SFU
- stream key storage
- live session creation
- broadcast start
- guest connection
- destination connection
- recording file creation
- replay creation
- replay upload
- media storage
- wallet/payment/token/blockchain
- fake live success

## Future next step

M8E may connect Flutter Live Studio to these disabled routes as status preview only, or M8F may define the live session state model first.
