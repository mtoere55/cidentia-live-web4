# M21D — Read-only Signed Media URL Helper Skeleton Disabled

Status: Helper skeleton only, disabled by default.

## Purpose

M21D adds a separate read/display signed media URL helper skeleton without generating any URL.

This helper is intentionally separate from the upload presigner.

## Added helper

- `server/media/objectStorageReadPresignerClient.js`

## Added check

- `scripts/m21d-read-only-signed-media-url-helper-disabled-check.js`

## Default disabled result

The default result must remain:

- `MEDIA_URL_GENERATION_DISABLED`
- `publicMediaUrl:null`
- `signedMediaReadUrl:null`
- `publicMediaUrlsCreated:false`
- `signedMediaReadUrlCreated:false`
- `storageSignedUrlCreated:false`
- `objectStorageCalled:false`
- `objectStorageRead:false`
- `objectStorageWrite:false`
- `storageBucketExposed:false`
- `storageObjectKeyExposed:false`
- `storageSecretExposed:false`
- `frontendSecretExposed:false`
- `secretsExposed:false`

## Upload/read separation

M21D does not touch the existing upload presigner.

Existing upload presigner:

- `server/media/objectStoragePresignerClient.js`

New read/display helper skeleton:

- `server/media/objectStorageReadPresignerClient.js`

Upload signed URLs and read/display signed URLs must remain separate boundaries.

## Required future gates

The helper skeleton expects future read gates:

- media URL generation enabled
- Object Storage read enabled
- signed media read URL enabled

Default is disabled for all.

## Locked boundaries preserved

M21D does not open:

- public media URL generation
- signed media read URL generation
- signed upload URL generation
- Object Storage client call
- Object Storage read
- Object Storage write
- Object Storage public access
- Object Storage secret exposure
- frontend secret
- API route
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
