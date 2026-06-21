# M8G Replay / Recording to Media-Post Pipeline Contract

## Status

M8G defines the future replay and recording handoff from Live Studio to the media/post pipeline.

This milestone is documentation only.

## Purpose

Cidentia.Live will later allow a verified CID creator to turn a live recording or replay into a media-backed post.

M8G connects the concept boundaries from:

- M7B media/post backend contract
- M8A live streaming architecture contract
- M8F live session state model

It does not create real recording, upload, storage, replay or publishing behavior.

## Future target flow

1. Creator has a verified CidenDB/CID session.
2. Creator starts a guarded live session.
3. Live backend records or archives an approved live session.
4. Backend creates a replay record.
5. Replay processing creates a media record with source `live_replay`.
6. Creator reviews replay metadata.
7. Creator optionally publishes replay as a post.
8. Feed, Reels and Profile can later read replay posts through the M7 media/post pipeline.

## Required identity rule

Replay creation and replay publishing are protected creator operations.

Required:

- verified CidenDB/CID session
- active or completed liveSessionId owned by the same CID
- server-side validation
- no raw CidenDB token in Flutter
- no fake CID
- no fake session

## Future route contract

Future guarded routes may include:

- POST /api/live/replay/create
- POST /api/live/replay/process
- POST /api/live/replay/publish
- GET /api/live/replay/status
- POST /api/posts/publish with postType `replay`

All routes must default to disabled/guarded until real backend is approved.

## Replay model draft

A replay record should contain:

- replayId
- liveSessionId
- ownerCid
- title
- description optional
- durationMs
- thumbnailUrl
- source: live_recording, studio_clip, imported_replay
- status: recording, processing, ready, published, failed
- mediaId optional
- postId optional
- createdAt
- updatedAt

## Media handoff model

When replay is ready, backend may create a media record:

- mediaId
- ownerCid
- mediaType: video
- source: live_replay
- replayId
- liveSessionId
- url
- thumbnailUrl
- width
- height
- durationMs
- status: ready

## Post handoff model

When creator publishes replay, backend may create a post record:

- postId
- ownerCid
- postType: replay
- caption
- media[]
- replayId
- liveSessionId
- visibility
- publishStatus
- createdAt

## Flutter boundary

Flutter may later show:

- replay readiness
- processing status
- replay preview metadata
- publish replay button
- disabled/guarded backend status

Flutter must not in M8G:

- create local recording file
- upload replay
- publish replay
- store raw video bytes
- store stream keys
- fake mediaId
- fake postId
- fake publish success

## Backend boundary

Backend must later validate:

- session belongs to verified CID
- liveSessionId belongs to same CID
- replay belongs to same CID
- mediaId belongs to same CID
- publish request uses owned media
- file processing completed before publish
- storage URL is server-controlled
- thumbnail is server-controlled

## Locked boundaries

M8G does not open:

- camera stream
- microphone stream
- screen capture
- RTMP connection
- WebRTC connection
- SFU connection
- real recording
- replay file creation
- replay processing
- media upload
- media storage
- post publish
- feed/reels/profile fetch
- wallet/payment/token/blockchain
- fake live success
- fake replay success
- fake post success

## Future next step

M8H may add a display-only replay pipeline card in Live Studio, or M8 may be sealed with a final QA handoff before any real capture/backend milestone.
