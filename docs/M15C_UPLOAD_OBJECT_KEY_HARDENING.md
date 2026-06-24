# M15C Upload Object Key Hardening

M15C verifies upload object key safety without opening real upload.

## Branch

m15c-upload-object-key-hardening

## Scope

The checked function is:

buildUploadObjectKey

from:

server/media/objectStoragePresignerClient.js

## Verified behavior

The check confirms:

- object keys always start under uploads/
- CID segment is sanitized
- surface segment is sanitized
- filename segment is sanitized
- path traversal input does not survive as ../
- backslash path input does not survive
- empty values fall back safely
- long filename segment is capped
- Object Storage write remains closed
- signed upload URL creation is not executed
- media metadata write remains closed

## Locked boundaries preserved

M15C does not open:

- Flutter signed PUT
- Object Storage PUT
- signed URL runtime gate
- media metadata write
- profile DB write
- public media publish
- fake CID/session/token

## Runtime check

Run:

node scripts/m15c-upload-object-key-hardening-check.js

Expected result:

M15C_UPLOAD_OBJECT_KEY_HARDENING_OK
