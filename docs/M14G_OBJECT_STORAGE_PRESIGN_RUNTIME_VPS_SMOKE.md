# M14G - Object Storage presign runtime VPS smoke

## Status

Completed and verified on VPS cidentia-live-api-01.

## Scope

This milestone verified that the guarded Object Storage presigner runtime can create a short-lived signed upload URL from the VPS backend with server-only Object Storage environment loaded.

## Verified runtime path

- VPS app path: /opt/cidentia-live/app/current
- Server package path: /opt/cidentia-live/app/current/server
- Smoke script: scripts/m14d-object-storage-live-smoke-check.js
- Env file: /opt/cidentia-live/env/object-storage-live-smoke.env
- Env file permission: 600

## Results

Default locked check returned OBJECT_STORAGE_LIVE_SMOKE_DISABLED with signedUploadUrlCreated false, objectStorageWrite false, uploadCreated false, mediaMetadataCreated false, and secretsExposed false.

Live server-only env check returned SIGNED_UPLOAD_URL_CREATED with signedUploadUrlCreated true, storageBucket cidentia-live-media, expiresInSeconds 900, objectStorageWrite false, uploadCreated false, mediaMetadataCreated false, and secretsExposed false.

After the live smoke, Object Storage env variables were unset from the shell and the default locked check again returned OBJECT_STORAGE_LIVE_SMOKE_DISABLED.

## Safety boundaries

No Object Storage credentials were exposed to Flutter, Git, chat, logs, screenshots, or public JavaScript.

No real file upload was executed.

No media metadata was written.

No database write was opened.

No public media read path was opened.

No permanent PM2 upload/write gate was enabled.

The smoke only verified signed PUT URL creation through the backend presigner boundary.

## Next safe milestone

M14H should be a controlled disposable Object Storage PUT smoke using a tiny test object, followed by verification and cleanup.

Flutter file picker and user media upload should come after the controlled PUT smoke.
