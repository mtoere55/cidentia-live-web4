# M8F Live Session State Model

## Status

M8F adds the local Flutter live session state model boundary.

## Purpose

This milestone defines the future live session data shape without creating a real session.

## Added Flutter model boundary

File:

- lib/local_social/local_social_data.dart

Added model classes:

- LiveSessionStateModel
- LivePermissionStateModel
- LiveSourceStateModel
- LiveDestinationStateModel
- LiveGuestStateModel
- LiveReplayStateModel

Added constant:

- cidentiaLiveSessionBoundary

## Boundary state

The model is intentionally locked:

- liveSessionId: local-preview-live-session
- ownerCid: verified-cid-required
- status: guarded_disabled
- viewerCount: 0
- routeStatus: 503 guarded - live session model locked

## Locked capabilities

M8F does not open:

- live session creation
- camera stream
- microphone stream
- screen capture
- RTMP connection
- WebRTC connection
- SFU connection
- stream key storage
- guest connection
- recording file
- replay creation
- replay upload
- media publish
- wallet/payment/token/blockchain
- fake live success

## Relation to M8D

M8D added disabled backend routes.

M8F defines the matching Flutter state model boundary, but does not call those routes and does not create a production session.

## Future next step

M8G may connect the Live Studio UI to this local model boundary as display-only state, or define the replay/recording to media-post pipeline contract.
