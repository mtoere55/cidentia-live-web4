# M15B Upload Request Validation Boundary

M15B adds guarded validation before upload routes can request a signed upload URL.

## Routes

- /api/upload/request
- /api/upload/signed-url

## Validation

The boundary validates:

- filename exists
- filename length is limited
- surface is allowed
- hyphenated surface aliases such as profile-cover are normalized to profile_cover
- mimeType is allowed
- byteLength is positive
- byteLength does not exceed size limits

## Safe locked result

Invalid requests return:

UPLOAD_REQUEST_VALIDATION_FAILED

Valid requests still remain locked by default:

OBJECT_STORAGE_PRESIGNER_DISABLED

## Locked boundaries preserved

M15B does not open:

- Flutter signed PUT
- Object Storage PUT
- media metadata write
- profile DB write
- public media publish
- fake CID/session/token
