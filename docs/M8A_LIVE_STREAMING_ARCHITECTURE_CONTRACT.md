# M8A Live Streaming Architecture Contract

## Purpose

M8A defines the future real live streaming architecture for Cidentia.Live.

This milestone is documentation only. It does not open camera, microphone, screen capture, RTMP, WebRTC, SFU, recording, replay, storage, upload, wallet, payment, token or blockchain behavior.

## Current Live Studio state

Cidentia.Live already has a local Live Studio preview surface.

Current local-preview features include:

- Live Studio stage
- Stage Focus
- stage chat overlay
- Live Translation Hub
- scene strip
- room modes
- mic toggle preview
- camera toggle preview
- recording indicator preview
- screen share notice
- invite guest notice
- destinations panel
- Custom RTMP preview
- destination manager preview
- Go Live protected action boundary

Current behavior is intentionally locked:

- no real camera stream
- no real microphone stream
- no real screen capture
- no real RTMP connection
- no real WebRTC/SFU connection
- no real stream key storage
- no real live broadcast
- no real recording file
- no real replay pipeline

## Identity and permission rule

Real creator live streaming requires a verified CidenDB/CID session.

Public viewers may browse public live/replay surfaces later, but creator operations require verified CID.

Protected creator operations include:

- start live
- stop live
- invite guest
- approve guest
- share screen
- manage RTMP destinations
- manage stream keys
- create replay
- publish replay
- monetize/support live room
- proof/effect/live achievement actions

Flutter must not store:

- raw CidenDB JWT
- access token
- refresh token
- id token
- RTMP stream key
- wallet key
- payment key
- backend secret

## Candidate architecture

Cidentia.Live should treat real live streaming as two possible backend strategies.

### Option A: WebRTC / SFU live room

Best for:

- host + guest live rooms
- low latency
- live chat synchronization
- multi guest mode
- live room proof/effects
- future watch party or co-host features

Required backend concepts:

- signaling server
- room session
- host track
- guest tracks
- SFU/media server
- viewer distribution
- room health events
- moderation state
- replay recorder bridge

Possible future tools:

- LiveKit
- mediasoup
- Janus
- Jitsi-based architecture
- custom WebRTC signaling plus SFU

Decision not made in M8A.

### Option B: RTMP ingest / destination routing

Best for:

- stream to YouTube, Twitch, Facebook, TikTok or custom RTMP
- creator studio destination routing
- broadcast style live
- compatibility with OBS-like workflows

Required backend concepts:

- RTMP ingest endpoint
- destination registry
- encrypted stream key storage
- destination health check
- reconnect policy
- live status events
- stream archive
- replay handoff to media/post pipeline

Decision not made in M8A.

## Recommended hybrid direction

A future production design may use both:

- WebRTC/SFU for Cidentia.Live native rooms, host/guest, mobile live and low-latency interaction.
- RTMP routing for external platform destinations and OBS-style studio output.

M8A does not choose or implement the final streaming engine. It defines the boundary.

## Backend route contract draft

Future guarded routes may include:

- POST /api/live/session/create
- POST /api/live/session/start
- POST /api/live/session/stop
- POST /api/live/guest/invite
- POST /api/live/guest/approve
- POST /api/live/screen/start
- POST /api/live/screen/stop
- POST /api/live/destinations
- POST /api/live/destinations/test
- POST /api/live/replay/create
- POST /api/live/replay/publish
- GET /api/live/session/:id
- GET /api/live/health/:id

All routes must default to disabled/guarded until explicitly opened.

## State model draft

A live session should include:

- liveSessionId
- ownerCid
- title
- mode: normal, vs_battle, multi_guest, proof_room, support_effect
- status: draft, ready, live, paused, ended, failed
- visibility: public, followers, private
- startedAt
- endedAt
- viewerCount
- destinations[]
- guests[]
- replayStatus
- health

A destination should include:

- destinationId
- ownerCid
- type: youtube, twitch, facebook, instagram, tiktok, custom_rtmp
- displayName
- encryptedCredentialRef
- status: locked, disabled, ready, testing, live, failed
- lastHealthCheckAt

A replay should include:

- replayId
- liveSessionId
- ownerCid
- mediaId
- postId optional
- durationMs
- thumbnailUrl
- status: recording, processing, ready, published, failed

## Flutter boundary

Flutter may show readiness and local preview states.

Flutter must not open production capture in M8A:

- no camera permission request
- no microphone permission request
- no screen capture permission request
- no RTMP connection
- no WebRTC peer connection
- no stream key entry with real secret storage
- no recording file
- no replay upload

Future M8 milestones should open capability step by step.

## Future M8 order

Recommended order:

1. M8B: Camera / mic / screen permission boundary
2. M8C: Local preview capture only
3. M8D: Streaming backend decision: WebRTC/SFU vs RTMP
4. M8E: Guarded disabled live backend skeleton
5. M8F: Live session state model
6. M8G: Replay / recording to media-post pipeline contract

## Locked boundaries

M8A does not open:

- real camera
- real microphone
- real screen capture
- RTMP
- WebRTC
- SFU
- stream key storage
- destination connection testing
- live broadcast
- recording file creation
- replay upload
- media storage
- wallet/payment/token/blockchain
- fake live success
- fake viewer traffic
