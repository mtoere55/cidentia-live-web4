# M7A Clone Media Flow Audit

## Scope

This audit compares the local Cidentia.Live media/create/live direction with the read-only Flutter Instagram offline-first clone reference.

Reference clone location:

`C:\PROJELER\cidentia-live-web4_reference\flutter-instagram-offline-first-clone-main\flutter-instagram-offline-first-clone-main`

The reference is used only for product and architecture learning. It must not be copied blindly.

## Clone finding: media/post flow

The clone does not implement a real live streaming system.

It implements a normal social media post/reel pipeline:

1. User selects photo/video media.
2. Video media can generate a thumbnail / first frame.
3. Video media can be compressed before upload.
4. Media bytes are uploaded to storage.
5. A post record is created through `PostsRepository.createPost`.
6. Feed, Reels and Profile consume repository-backed post data.
7. Feed updates are pushed into the FeedBloc state after post creation.

Important observed concepts:

- `create-post`
- `publish-post`
- `FeedBloc`
- `FeedPostCreateRequested`
- `PostsRepository.createPost`
- `PostsRepository.getPage`
- `postsToReelBlockMapper`
- video thumbnail / first frame
- video compression
- storage upload
- feed/reels/profile shared post model

## Clone finding: live/camera flow

The clone is not a live streaming engine.

It does not provide:

- real RTMP live broadcast
- WebRTC/SFU live room engine
- host/guest live room streaming backend
- live camera-to-broadcast pipeline
- screen share broadcasting
- live recording/replay pipeline

The clone may have camera/media selection surfaces, but its useful reference is uploadable media creation, not live streaming.

## Cidentia.Live current state

Cidentia.Live currently has safe local preview surfaces:

- Feed / Search / Reels public preview
- Create preview
- Draft tray preview
- Profile identity readiness
- Upload readiness boundary
- Live Studio readiness boundary
- Safe CidenDB/CID session state

Current media limitations:

- no real file picker
- no real media bytes
- no video thumbnail extraction
- no video compression
- no storage upload
- no server-backed post record
- no server-backed Feed/Reels/Profile data
- no live camera/mic/screen capture production stream
- no RTMP/WebRTC/SFU connection

## Decision

The previous local-only Feed insertion experiment is not the correct long-term path.

Cidentia.Live should not spend time filling the app with temporary local post state if the real system will later use server-backed media/post records.

The correct next direction is a backend/repository contract first.

## Recommended M7 path

M7 should handle normal social media media/post creation:

- M7B: Cidentia media/post backend contract
- M7C: Guarded media upload backend skeleton
- M7D: Flutter real media picker preparation
- M7E: Feed/Reels/Profile server-backed post model boundary

M7 must not open real storage or upload until the guarded backend boundary exists.

## Recommended M8 path

Live streaming should remain a separate milestone track:

- M8A: Live streaming architecture contract
- M8B: Camera/mic/screen permission boundary
- M8C: Local preview capture only
- M8D: Streaming backend decision: WebRTC/SFU vs RTMP
- M8E: Replay/recording to media-post pipeline

## Safe boundaries

Do not import or copy from the clone:

- Supabase auth
- Google/Firebase auth
- clone token storage
- clone password login
- clone identity model
- clone backend secrets
- clone storage credentials

Cidentia rules remain:

- CidenDB is identity/databank authority.
- CidentiaApp is onboarding/registration authority.
- CidenBridge is future integration/bridge layer.
- Cidentia.Live accepts verified CID session state.
- Flutter must not hold raw CidenDB tokens or secrets.
- No fake CID/session/token.
- No wallet/payment/blockchain action.
- No real RTMP/live broadcast until approved.
