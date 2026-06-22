# M11G — CID-Gated Upload Request Boundary

## Purpose

M11G adds a CID requirement to the upload request boundary without opening real
upload, Object Storage, signed URL creation, or media metadata write.

## Route

POST /api/upload/request

## Missing CID Response

If no CID is supplied through a guarded request boundary:

- HTTP 401
- code: CID_REQUIRED_FOR_UPLOAD
- uploadCreated: false
- signedUploadUrlCreated: false
- mediaMetadataCreated: false
- cidRequired: true
- cidVerified: false
- guarded: true
- readOnly: true

## CID Present But Upload Locked

If a CID is present, upload still remains disabled by default:

- HTTP 503
- code: UPLOAD_ROUTE_DISABLED
- uploadCreated: false
- signedUploadUrlCreated: false
- mediaMetadataCreated: false
- cidRequired: true
- cidVerified: false

## CID Source

This skeleton may read CID from:

- x-cidentia-cid header
- x-cid header
- body.ownerCid
- body.cid

This does not verify a live CidenDB session yet. It only creates the upload
request boundary shape.

## Locked Boundaries

M11G does not open:

- real upload
- file picker
- Object Storage connection/write
- signed upload URL creation
- media metadata write
- database connection
- public media read
- replay recording
- RTMP/WebRTC
- wallet/payment
- CidenBridge live calls
- fake CID/session/token

## Next Safe Step

A later milestone may connect the Flutter verified session CID into this
request boundary, still without opening upload.
