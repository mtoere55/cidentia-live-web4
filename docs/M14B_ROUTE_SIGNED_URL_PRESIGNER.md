# M14B Route Signed URL Presigner

M14B routes `/api/upload/signed-url` through the guarded Object Storage presigner client added in M14A.

## Changed

- `api/upload/signed-url.js`

## Added

- `scripts/m14b-route-signed-url-presigner-check.js`

## Behavior

`POST /api/upload/signed-url` now:

- requires a CID from headers or body
- returns `CID_REQUIRED_FOR_UPLOAD` without CID
- calls the guarded Object Storage presigner with CID, filename, MIME type, and surface
- returns `OBJECT_STORAGE_PRESIGNER_DISABLED` while upload/storage/signed URL gates are closed
- returns `OBJECT_STORAGE_CONFIG_MISSING` if gates are open but server-only Object Storage env is incomplete
- can return `SIGNED_UPLOAD_URL_CREATED` only when all gates and server-only env are valid

## Locked boundaries

M14B does not add:

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

M14C can connect `/api/upload/request` to the same guarded signed URL flow or add a server-side live smoke script for Object Storage env validation.
