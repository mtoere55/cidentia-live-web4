# M8B Live Permission Boundary

## Purpose

M8B defines the permission boundary for future real live capture.

This milestone is documentation only. It does not add Android permissions, Windows capture code, Flutter camera packages, WebRTC packages, permission_handler, native capture bridges, RTMP, recording, or real live streaming.

## Current inspected state

### Android

Current Android manifest includes:

- android.permission.INTERNET
- android.permission.FOREGROUND_SERVICE
- android.permission.ACCESS_NETWORK_STATE
- media/storage related permissions
- VIBRATE

Current Android manifest does not expose live capture permissions for M8B:

- no CAMERA permission
- no RECORD_AUDIO permission
- no MediaProjection service contract for live studio capture

### Windows

Windows runner files currently show no camera, microphone, screen capture or media permission implementation.

### Flutter dependencies

pubspec.yaml currently does not expose a live streaming dependency boundary for:

- permission_handler
- flutter_webrtc
- WebRTC/SFU package
- screen capture package
- record package

### Live Studio UI

Live Studio already has local preview controls:

- Mic
- Camera
- Share Screen
- Record
- Go Live
- Destination manager
- RTMP testing notice

These controls are local-preview only.

## Future permission categories

Real live streaming will require a deliberate permission milestone before opening any production capture.

### Camera

Required for:

- host video
- guest video
- live room camera source
- future replay/recording source

Android future permission:

- android.permission.CAMERA

Flutter rule:

- permission request must happen only after explicit user action
- permission state must be visible in UI
- denial must keep Live Studio in preview mode
- no background camera capture

### Microphone

Required for:

- host audio
- guest audio
- live translation audio input
- recording/replay audio

Android future permission:

- android.permission.RECORD_AUDIO

Flutter rule:

- permission request must happen only after explicit user action
- user must be able to mute/stop immediately
- no hidden microphone capture
- no raw audio storage without explicit replay/recording milestone

### Screen share

Required for:

- screen source
- slides/source broadcast
- creator screen share
- future Android/desktop capture

Android future direction:

- MediaProjection consent flow
- foreground service
- visible capture notification
- one explicit user-approved session

Windows future direction:

- explicit desktop capture picker/session
- visible capture state
- stop control always available

Flutter rule:

- no screen capture permission in M8B
- no hidden screen reading
- no background capture
- no screenshots stored by default
- no upload without explicit later milestone

### Recording / replay

Required for:

- local replay
- live archive
- replay to media post pipeline

Future rule:

- recording must be visibly active
- recording file creation must be separate from permission boundary
- replay upload/publish must use the M7 media/post boundary
- no fake recording success

## Required verified CID rule

Live capture operations are creator operations.

Before requesting production permissions, Cidentia.Live must have:

- verified CidenDB/CID session
- user-initiated action
- visible permission explanation
- visible capture indicator
- stop/cancel path

Guests/viewers may watch public surfaces later, but they cannot host, share screen, start live, manage destination, or record without verified CID.

## Future implementation order

Recommended next M8 steps:

1. M8C: Live permission readiness UI
2. M8D: Guarded disabled live backend skeleton
3. M8E: Local preview capture design, still no real stream
4. M8F: Streaming engine decision: WebRTC/SFU vs RTMP
5. M8G: Replay/recording to media-post pipeline contract

## Locked boundaries

M8B does not open:

- android CAMERA permission
- android RECORD_AUDIO permission
- Android MediaProjection service
- Windows capture API
- camera package
- permission_handler package
- flutter_webrtc package
- microphone stream
- camera stream
- screen stream
- RTMP connection
- WebRTC peer connection
- SFU connection
- recording file
- replay upload
- live broadcast
- stream key storage
- fake permission success
- fake live success
