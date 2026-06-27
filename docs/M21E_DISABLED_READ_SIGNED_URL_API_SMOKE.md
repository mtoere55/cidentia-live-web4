# M21E — Disabled Read Signed URL API Boundary Smoke

Status: Disabled API boundary smoke only.

## Purpose

M21E verifies the M21D read/display signed media URL helper through a disabled API route.

M21E does not generate a signed media read URL.

## Added route

- `POST /api/media/read-url`

## Added smoke

- `scripts/m21e-disabled-read-signed-url-api-smoke.js`

## Expected disabled result

- HTTP `503`
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
- `uploadPresignerTouched:false`
- `flutterOpened:false`
- `secretsExposed:false`

## Upload/read separation

M21E uses only:

- `server/media/objectStorageReadPresignerClient.js`

It does not use or touch:

- `server/media/objectStoragePresignerClient.js`

## Locked boundaries preserved

M21E does not open:

- public media URL generation
- signed media read URL generation
- signed upload URL generation
- Object Storage client call
- Object Storage read
- Object Storage write
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
