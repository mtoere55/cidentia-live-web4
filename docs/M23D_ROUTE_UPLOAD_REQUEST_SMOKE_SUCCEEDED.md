# M23D - Route-level upload request smoke succeeded

Status: completed.

## Purpose

M23D proves that the /api/upload/request route boundary can create a guarded signed upload URL for a video upload request with CID header validation, without exposing the signed URL, bucket, object key, or secrets in the smoke output.

## Server runtime

Server current path:

/opt/cidentia-live/app/current

PM2 process was not restarted and was not changed.

The smoke loaded Object Storage smoke env only for the current process.

## Route smoke input

Route:

/api/upload/request

Method:

POST

Headers:

- content-type: application/json
- x-cidentia-cid: Cid-M23D-Route-Smoke

Body:

- filename: m23d-route-video-smoke.mp4
- mimeType: video/mp4
- surface: reel_video
- byteLength: 24

## Route smoke result

- ok: true
- httpStatus: 200
- code: SIGNED_UPLOAD_URL_CREATED
- route: /api/upload/request
- cidRequired: true
- cidVerified: true
- guarded: true
- readOnly: false
- signedUploadUrlCreated: true
- uploadUrlPresentHidden: true
- storageBucketPresentHidden: true
- storageObjectKeyPresentHidden: true
- objectStorageWrite: false
- uploadCreated: false
- mediaMetadataCreated: false
- secretsExposed: false

## What this proves

- /api/upload/request can process a video upload request.
- CID header is required and verified at the route boundary.
- The route can call the signed upload URL helper successfully.
- A signed upload URL is created for ideo/mp4.
- The route remains guarded.
- The smoke output did not print the signed URL.
- The smoke output did not print the bucket value.
- The smoke output did not print the object key value.
- The smoke output did not print secrets.

## What is still not completed

- The route smoke did not PUT the file to Object Storage.
- The route smoke did not create persistent metadata.
- Flutter real video picker upload is not opened.
- Flutter real video render is not opened.
- Public media read/render path is not opened.
- PM2 production process was not restarted with upload env.

## Completed backend chain through M23D

- Signed video upload URL creation works.
- Object Storage video PUT works.
- Media metadata DB write and cleanup works.
- /api/upload/request route-level signed URL creation works.

## Next milestone

M23E - End-to-end server-only upload plus metadata smoke.

M23E should create a signed upload URL through the route, PUT a video/mp4 payload to Object Storage, then create a matching media metadata record and clean it up, while hiding URL, bucket, object key, and secrets.
