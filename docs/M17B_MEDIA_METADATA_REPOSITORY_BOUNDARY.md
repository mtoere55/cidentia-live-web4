# M17B — Media Metadata Repository Boundary

Status: Completed as a guarded backend repository boundary.

## Purpose

M17B prepares the future media metadata persistence layer for profile cover and creator media without enabling production writes.

This milestone adds a backend repository skeleton for `cidentia_media_assets`.

## Added files

- `server/media/mediaMetadataRepository.js`
- `scripts/m17b-media-metadata-repository-check.js`

## Repository behavior

The repository can sanitize and validate safe media metadata draft fields:

- owner CID
- surface
- storage bucket
- storage object key
- MIME type
- byte length
- upload status

Allowed surfaces are normalized to underscore format:

- `profile_cover`
- `avatar`
- `post`
- `reel`
- `live_replay`

## Guarded DB behavior

The repository uses the existing guarded database client.

When DB query gates are disabled, it returns a locked result and does not execute any insert.

Expected locked behavior:

- `mediaMetadataCreated:false`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

## Future write path

The future write path may insert into `cidentia_media_assets` only when explicit DB/query/write gates are enabled.

M17B does not enable these gates.

## Locked boundaries preserved

M17B does not open:

- production upload route
- metadata database write by default
- profile database write
- public media publish
- Object Storage public URL exposure
- frontend Object Storage secrets
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Result

M17B prepares the media metadata repository boundary while keeping runtime persistence disabled by default.
