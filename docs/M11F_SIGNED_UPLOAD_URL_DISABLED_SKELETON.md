# M11F — Disabled Signed Upload URL Skeleton

## Purpose

M11F adds a disabled signed upload URL backend boundary without connecting to
Object Storage and without creating a real upload URL.

## Added Boundary

- server/media/signedUploadUrlBoundary.js
- api/upload/signed-url.js

## API Route

POST /api/upload/signed-url

Expected disabled response:

- HTTP 503
- code: SIGNED_UPLOAD_URL_DISABLED
- signedUploadUrlCreated: false
- objectStorageConnected: false
- objectStorageWrite: false
- uploadCreated: false
- mediaMetadataCreated: false
- uploadUrl: null
- storageBucket: null
- storageObjectKey: null
- guarded: true
- readOnly: true

## Locked Boundaries

M11F does not open:

- real upload
- file picker
- Object Storage connection
- Object Storage write
- signed upload URL creation
- media metadata write
- database connection
- public media read
- replay recording
- RTMP/WebRTC
- wallet/payment
- CidenBridge live calls
- fake CID/session/token

## Required Future Gates

A real signed upload URL may only be created later when all relevant gates are
explicitly enabled and verified:

- CIDENTIA_UPLOAD_ENABLED=true
- CIDENTIA_OBJECT_STORAGE_ENABLED=true
- CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=true
- CIDENTIA_SIGNED_URL_ENABLED=true
- CIDENTIA_CIDENDB_SESSION_ENABLED=true

## Next Safe Step

M11G may connect verified CID checks to the upload request boundary while still
returning locked responses when CID/session/gates are missing.
