# M15D Upload Boundary Final Handoff

M15D seals the guarded upload boundary preparation line.

## Branch

m15d-upload-boundary-final-handoff

## Final chain

### M15A Upload route readiness

Commit:

a76f9f6 Add M15A upload route readiness boundary

Verified:

- /api/upload/request accepts guarded upload boundary requests.
- Missing CID returns CID_REQUIRED_FOR_UPLOAD.
- Verified CID reaches the upload boundary.
- Default runtime remains locked with OBJECT_STORAGE_PRESIGNER_DISABLED.
- No signed upload URL is created.
- No Object Storage write is executed.
- No upload object is created.
- No media metadata is written.
- No secrets are exposed.

### M15B Upload request validation

Commit:

c8bf160 Add M15B upload request validation boundary

Verified:

- filename validation
- surface validation
- profile-cover normalized to profile_cover
- mimeType allowlist validation
- byteLength positive check
- byteLength size limit check
- invalid requests return UPLOAD_REQUEST_VALIDATION_FAILED
- valid requests still remain locked with OBJECT_STORAGE_PRESIGNER_DISABLED

### M15C Upload object key hardening

Commit:

a205c96 Add M15C upload object key hardening check

Verified:

- object keys stay under uploads/
- CID segment is sanitized
- surface segment is sanitized
- filename segment is sanitized
- ../ traversal does not survive
- backslash path input does not survive
- empty values fall back safely
- long filename segment is capped

## Locked boundaries preserved

The following are still not opened:

- Flutter signed PUT
- public production upload
- Object Storage PUT from app runtime
- media metadata database write
- profile database write
- public media publish
- fake CID/session/token
- wallet/payment/token/blockchain
- RTMP/WebRTC/live stream

## Current status

The upload boundary is ready for the next controlled phase.

Current safe runtime expectation:

- Valid CID + valid request: OBJECT_STORAGE_PRESIGNER_DISABLED
- Invalid request: UPLOAD_REQUEST_VALIDATION_FAILED
- Missing CID: CID_REQUIRED_FOR_UPLOAD

## Next phase

M16A may begin the real upload path, but only as a controlled server-side/live-staging phase.

M16A must not immediately enable public Flutter PUT.

Recommended M16A order:

1. Confirm server-only Object Storage env on VPS.
2. Confirm upload gates remain disabled by default in PM2 runtime.
3. Add a controlled signed URL staging smoke path.
4. Confirm generated signed URL does not expose secrets.
5. Confirm object key follows M15C rules.
6. Only then decide whether Flutter receives a signed upload URL.
7. Metadata DB write must remain separate and locked until its own milestone.
