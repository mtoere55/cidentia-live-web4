# M20E — Media URL Policy Plan

Status: Policy plan only.

## Purpose

M20E defines the required safety policy before any real media URL can be rendered in Flutter or exposed through API responses.

M20E does not open media rendering.

## Current safe state

Profile tab backend boundaries exist:

- `GET /api/profile/posts`
- `GET /api/profile/reels`
- `GET /api/profile/media`

Flutter can request Posts and Reels boundary status, but still keeps the placeholder grid unchanged.

Repository mapped items currently return:

- `publicMediaUrl:null`

## Core rule

No media asset may receive a public URL by default.

A media URL can only be returned when all required gates are explicitly passed.

## Required gates before public URL rendering

A media item must satisfy all of these:

1. verified CID exists
2. owner CID is known
3. media asset exists in `cidentia_media_assets`
4. `visibility` policy allows the current viewer
5. `moderation_status` allows display
6. storage object key is present
7. storage bucket is allowed for the surface
8. route explicitly allows media URL generation
9. runtime explicitly enables media URL generation
10. frontend does not receive storage secrets

## Required locked behavior

When media URL generation is not enabled, API responses must keep:

- `publicMediaUrl:null`
- `publicMediaUrlsCreated:false`
- `storageSignedUrlCreated:false`
- `storageBucketExposed:false`
- `storageSecretExposed:false`
- `frontendSecretExposed:false`

## Visibility policy draft

Suggested future visibility levels:

- `private`
- `followers`
- `public`
- `proof_only`
- `owner_only`

Default must be:

- `private`

## Moderation policy draft

Suggested future moderation statuses:

- `pending`
- `approved`
- `rejected`
- `quarantined`

Only `approved` may be considered for public rendering.

Default must be:

- `pending`

## Surface policy draft

Different surfaces may need different media URL rules:

- profile avatar
- profile cover
- profile tab posts
- profile tab reels
- profile tab media
- proof documents
- live room preview
- feed preview

A surface must be explicitly allowed before rendering media URLs.

## Storage URL policy draft

Future URL generation must be server-side only.

Allowed future options:

- short-lived signed URL
- CDN-backed controlled URL
- internal proxy URL with policy checks

Disallowed:

- exposing Object Storage secrets to Flutter
- exposing raw storage credentials
- exposing unrestricted bucket/object access
- returning public URLs for private or pending assets

## Flutter policy

Flutter must not construct Object Storage URLs.

Flutter may only render a URL returned by a guarded backend route.

Flutter must keep placeholders when:

- CID is missing
- route is disabled
- media URL generation is disabled
- visibility is not allowed
- moderation is not approved
- backend returns `publicMediaUrl:null`

## Required future milestones

Recommended sequence:

1. M21A — media URL policy helper, disabled by default
2. M21B — media URL disabled API smoke
3. M21C — server-only signed URL smoke with temporary object, if storage gate is explicitly opened
4. M21D — Flutter media URL boundary read without rendering
5. M21E — first guarded avatar/cover rendering policy, still disabled by default
6. M21F — guarded profile tab media rendering policy

## Locked boundaries preserved

M20E does not open:

- public media URL generation
- signed URL generation
- Object Storage public access
- Object Storage secret exposure
- frontend secret
- Flutter real media rendering
- Flutter real posts rendering
- Flutter real reels rendering
- new Media tab
- fake posts
- fake reels
- fake media assets
- fake counters
- public feed publishing
- public upload/media route
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording
