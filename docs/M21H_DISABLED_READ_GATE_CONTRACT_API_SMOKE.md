# M21H — Disabled Read Gate Contract API Smoke

Status: Disabled API smoke only.

## Purpose

M21H verifies that the read/display signed media URL API boundary reads the env contract gates and remains disabled by default.

## Updated route

- `POST /api/media/read-url`

## Added smoke

- `scripts/m21h-disabled-read-gate-contract-api-smoke.js`

## Expected disabled result

- HTTP `503`
- `MEDIA_URL_GENERATION_DISABLED`
- `envContractRead:true`
- `mediaUrlGenerationLocked:true`
- `objectStorageReadLocked:true`
- `signedMediaReadUrlLocked:true`
- `publicMediaUrl:null`
- `signedMediaReadUrl:null`
- `signedMediaReadUrlCreated:false`
- `storageSignedUrlCreated:false`
- `objectStorageCalled:false`
- `objectStorageRead:false`
- `objectStorageWrite:false`
- `uploadPresignerTouched:false`
- `flutterOpened:false`
- `secretsExposed:false`

## Locked boundaries preserved

M21H does not open:

- VPS env gate change
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
