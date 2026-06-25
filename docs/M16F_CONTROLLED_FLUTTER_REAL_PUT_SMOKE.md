# M16F — Controlled Flutter Real PUT Smoke

Status: Completed and QA verified.

## Goal

M16F verified the first controlled Flutter-to-Object-Storage PUT path for profile cover media without opening normal production upload, metadata persistence, profile database writes, public publishing, wallet/payment, CidenBridge, RTMP/WebRTC, or fake session behavior.

## Verified flow

Flutter Windows was launched with:

- CIDENTIA_LIVE_API_BASE_URL=http://127.0.0.1:3012
- CIDENDB_ENTRY_BRIDGE_BASE_URL=http://127.0.0.1:3000

Windows port 3012 was an SSH tunnel to the VPS-only smoke server:

- Windows 127.0.0.1:3012
- VPS 127.0.0.1:3011
- Smoke server script: scripts/m16f-upload-smoke-server.js

The smoke route returned SIGNED_UPLOAD_URL_CREATED with signedUploadUrlCreated:true and a profile-cover storageObjectKey. The signed URL was redacted in logs.

Flutter selected a profile cover image and completed the real PUT through the signed URL.

Observed UI confirmation:

Cover uploaded. Metadata write is still locked.

## Public production lock verification

After the smoke test, the smoke server and tunnel were stopped.

Public API lock check returned:

- HTTP/2 503
- UPLOAD_ROUTE_DISABLED
- uploadLocked:true
- objectStorageWrite:false
- uploadCreated:false
- signedUploadUrlCreated:false
- mediaMetadataCreated:false
- readOnly:true

The VPS smoke server port 3011 was confirmed closed.

## Locked boundaries preserved

M16F did not open:

- normal public upload route
- metadata database write
- profile database write
- public media publish
- frontend Object Storage secrets
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Result

M16F proves the real signed PUT path works from Flutter through a controlled smoke-only server while the public backend remains locked.

Next safe milestone can be profile cover local preview polish or a guarded metadata-write plan. Metadata persistence remains disabled until explicitly opened.
