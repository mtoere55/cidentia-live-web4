# M21I — Positive Read Gate Contract Smoke Without Object Storage

Status: Positive env gate contract smoke only.

## Purpose

M21I verifies that `/api/media/read-url` reads the env contract and moves past the default disabled gate when read/display gates are explicitly true in the local smoke process.

M21I does not generate signed media read URLs.

## Smoke behavior

The local smoke starts the disabled backend with:

- `CIDENTIA_MEDIA_URL_GENERATION_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_READ_ENABLED=true`
- `CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=true`

Expected route result:

- HTTP `503`
- `SIGNED_MEDIA_READ_URL_SIGNER_NOT_IMPLEMENTED`

This confirms the gate contract opens only inside the smoke process and still stops before any signer or Object Storage call.

## Expected safe result

- `envContractRead:true`
- `mediaUrlGenerationLocked:false`
- `objectStorageReadLocked:false`
- `signedMediaReadUrlLocked:false`
- `publicMediaUrl:null`
- `signedMediaReadUrl:null`
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
- `vpsEnvChanged:false`

## Added smoke

- `scripts/m21i-positive-read-gate-contract-smoke-no-storage.js`

## Locked boundaries preserved

M21I does not open:

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
