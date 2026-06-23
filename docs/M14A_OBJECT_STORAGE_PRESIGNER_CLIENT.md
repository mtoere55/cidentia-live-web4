# M14A Object Storage Presigner Client

M14A adds a guarded server-side Object Storage presigner client for future signed media uploads.

## Added

- `server/media/objectStoragePresignerClient.js`
- `scripts/m14a-object-storage-presigner-client-check.js`
- Server-only dependencies:
  - `@aws-sdk/client-s3`
  - `@aws-sdk/s3-request-presigner`

## Runtime gates

Signed upload URL creation remains locked unless all gates are enabled server-side:

- `CIDENTIA_UPLOAD_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=true`
- `CIDENTIA_SIGNED_URL_ENABLED=true`

## Required server-only Object Storage env

These values must stay outside Git and outside Flutter:

- `CIDENTIA_OBJECT_STORAGE_ENDPOINT`
- `CIDENTIA_OBJECT_STORAGE_BUCKET`
- `CIDENTIA_OBJECT_STORAGE_REGION`
- `CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID`
- `CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY`
- `CIDENTIA_SIGNED_UPLOAD_TTL_SECONDS`

## Locked by default

Default behavior remains safe:

- no upload is created
- no Object Storage write is performed
- no media metadata row is written
- no secret is exposed
- no Flutter secret is added
- no wallet/payment/RTMP/WebRTC path is opened

## Next safe step

M14B can route `/api/upload/signed-url` through this guarded presigner client, while preserving CID-required and disabled behavior when gates/env are missing.
