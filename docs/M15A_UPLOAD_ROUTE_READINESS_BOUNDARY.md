# M15A Upload Route Readiness Boundary

M15A verifies the guarded backend upload request route without opening production upload.

## Branch

m15a-upload-route-readiness-boundary

## Scope

The route under review is:

/api/upload/request

The route accepts a verified CID boundary request and delegates to the guarded Object Storage presigner boundary.

## Verified locked behavior

The M15A check confirms:

- Missing CID returns CID_REQUIRED_FOR_UPLOAD.
- Verified CID reaches the upload request boundary.
- Default runtime keeps Object Storage presigner disabled.
- Default verified-CID response remains OBJECT_STORAGE_PRESIGNER_DISABLED.
- No signed upload URL is created.
- No Object Storage write is executed.
- No upload object is created.
- No media metadata row is created.
- No secrets are exposed.

## Locked boundaries preserved

The following are not opened by M15A:

- Public production upload
- Flutter signed PUT
- Object Storage PUT
- Media metadata write
- Profile DB write
- Public media publish
- Avatar/cover persistence
- Wallet/payment/token/blockchain
- RTMP/WebRTC/live stream
- Fake CID/session/token

## Runtime check

Run:

node scripts/m15a-upload-route-readiness-boundary-check.js

Expected result:

M15A_UPLOAD_ROUTE_READINESS_OK

## Next safe step

M15B may prepare stricter upload request validation, such as allowed surfaces, MIME allowlist, byte size limits, and normalized object-key rules.

M15B must still keep Object Storage write and public Flutter PUT disabled by default.
