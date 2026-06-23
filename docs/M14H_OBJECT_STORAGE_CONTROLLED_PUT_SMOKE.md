# M14H - Object Storage controlled PUT smoke

## Status

Completed and verified on VPS cidentia-live-api-01.

## Scope

This milestone verified a controlled disposable Object Storage PUT smoke through a backend-generated signed upload URL.

## Runtime path

- VPS app path: /opt/cidentia-live/app/current
- Smoke script: scripts/m14h-object-storage-controlled-put-smoke-check.js
- Env file: /opt/cidentia-live/env/object-storage-live-smoke.env
- Env file permission: 600

## Default locked result

With Object Storage PUT smoke env disabled, the script returned OBJECT_STORAGE_PUT_SMOKE_DISABLED.

Default locked state confirmed signedUploadUrlCreated false, objectStorageWrite false, uploadCreated false, cleanupDone false, mediaMetadataCreated false, and secretsExposed false.

## Live controlled PUT result

With server-only Object Storage env loaded and CIDENTIA_OBJECT_STORAGE_PUT_SMOKE=true, the script returned OBJECT_STORAGE_PUT_SMOKE_OK.

Verified result:

- signedUploadUrlCreated true
- objectStorageWrite true
- uploadCreated true
- uploadedBytes 65
- cleanupDone true
- mediaMetadataCreated false
- secretsExposed false
- storageBucket cidentia-live-media
- storageObjectKey uploads/Cid-M14H-Put-Smoke/put-smoke/2026-06-23T23-54-44-401Z-m14h-put-smoke.txt

## Cleanup confirmation

The tiny disposable object was uploaded, verified, and deleted by the smoke script.

After the live smoke, Object Storage env variables were unset from the shell and the default locked check again returned OBJECT_STORAGE_PUT_SMOKE_DISABLED.

## Safety boundaries

No Object Storage credentials were exposed to Flutter, Git, chat, screenshots, public JavaScript, or client runtime.

No permanent public object was left in Object Storage.

No media metadata was written.

No database write was opened.

No Flutter file picker upload was opened.

No permanent PM2 upload/write gate was enabled.

No wallet, payment, RTMP, WebRTC, CidenBridge, or fake CID/session/token path was opened.

## Next safe milestone

M14I should connect Flutter local file picker/upload flow to the verified signed upload boundary while keeping metadata write and public media publishing locked until the next explicit gate.
