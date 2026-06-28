# M23J - Signed media read URL helper implementation

Status: completed.

## Purpose

M23J implements and verifies server-only signed media read URL generation for persisted media assets.

## Local implementation

Changed files:

- server/media/objectStorageReadPresignerClient.js
- api/media/read-url.js
- server/runtime/envContract.js

## Implementation details

The read presigner now uses:

- S3Client
- GetObjectCommand
- getSignedUrl

The helper now returns:

- code: SIGNED_MEDIA_READ_URL_CREATED
- signedMediaReadUrlCreated: true
- expiresInSeconds: 300 by default

The signed read URL itself must not be printed in smoke logs.

## Route alignment

api/media/read-url.js now calls createSignedMediaReadUrl instead of only evaluateSignedMediaReadUrlPolicy.

The route still remains guarded by env gates and must not be publicly opened without a separate milestone.

## Env contract alignment

server/runtime/envContract.js now includes read gates:

- CIDENTIA_MEDIA_URL_GENERATION_ENABLED
- CIDENTIA_OBJECT_STORAGE_READ_ENABLED
- CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED

Locked flags now include:

- mediaUrlGenerationLocked
- objectStorageReadLocked
- signedMediaReadUrlLocked

Server verification confirmed the gates resolve to true when passed inline for a smoke process, and locked values become false.

## Server deployment alignment

The following files were copied to the server artifact:

- server/media/objectStorageReadPresignerClient.js
- api/media/read-url.js
- server/runtime/envContract.js

The server artifact required api/media to be created because it was missing.

Server checks passed:

- read helper present
- read route present
- new driver.S3Client present
- new driver.GetObjectCommand present
- driver.getSignedUrl present
- SIGNED_MEDIA_READ_URL_CREATED present
- node --check passed for read helper
- node --check passed for read route
- node --check passed for env contract

## Server-only hidden signed read URL smoke

Smoke name:

M23J SERVER-ONLY HIDDEN SIGNED READ URL SMOKE V3

Input:

- ownerCid: Cid-M23F-Persistent-Video-Smoke
- DB record from cidentia_media_assets
- inline read gates only for this process
- PM2 was not restarted
- no production env was permanently opened

Result:

- ok: true
- code: M23J_SERVER_ONLY_SIGNED_READ_URL_CREATED_OK
- signerCode: SIGNED_MEDIA_READ_URL_CREATED
- mediaAssetIdPresent: true
- signedMediaReadUrlCreated: true
- signedMediaReadUrlPresentHidden: true
- expiresInSeconds: 300
- mediaUrlGenerationEnabled: true
- objectStorageReadEnabled: true
- signedMediaReadUrlEnabled: true
- storageBucketPresentHidden: true
- storageObjectKeyPresentHidden: true
- objectStorageRead: false
- objectStorageCalled: false
- uploadPresignerTouched: false
- flutterOpened: false
- publicRouteOpened: false
- secretsExposed: false

## What this proves

- A persisted media asset can be read from DB.
- Its internal bucket/key can be used server-side.
- A short-lived signed read URL can be generated server-side.
- The signed URL was not printed.
- Storage bucket and object key were not printed.
- No Flutter render path was opened.
- No public route was opened.
- No PM2 process was restarted.
- No secrets were exposed.

## Still not completed

- Profile media route does not yet attach signed read URLs.
- publicMediaUrl remains null in profile media metadata responses.
- Flutter media/reels UI is not connected to signed read URL.
- Real video playback is not yet opened.
- PM2 production runtime gates are not permanently opened.

## Next milestone

M23K - Route-level hidden signed read URL smoke.

M23K should call api/media/read-url.js as a route handler with a persisted media asset and verify:

- HTTP 200
- SIGNED_MEDIA_READ_URL_CREATED
- signedMediaReadUrlPresentHidden: true
- bucket/key are not exposed in the response
- signed URL is not printed in logs
- public route is still not opened
- Flutter remains closed
