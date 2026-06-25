# M16E Upload Request Signed URL Route Smoke

Date: 2026-06-25

## Status

M16E confirmed that the guarded server upload request route can return a signed Object Storage upload URL through the real HTTP handler path when server-only Object Storage smoke env and gates are enabled temporarily.

## Verified path

- VPS host: cidentia-live-api-01
- App path: /opt/cidentia-live/app/current
- Public API domain: https://api.cidentia.live
- Runtime process: cidentia-live-disabled-backend
- Route handler tested: api/upload/request.js
- Presigner: server/media/objectStoragePresignerClient.js
- Bucket: cidentia-live-media

## Successful route smoke result

The temporary local HTTP route smoke returned:

- httpStatus: 200
- code: SIGNED_UPLOAD_URL_CREATED
- signedUploadUrlCreated: true
- uploadUrl: redacted in logs
- storageBucket: cidentia-live-media
- storageObjectKey: uploads/Cid-M16E-Route-Smoke/profile-cover/...
- mediaMetadataCreated: false
- secretsExposed: false

## Safety boundary

This smoke used server-only env from:

- /opt/cidentia-live/env/object-storage-live-smoke.env

Secrets were not printed in chat or logs. The signed upload URL was redacted.

The public PM2 process was not permanently changed. Upload gates were exported only in the temporary shell for the route smoke and then unset.

## Still locked

M16E does not open production/user-facing upload.

The following remain locked:

- media metadata DB write
- profile DB write
- public media publish
- permanent media URL
- Flutter secrets
- fake CID/session/token
- wallet/payment/token/blockchain
- RTMP/WebRTC/live stream

## Relation to M16D

M16D already merged Flutter support for this response shape.

When the backend returns:

- signedUploadUrlCreated: true
- uploadUrl: valid signed URL

Flutter can PUT selected profile cover bytes and show:

Cover uploaded. Metadata write is still locked.

If the public backend remains locked, Flutter keeps local preview behavior and shows locked boundary feedback.

## Next milestone

M16F should decide how to enable a controlled user-facing signed upload request path without opening media metadata persistence or public publishing.

Recommended next step:

- create a controlled staging/smoke process or deploy config for signed URL route
- do not put Object Storage secrets into Flutter
- keep metadata/profile DB writes disabled
- keep public media publishing disabled
