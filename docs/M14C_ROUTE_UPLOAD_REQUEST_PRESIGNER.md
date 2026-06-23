# M14C Route Upload Request Presigner

M14C routes `/api/upload/request` through the same guarded Object Storage presigner flow used by `/api/upload/signed-url`.

## Changed

- `api/upload/request.js`

## Added

- `scripts/m14c-route-upload-request-presigner-check.js`

## Behavior

`POST /api/upload/request` now:

- requires a CID from headers or body
- returns `CID_REQUIRED_FOR_UPLOAD` without CID
- calls the guarded Object Storage presigner with CID, filename, MIME type, and surface
- returns `OBJECT_STORAGE_PRESIGNER_DISABLED` while upload/storage/signed URL gates are closed
- returns `OBJECT_STORAGE_CONFIG_MISSING` if gates are open but server-only Object Storage env is incomplete
- can return `SIGNED_UPLOAD_URL_CREATED` only when all gates and server-only env are valid

## Locked boundaries

M14C does not add:

- Flutter UI
- test cards
- fake upload buttons
- gallery picker
- actual file upload
- Object Storage write from Flutter
- media metadata DB write
- wallet/payment
- RTMP/WebRTC
- frontend secrets

## Next safe step

M14D should add a server-side Object Storage live-smoke check that can validate env and signed URL generation on VPS without exposing secrets or uploading a real user file.
