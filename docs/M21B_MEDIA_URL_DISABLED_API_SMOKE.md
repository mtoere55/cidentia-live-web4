# M21B — Media URL Disabled API Smoke

Status: Disabled API smoke only.

## Purpose

M21B verifies the M21A media URL policy helper through a disabled API route without generating public or signed media URLs.

## Added route

- `POST /api/media/url`

## Added smoke

- `scripts/m21b-media-url-disabled-api-smoke.js`

## Expected disabled result

- HTTP `503`
- `MEDIA_URL_GENERATION_DISABLED`
- `publicMediaUrl:null`
- `publicMediaUrlsCreated:false`
- `storageSignedUrlCreated:false`
- `storageBucketExposed:false`
- `storageSecretExposed:false`
- `frontendSecretExposed:false`
- `objectStorageCalled:false`
- `flutterOpened:false`
- `secretsExposed:false`

## Locked boundaries preserved

M21B does not open:

- public media URL generation
- signed URL generation
- Object Storage client call
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
