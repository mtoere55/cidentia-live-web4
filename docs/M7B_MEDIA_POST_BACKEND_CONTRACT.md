# M7B Cidentia Media/Post Backend Contract

## Purpose

This contract defines the future real media/post pipeline for Cidentia.Live.

It replaces temporary local-only post experiments with a guarded server-backed architecture.

## Target flow

1. Flutter user selects photo/video.
2. Flutter creates a local draft with caption, media type and file metadata.
3. Flutter sends upload request only with verified CID session.
4. Server validates CidenDB/CID session reference.
5. Server receives media.
6. Server stores media in approved storage.
7. Server creates post record.
8. Feed, Reels and Profile read server-backed post records.

## Required endpoints

### POST /api/media/upload

Uploads one media file.

Request requirements:

- verified Cidentia.Live session reference
- no raw CidenDB JWT from Flutter
- no frontend secret
- content type allowlist
- size limit
- media type: image or video

Expected response:

{
  "ok": true,
  "mediaId": "media_xxx",
  "mediaType": "image",
  "url": "server-controlled-url",
  "thumbnailUrl": "server-controlled-thumbnail-url",
  "width": 1080,
  "height": 1350,
  "durationMs": null,
  "blurHash": null,
  "uploadStatus": "ready"
}

### POST /api/posts/publish

Creates a post record from uploaded media.

Request requirements:

- verified Cidentia.Live session reference
- at least one uploaded mediaId
- caption optional
- post type: post, reel, story, replay

Expected response:

{
  "ok": true,
  "postId": "post_xxx",
  "cid": "Cid-26-00004",
  "postType": "post",
  "caption": "Example caption",
  "media": [],
  "createdAt": "server-time",
  "publishStatus": "published"
}

### GET /api/feed

Returns server-backed feed posts.

Query:

- cursor optional
- limit optional
- type optional

Expected response:

{
  "ok": true,
  "items": [],
  "nextCursor": null
}

### GET /api/reels

Returns server-backed reel posts.

### GET /api/profile/:cid/posts

Returns posts owned by a verified CID profile.

## Media model

A media record should contain:

- mediaId
- ownerCid
- mediaType: image, video
- source: upload, live_replay, story, studio_clip
- url
- thumbnailUrl
- width
- height
- durationMs
- blurHash
- storageProvider
- createdAt
- status

## Post model

A post record should contain:

- postId
- ownerCid
- ownerDisplayName
- ownerEmail optional
- postType: post, reel, story, replay
- caption
- media[]
- visibility
- createdAt
- updatedAt
- likeCount
- commentCount
- shareCount
- saveCount
- status

## Security rules

Flutter must not store or send:

- raw CidenDB JWT
- access token
- refresh token
- id token
- storage secret
- upload secret
- wallet key
- payment key
- RTMP stream key

Flutter may send:

- safe Cidentia.Live session reference
- media metadata
- caption
- selected local file content during approved upload flow

Server must validate:

- session is active
- CID exists
- upload belongs to CID
- media type is allowed
- size limit is respected
- file extension and MIME type match
- post publish uses media owned by same CID

## Locked boundaries

This milestone does not open:

- real upload
- real storage
- real post publishing
- real video processing
- real live streaming
- RTMP
- WebRTC/SFU
- wallet/payment/blockchain

## Clone reference mapping

The Flutter Instagram clone showed the useful normal media/post path:

- selected media
- thumbnail / first frame
- video compression
- storage upload
- repository createPost
- feed/reels/profile consuming shared post model

Cidentia.Live will not copy clone auth, Supabase auth, token storage or identity model.

## Future milestones

- M7C: guarded disabled upload backend skeleton
- M7D: Flutter create screen real media picker preparation
- M7E: Feed/Reels/Profile server-backed post model boundary
- M8A: live streaming architecture contract
